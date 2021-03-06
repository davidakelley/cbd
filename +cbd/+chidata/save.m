function saved = save(sectionIn, dataIn, propsIn, varargin)
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
%   tolerance   ~ double, the accepted tolerance when checking
%               whether the new data revises old data, optional.
%   userInput   ~ char, the input used for any and all of the user
%               prompts issued by the function. Using this is DANGEROUS
%               and NOT recommended outside of the testing framework.
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

%% Setup
% Handle inputs
[section, data, props] = checkInputs(sectionIn, dataIn, propsIn);
[tolerance, prompt] = parseVarargin(varargin);

% Load the chidata directory
chidataDir = cbd.chidata.dir();

%% Index
% Load the index
[index, indexFname] = cbd.chidata.loadIndex();

% Update the index
curSeries = data.Properties.VariableNames;
[updatedIndex, isNewSection] = ...
    cbd.chidata.updateIndex(index, section, curSeries, prompt);

%% Update step 
% Get the data and props files
if ~isNewSection
    % If it is not a new section, open data and prop files and compare
    [oldData, dataFname] = cbd.chidata.loadData(section);
    cbd.chidata.compareData(data, oldData, tolerance, prompt);
    [oldProps, propsFname] = cbd.chidata.loadProps(section);
    cbd.chidata.compareProps(props, oldProps, prompt);
else
    % If it is a new section, store the names of the new files
    dataFname = fullfile(chidataDir, [section '_data.csv']);
    propsFname = fullfile(chidataDir, [section '_prop.csv']);
end % if-else

% Write the dynamic properties to the structure
props = cbd.chidata.dynamicFields(props, 'add');

% Make the properties table
propTable = prop_struct2table(props, data);

%% Writing step

% Write index file
cbd.chidata.writeIndex(indexFname, updatedIndex);

% Write data file
writetable(data, dataFname, 'WriteRowNames', true);

% Write props file
writetable(propTable, propsFname, 'WriteRowNames', true);

% Store output argument
saved = true;

end

function [section, data, props] = checkInputs(sectionIn, dataIn, propsIn)
%CHECKINPUTS checks the inputs to the cbd.chidata.save function
%
% Santiago Sordo-Palacios, 2019

% Check section validity
assert(ischar(sectionIn) && ~isempty(sectionIn), ...
    'chidata:save:invalidSection', ...
    'Section is not a character or is empty');
section = upper(sectionIn);

% Check data validity
assert(istable(dataIn) && ~isempty(dataIn), ...
    'chidata:save:invalidData', ...
    'Data is not a table or is empty');

% Pass to cbd.private.cbdTable to make a cbd-style table
values = dataIn{:, :};
dates = cbd.private.mdatenum(dataIn.Properties.RowNames);
varNames = upper(dataIn.Properties.VariableNames);
data = cbd.private.cbdTable(values, dates, varNames, true);

% Check properties validity
assert(isstruct(propsIn) && ~isempty(propsIn), ...
    'chidata:save:invalidProps', ...
    'Props is not a structure or is empty');
props = cbd.chidata.dynamicFields(propsIn, 'remove');

% Check that the size of data and props are equal
dataSize = size(dataIn, 2);
propSize = size(propsIn, 2);
assert(isequal(dataSize, propSize), ...
    'chidata:save:dataPropMismatch', ...
    'Data contains "%s" series while properties has %s"', ...
    dataSize, propSize);

end % function

function [tolerance, prompt] = parseVarargin(vararginIn)
%PARSEINPUTS parses the varargin inputs to the main function call
%
% Santiago Sordo-Palacios, 2019

% Input parse
inP = inputParser;
inP.addParameter('tolerance', 1e-12, @isnumeric);
inP.addParameter('userInput', '', @ischar);
inP.parse(vararginIn{:});
tolerance = inP.Results.tolerance;
userInput = inP.Results.userInput;

% Anonymous function to call prompt
if isempty(userInput)
    prompt = @(id, msg) cbd.chidata.prompt(id, msg);
else
    prompt = @(id, msg) cbd.chidata.prompt(id, msg, userInput);
end % if-isempty

end % function

function propTable = prop_struct2table(propStruct, data)
%PROP_STRUCT2TABLE transforms a properties structure into a table
%
% Santiago Sordo-Palacios, 2019

% Convert structure to table
propCell = squeeze(struct2cell(propStruct));
cellNames = fieldnames(propStruct);
propTable = cell2table(propCell, ...
    'RowNames', cellNames, ...
    'VariableNames', data.Properties.VariableNames);

end % function
