function [data, dataProp] = chidataseries(seriesID, opts)
%CHIDATASERIES reads a data series from the CHIDATA folder and returns it
%as a table.
%
% data = chidataseries(seriesID) retuns the data for seriesID.
%
% [data, dataProp] = chidataseries(seriesID, opts) returns the data for
% seriesID with the given options in opts, along with the data properties
% in dataProp.
%
% See also: chidata_save

% David Kelley, 2015-2019

chidataDir = cbd.private.chidatadir();

if ischar(opts.startDate)
    opts.startDate = datenum(opts.startDate);
end
if ischar(opts.endDate)
    opts.endDate = datenum(opts.endDate);
end 

%% Get file name, read the data
fname = getChidataFilename(seriesID, chidataDir);
rawData = readChidataSeries(seriesID, fname, chidataDir);

%% Return only requested time frame
dataDates = datenum(rawData.Properties.RowNames);
delDates = false(size(dataDates));
if nargin > 1 && isfield(opts, 'startDate') && ~isempty(opts.startDate)
    delDates = delDates | (dataDates < opts.startDate);
end
if nargin > 1 && isfield(opts, 'endDate') && ~isempty(opts.endDate)
    delDates = delDates | (dataDates > opts.endDate);
end
data = rawData(~delDates, :);

%% Get properties
if nargout > 1
    dataProp = cbd.private.loadChidataProp(fname);
    seriesIndex = strcmpi(seriesID, {dataProp.Name});
    dataProp = dataProp(seriesIndex);
    dataProp.provider = 'chidata';
end

end


function fname = getChidataFilename(series, chidataDir)
    % Read the index file and get the name of the section containing the
    % series.
    try
        dataDict = readtable(fullfile(chidataDir, 'index.csv'), 'ReadRowNames', true);
    catch
        error('cbd:data:CHIDATA:dictionaryFile', 'Data dictionary file not found.');
    end
    seriesNames = dataDict.Properties.RowNames;
    seriesInd = strcmpi(series, seriesNames);
    if sum(seriesInd) == 1
        fname = dataDict{seriesInd, 1}{1};
    elseif sum(seriesInd) > 1
        error('chidataseries:badIndex', 'Index has been corrupted.');
    elseif sum(seriesInd) < 1
        error('chidataseries:noSeries', ['Series ' series ' not found in data index.']);
    end

end

function data = readChidataSeries(series, fname, chidataDir)
    % Read the data from the section file, returns the whole history
    try
      if verLessThan('matlab', '9.1')
        readData = readtable(fullfile(chidataDir, [fname '_data.csv']), ...
          'ReadRowNames', true);
      else
        readData = readtable(fullfile(chidataDir, [fname '_data.csv']), ...
          'ReadRowNames', true, 'DatetimeType', 'text');
      end
    catch
        error('chidataseries:noFile', 'Data file not found.');
    end

    seriesInd = strcmpi(series, readData.Properties.VariableNames);
    if sum(seriesInd) == 1
        data = readData(:, seriesInd);
    elseif sum(seriesInd) > 1
        error('chidataseries:multiseries', ['Multiple series found using name ' series ' in ' fname '.']);
    else
        error('chidataseries:noSeries', ['Series ' series ' not found in specified file.']);
    end
end