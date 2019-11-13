function saved = save(section, data, props, varargin)
%SAVE stores data and props to a section of the CHIDATA directory
%
% DESCRIPTION
%   The CHIDATA directory allow for users to store timeseries data to a
%   specified folder that is then accessible via cbd.expression() calls as
%   series@CHIDATA.
%
%   The directory, initialized via cbd.chidata.dir(), comprises
%   a set of sections. Each section is a collection of timeseries data
%   that are updated together. All series in a section must have the same
%   frequency and have the same start and end dates (NaN's are allowed).
%   By convention, the name of the seciton is the source of the data.
%
%   The data for a section is stored in the section_data.csv and
%   loaded with cbd.chidata.loadData(section). The properties of a
%   section are stored in section_props.csv and loaded with
%   cbd.chidata.loadProps(section). However, you should not use these
%   functions to load data or properties. Instead, use a cbd.expression()
%   call to do so.
%
%   Because the section is not explicit when making a cbd.expression()
%   call, CHIDATA uses an index.csv file to map the name of the series
%   to the section in which it is contained. The index is loaded using
%   cbd.chidata.loadIndex() function.
%
%   When updating a section, this funciton will perform a set of checks
%   between the existing data and the new data and prompt the user
%   before overwriting any data.
%
% INPUTS
%   section     ~ char, the name of the section being saved/updated
%               If the section does not exist in the index, the user
%               will be prompted to add a new section
%   data        ~ table, the table of data that is being saved. The data
%               table must be passed as a cbd-style table with valid
%               variable names and sorted rows in 'dd-mmm-yyyy' format
%   props       ~ struct, the properties of the data being saved. Each
%               series must have a valid properties field. Use
%               cbd.chidata.props(nSeries) to generate valid properties.
%   revisionTolerance
%               ~ double, the accepted tolerance when checking
%               whether the new data revises old data, optional.
%
% OUTPUTS
%   valid       ~ logical, true if the index, data, and props were all
%               updated correctly
%
% USAGE
%   >> cbd.chidata.save(section, data, properties)
%   The table data and structure properties will be saved to section
%
% WARNING
%   The data, props, and index files should not be modified by hand.
%   However, if an error occurs with a CHIDATA section, the data and
%   props files should be deleted from the folder. Reference to the
%   series in that section should be removed manually from the index.
%   The data and props should then be updated from the source data.
%
% David Kelley, 2014-2019
% Santiago Sordo-Palacios, 2019

%% Handle inputs
% Verify first three inputs
assert(ischar(section) && ~isempty(section), ...
    'chidata:save:invalidSection', ...
    'Section is not a character or is empty');
assert(istable(data) && ~isempty(data), ...
    'chidata:save:invalidData', ...
    'Data is not a table or is empty');
assert(isstruct(props) && ~isempty(props), ...
    'chidata:save:invalidProps', ...
    'Props is not a structure or is empty');

% Check for invalid fields in props
% These fields are created dynamically in this function, so they cannot
% be already included in the properties structure
dynamicFields = {'Name', 'DateTimeMod', 'UsernameMod', 'FileMod'};
if any(ismember(dynamicFields, fieldnames(props)))
    id = 'chidata:save:invalidProps';
    msg = 'Incoming properties structure contains dynamic fields';
    ME = MException(id, msg);
    throw(ME);
end % if-ismember

% Check that the size of data and props are equal
dataSize = size(data, 2);
propSize = size(props, 2);
assert(isequal(dataSize, propSize), ...
    'chidata:save:dataPropMismatch', ...
    'The number of series in data does not match number of props');

% Parse the input arguments
inP = inputParser;
inP.addParameter('revisionTolerance', 1e-12, @isnumeric);
inP.parse(varargin{:});
revisionTolerance = inP.Results.revisionTolerance;

% Anonymous function to call prompt
prompt = @(id, msg) cbd.chidata.prompt(id, msg);

% Set boolean conditions that may change throughout
writeIndex = false;
addedSection = false;
addedSeriesToSection = false;

% Load the chidata directory
chidataDir = cbd.chidata.dir();

%% Index Step
% Make sure index.csv has the series in it.
% Load the index
[index, indexFname] = cbd.chidata.loadIndex();

% Check if the section is in the index
hasSection = ismember(section, index.Section);
if ~hasSection
    % Prompt if adding a new seciton to the index
    id = 'chidata:save:addNewSection';
    msg = sprintf('Adding a new section "%s" to the index', section);
    prompt(id, msg);
    addedSection = true;
end % if

% Check if seriesID is in the index
seriesVec = data.Properties.VariableNames;
if addedSection
    seriesInIndex = false(length(seriesVec));
else
    seriesInIndex = ismember(seriesVec, index.Series);
end

% Prompt if adding new series to the index
if any(~seriesInIndex) && ~all(~seriesInIndex) && ~addedSection
    missingFromIndex = strjoin(seriesVec(~seriesInIndex), ',');
    id = 'chidata:save:addingSeries';
    msg = sprintf(...
        'Adding series "%s" to section "%s"', ...
        missingFromIndex, section);
    addedSeriesToSection = true;
    prompt(id, msg);
end

% Update index if adding new series to the section
if any(~seriesInIndex)
    index = [index; ...
        table(seriesVec(~seriesInIndex)',  ...
        repmat({section}, [sum(~seriesInIndex) 1]), ...
        'VariableNames', {'Series', 'Section'})];
    writeIndex = true;
end

nSer = length(seriesVec);
for iSer = 1:nSer
    oldSection = cbd.chidata.findSection(seriesVec{iSer}, index);
    if ~strcmpi(oldSection, section)
        id = 'chidata:save:changingSection';
        msg = sprintf( ...
            'Changing section of series "%s" from "%s" to "%s"', ...
            seriesVec{iSer}, oldSection, section);
        prompt(id, msg);
        index{strcmpi(seriesVec{iSer}, index.Series), 2} = {section};
        writeIndex = true;
    end
end

%% Data step
% Open the old data file
try
    [oldData, dataFile] = cbd.chidata.loadData(section);
    oldDataExists = true;
catch ME
    expectedID = strcmpi(ME.identifier, 'chidata:loadData:notFound');
    if expectedID
        dataFile = fullfile(chidataDir, [section '_data.csv']);
        oldDataExists = false;
        if ~addedSection
            id = 'chidata:save:newDataFile';
            msg = sprintf('Creating new data file for "%s"', section);
            prompt(id, msg);
        end % if-notaddedSection
    else
        rethrow(ME);
    end % if-else
end % try-catch

% Compare the data with the oldData
if oldDataExists
    
    % Check the end date
    newEndsBeforeOld = lt( ...
        datenum(data.Properties.RowNames{end}), ...
        datenum(oldData.Properties.RowNames{end}));
    if newEndsBeforeOld
        id = 'chidata:save:newEndsBeforeOld';
        msg = 'Overwriting with new data that has earlier endDate';
        prompt(id, msg);
    end
    
    % Check the start date
    newHasDiffStart = ne( ...
        datenum(data.Properties.RowNames{1}), ...
        datenum(oldData.Properties.RowNames{1}));
    if newHasDiffStart
        id = 'chidata:save:newHasDiffStart';
        msg = 'Overwriting with new data that has different startDate';
        prompt(id, msg);
    end
    
    % Check the overall size
    newIsShorter = size(oldData,1) > size(data,1);
    if newIsShorter
        id = 'chidata:save:newIsShorter';
        msg = 'Overwriting with new data that has a shorter history';
        prompt(id, msg);
    end
    
    % Check if removing series
    newHasFewerSeries = size(oldData,2) > size(data,2);
    if newHasFewerSeries
        id = 'chidata:save:newHasFewerSeries';
        msg = 'Overwriting with new data that has fewer series';
        prompt(id, msg);
    end
    
    % Check if adding series
    newHasMoreSeries = size(oldData,2) < size(data,2);
    if newHasMoreSeries && ~addedSeriesToSection
        id = 'chidata:save:newHasMoreSeries';
        msg = 'Adding additional series to section';
        prompt(id, msg);
    end
    
    % Check if data are being revised
    minLen = min(size(oldData, 1), size(data,1));
    minWid = min(size(oldData, 2), size(data,2));
    equalArray = lt( ...
        abs(oldData{1:minLen, 1:minWid} - data{1:minLen, 1:minWid}), ...
        revisionTolerance);
    nanArray = arrayfun( ...
        @isnan, oldData{1:minLen, 1:minWid}) | ...
        arrayfun(@isnan, data{1:minLen, 1:minWid});
    newHasRevisions = ~all(equalArray | nanArray);
    if newHasRevisions
        id = 'chidata:save:newHasRevisions';
        msg = 'Overwriting with revised data';
        prompt(id, msg);
    end
    
end % if-oldDataExists

%% Properties Step
% Open the old properties file
try
    [oldProps, propFile] = cbd.chidata.loadProps(section);
    oldPropsExists = true;
catch ME
    expectedID = strcmpi(ME.identifier, 'chidata:loadProps:notFound');
    if expectedID
        propFile = fullfile(chidataDir, [section '_prop.csv']);
        oldPropsExists = false;
        if ~addedSection
            id = 'chidata:save:newPropsFile';
            msg = sprintf('Creating new properties file for "%s"', section);
            prompt(id, msg);
        end % if-notaddedSection
    else
        throw(ME);
    end
end % try-catch

% Check old properties
if oldPropsExists
    % Remove dynamic fields
    try
        oldProps = rmfield(oldProps, dynamicFields);
    catch
        legacyFields = {'Name', 'DateTimeMod'};
        oldProps = rmfield(oldProps, legacyFields);
    end
    
    % Check if properties are udpated
    newHasDiffProps = ~isequal(oldProps, props);
    if newHasDiffProps
        id = 'chidata:save:overwriteProps';
        msg = 'Overwriting with revised properties';
        prompt(id, msg);
    end
end % try-catch

% Find the current date and username
DateTimeMod = datestr(now);
Username = getenv('username');

% Find the file that calls chidata.save
thisStack = dbstack('-completenames');
[~, loc] = ismember(mfilename(), {thisStack.name});

% Shift up one index to get calling file
loc = loc + 1;
if size(thisStack, 1) < loc
    id = 'chidata:save:noCallFun';
    msg = 'The function calling save could was not found';
    prompt(id, msg);
    FileMod = '';
else
    FileMod = thisStack(loc).file;
end

% Write the dynamic properties to the structure
for iProp = 1:length(props)
    props(iProp).DateTimeMod = DateTimeMod;
    props(iProp).UsernameMod = Username;
    props(iProp).FileMod = FileMod;
end

% Convert structure to table
propCell = squeeze(struct2cell(props));
goodPropNames = all(~any(cellfun( ...
    @strcmp, propCell, repmat({','}, size(propCell)))));
assert(goodPropNames, ...
    'chidata:save:badPropNames', ...
    'Property names cannot contain commas.');
cellNames = fieldnames(props);
propTable = cell2table(propCell, ...
    'RowNames', cellNames, ...
    'VariableNames', data.Properties.VariableNames);

%% Writing step

% Write the index file if updated
if writeIndex
    writetable(index, indexFname);
end

% Write data file
writetable(data, dataFile, 'WriteRowNames', true);

% Write props file
writetable(propTable, propFile, 'WriteRowNames', true);

% Store output
saved = true;

end
