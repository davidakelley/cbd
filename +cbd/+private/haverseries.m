function [data, dataProp] = haverseries(seriesID, opts)
%HAVERSERIES Fetch single Haver series
%
% Fetch a single series from Haver and return it in a table. StartDate and
% EndDate must be in datenum format.

% David Kelley, 2015

%% Check for illegal charactars
if nargin < 2
    opts.endDate = [];
    opts.startDate = [];
    opts.dbID = 'USECON';
end

illegalChar = '(\(|\),)';
for testcase = {seriesID, opts.dbID}
    regexOut = regexpi(testcase{1}, illegalChar);
    assert(isempty(regexOut), 'haverseries:invalidInput', 'HaverSeries takes only clean inputs.');
end

assert(~isempty(seriesID), 'haverseries:nullSeries', 'Series input empty');
assert(~any(seriesID=='@'), 'haverseries:invalidInput', '@ sign in input.');

if ischar(opts.startDate)
    opts.startDate = datenum(opts.startDate);
end
if ischar(opts.endDate)
    opts.endDate = datenum(opts.endDate);
end 

%% Get data from Haver database
% Create Connection
try
    lisc = true;
    hav = haver(['R:\_appl\Haver\DATA\' opts.dbID '.dat']);
catch ex
    % Try again to see if its a network error.
    pause(1)
    try 
      hav = haver(['R:\_appl\Haver\DATA\' opts.dbID '.dat']);
    catch
      % Database really doesn't exist
      if strcmpi(ex.identifier, 'datafeed:haver')
        lisc = false;
      else
%         display('If license error, fix HaverSeries.fetch function!');
        rethrow(ex);
      end
    end
end

if ~isconnection(hav)
    error('haverseries:invalidDB', 'Invalid database name or network error.');
end

% Get the series info and data
if lisc
    try
        seriesInfo = info(hav, seriesID);
    catch
        error('haverseries:noPull', ['Cannot pull ' upper(seriesID) ' from the ' upper(opts.dbID) ' database.']);
    end
    if isempty(opts.startDate)
        opts.startDate = datenum(seriesInfo.StartDate);
    end
    if isempty(opts.endDate)
        opts.endDate = datenum(seriesInfo.EndDate);
    end
    
    fetch_data = fetch(hav, seriesID, cbd.private.mdatestr(opts.startDate), cbd.private.mdatestr(opts.endDate));
else
  error('haverpull_stata depricated.');
  % data = cbd.private.haverpull_stata(seriesID, startDate, endDate);
  % Convert Stata dates to Matlab dates
  % freq = cbd.getFreq(data(:,1));
  % fetch_data(:,1) = cbd.endOfPer(data(:,1), freq);
end

%% Transform to Table
data = cbd.private.cbdTable(fetch_data(:,2), fetch_data(:,1), {upper(seriesID)});
 
% if ~isempty(fetch_data(:,2))
%     data = array2table(fetch_data(:,2), 'VariableNames', {upper(seriesID)}, ...
%         'RowNames', cellstr(cbd.private.mdatestr(fetch_data(:,1))));
% else
%     data = table([], 'VariableNames', {upper(seriesID)});
% end

dataProp = struct;
dataProp.ID = [seriesID '@' opts.dbID];
dataProp.dbInfo = seriesInfo;
dataProp.value = [];
dataProp.provider = 'haver';
