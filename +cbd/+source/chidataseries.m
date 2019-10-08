function [data, props] = chidataseries(seriesID, opts)
%CHIDATASERIES Reads a series from CHIDATA and returns a table
%
% The function requires that the opts structure has all necessary fields
% initialized (can be empty) except for dbID.
%
% INPUTS:
%   seriesID        ~ char, the name of the series
%   opts            ~ struct, the options structure with the fields:
%       dbID        ~ char, the name of the database
%       startDate   ~ datestr/datenum, the first date for the pull
%       endDate     ~ datestr/datenum, the cutoff date for the pull
%       frequency   ~ char, the specified frequency of the data
%       field       ~ char, the field pulled from Bloomberg
%
% OUPTUTS:
%   data            ~ table, the table of the series in cbd format
%   props           ~ struct, the properties of the series
%
% SEE ALSO:
%   CBD.CHIDATA_SAVE
%   CBD.CHIDATA_PROP
%   CBD.CHIDATA_DIR
%
% David Kelley, 2015-2019
% Santiago I. Sordo-Palacios, 2019

%% Setup
chidataDir = cbd.private.chidatadir();
indexName = 'index.csv';
dataExt = '_data.csv';

%% Parse inputs
cbd.source.assertSeries(seriesID, mfilename());
reqFields = {'dbID', 'startDate', 'endDate'};
cbd.source.assertOpts(opts, reqFields, mfilename());
% TODO: better handling of the following:
assert(isequal(opts.dbID, 'CHIDATA'), 'chidataseries:invaliddbID', ... 
    'dbID "%s" in chidataseries is not CHIDATA', opts.dbID);
startDate = cbd.source.parseDates(opts.startDate);
endDate = cbd.source.parseDates(opts.endDate);

%% Get file name, read the data
sectionName = getChidataFilename(seriesID, chidataDir, indexName);
rawData = readChidataSeries(seriesID, chidataDir, sectionName, dataExt);

%% Trim the data
if isempty(startDate) && isempty(endDate)
    data = rawData;
elseif isempty(startDate) && ~isempty(endDate)
    data = cbd.trim(rawData, 'endDate', endDate);
elseif ~isempty(startDate) && isempty(endDate)
    data = cbd.trim(rawData, 'startDate', startDate);
else
    data = cbd.trim(rawData, 'startDate', startDate, 'endDate', endDate);
end % if-elseif

%% Get properties
if nargout == 2
    allProps = cbd.source.loadChidataProp(sectionName);
    seriesIndex = strcmpi(seriesID, {allProps.Name});
    props = struct;
    props.ID = [seriesID '@' opts.dbID];
    props.dbInfo = allProps(seriesIndex);
    props.value = [];
    props.provider = 'chidata';
end

end

function sectionName = getChidataFilename(seriesID, chidataDir, indexName)
%GETCHIDATAFILENAME reads index and gets the section containing the series
%
% INPUTS:
%   seriesID    ~ char, the name of the series
%   chidataDir  ~ char, the CHIDATA directory
%   indexName   ~ char, the name of the file containing the index
%
% OUPTUS:
%   sectionName ~ char, the name of the section containing seriesID

% Store the full fname
fullIndexName = fullfile(chidataDir, indexName);

% Try to open the dictionary file
try
    dataDict = readtable(fullIndexName, 'ReadRowNames', true);
catch ME
    if strcmp(ME.identifier, 'MATLAB:readtable:OpenFailed')
        missID = 'chidataseries:missDictFile';
        missMsg = sprintf( ...
            'Index file %s could not be opened', fullIndexName);
        missME = MException(missID, missMsg);
        missME = addCause(missME, ME);
    end % if-strcmp
    throw(missME);
end % try-catch

% Get the name of the series
seriesNames = dataDict.Properties.RowNames;
seriesInd = strcmpi(seriesID, seriesNames);

% Get the fname of the section
if sum(seriesInd) == 1
    sectionName = dataDict{seriesInd, 1}{1};
elseif sum(seriesInd) > 1
    error('chidataseries:badIndex', ...
        'Index %s is corrupted', fullIndexName);
elseif sum(seriesInd) < 1
    error('chidataseries:noPull', ...
        'The seriesID %s is not in %s', seriesID, fullIndexName);
end % if-elseif

end % function-getChidataFilename

function data = readChidataSeries(seriesID, chidataDir, sectionName, dataExt)
%READCHIDATASERIES reads the data from the section and returns full history
%
% INPUTS:
%   seriesID    ~ char, the name of the series
%   chidataDir  ~ char, the CHIDATA directory
%   sectionName ~ char, the name of the section containing seriesID
%   dataExt     ~ char, the extension of the data files
%
% OUPTUS:
%   data        ~ table, the data for seriesID

% Store the full section file name
fullSectionName = fullfile(chidataDir, [sectionName dataExt]);

% Read the data from the section file, returns the whole history
try
    if verLessThan('matlab', '9.1')
        readData = readtable(fullSectionName, ...
            'ReadRowNames', true);
    else
        readData = readtable(fullSectionName, ...
            'ReadRowNames', true, 'DatetimeType', 'text');
    end % if-else
catch ME
    if strcmp(ME.identifier, 'MATLAB:readtable:OpenFailed')
        missID = 'chidataseries:missDataFile';
        missMsg = sprintf(...
            'Index file %s could not be opened', fullSectionName);
        missME = MException(missID, missMsg);
        missME = addCause(missME, ME);
    end % if-strcmp
    throw(missME);
end % try-catch

% Get the specific data series
seriesInd = strcmpi(seriesID, readData.Properties.VariableNames);
if sum(seriesInd) == 1
    data = readData(:, seriesInd);
elseif sum(seriesInd) > 1
    error('chidataseries:noPull', ...
        'Multiple series found using %s in %s', seriesID, sectionName);
else
    error('chidataseries:noPull', ...
        'No series found using %s in %s', seriesID, sectionName);
end % if-elseif

end % function-readChidataSeries
