function [data, dataProp] = haverpull(seriesStruct, startDate, endDate)
%HAVERPULL Get individual Haver series
% Initially attempts to use the datafeed toolbox to create connection to a
%   Haver database. If no Datafeed toolbox license can be found, use haverpull_stata to 
%   pull the data (limits the amount of metadata returned). Note that this
%   function only pulls the data, it does not do any aggregation or
%   modification. 
%
% INPUTS:
%   seriesID  ~ (string) 
%   dbID      ~ (string) 
%
% OUTPUTS:
%   data      ~ a table of the data requested in the order of the series.
%   dates     ~ dates of observed data in a column vector.
%   dataProp  ~ structre with the data properties, including those from Haver.
%
% TODO - add support for higher frequency data (currently supports M, Q, & Y)

% Coppyright: David Kelley, 2014

%% Error checking
seriesID = seriesStruct.seriesID;
dbID = seriesStruct.dbID;

validateattributes(seriesID, {'char'}, {'row'});
validateattributes(dbID, {'char'}, {'row'});
illegalChar = '()@';
assert(isempty(regexpi(seriesID, illegalChar)), ...
    'haverpull:seriesInput', 'Haverpull takes only clean series IDs.');
assert(isempty(regexpi(dbID, illegalChar)), ...
    'haverpull:seriesInput', 'Haverpull takes only clean database IDs.');

if nargin >= 3 && ~isempty(endDate)
    validateattributes(endDate, {'numeric'}, {'scalar'});
else
    endDate = [];
end
if nargin >= 2 && ~isempty(startDate)
    validateattributes(startDate, {'numeric'}, {'scalar'});
else
    startDate = [];
end

%% Create Connection
try
    lisc = true;
    hav = haver(['R:\_appl\Haver\DATA\' dbID '.dat']);
catch ex 
    if strcmpi(ex.identifier, 'datafeed:haver')
        lisc = false;
    else 
        display('If license error, please fix haverpull function!');
        rethrow(ex);
    end
end

if ~isconnection(hav)
    error('haverpull:invalidDB', 'Invalid database name or network error.');
end

%% Get the series info and data
if lisc
    try
        seriesInfo = info(hav, seriesID);
    catch
        error('haverpull:noPull', ['Cannot pull ' upper(seriesID) ' from the ' upper(dbID) ' database.']);
    end
    if isempty(startDate)
        startDate = datenum(seriesInfo.StartDate);
    end
    if isempty(endDate)
        endDate = datenum(seriesInfo.EndDate);
    end
    
    data = fetch(hav, seriesID, datestr(startDate), datestr(endDate));
else
    data = cbd.private.haverpull_stata(seriesID, startDate, endDate);
    % Convert Stata dates to Matlab dates
    freq = cbd.getFreq(data(:,1)); 
    data(:,1) = cbd.endOfPer(data(:,1), freq);  
end

data = array2table(data(:,2), 'VariableNames', {upper(seriesID)}, 'RowNames', cellstr(datestr(data(:,1))));

%% Copute transformations
if ~isnan(seriesStruct.Transform)
    tFnH = str2func(['cbd.' seriesStruct.Transform]);
    try 
        if isnan(seriesStruct.TransformArgs)
            data = tFnH(data);
        else
            data = tFnH(data, seriesStruct.TransformArgs);
        end
    catch
        error('haverpull:noFn', ['Undefined Haver transformation ' upper(seriesStruct.Transform) '.']);
    end
end

%% Transform to Table

dataProp = struct;
dataProp.ID = [seriesID '@' dbID];
if lisc
    dataProp.HaverInfo = seriesInfo;
end

end

