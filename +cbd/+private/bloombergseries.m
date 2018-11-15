function [data, dataProp] = bloombergseries(seriesID, opts)
%BLOOMBERSERIES Fetch single Bloomber series via the local connection
%
% Fetch a single series from Bloomberg and return it in a table.
% Frequency will default to daily.

% David Kelley, 2017

%% Handle inputs
if nargin < 2
  opts = struct; 
end

if ~isfield(opts, 'frequency')
  opts.frequency = 'DAILY';
end

% Get Bloomberg's full frequ
if length(opts.frequency) == 1
  longFreqs = {'DAILY', 'WEEKLY', 'MONTHLY', 'QUARTERLY', 'YEARLY'};
  shortFreqs = 'DWMQY';
  opts.frequency = longFreqs{strfind(shortFreqs, opts.frequency)};
end  
assert(~isempty(opts.frequency), 'Invalid frequency specification.');
shortFreq = opts.frequency(1);

if ~isfield(opts, 'startDate') || isempty(opts.startDate)
  opts.startDate = datenum('1/1/1900');
end
if ~isfield(opts, 'endDate') || isempty(opts.endDate)
  opts.endDate = floor(now);
end

if ~isfield(opts, 'field') || isempty(opts.field)
  opts.field = 'LAST_PRICE';
end

assert(~isempty(seriesID), 'haverseries:nullSeries', 'Series input empty');

% Check that we have a clean series ID
illegalChar = '(\(|\),)';
for testcase = {seriesID, opts.dbID}
  regexOut = regexpi(testcase{1}, illegalChar);
  assert(isempty(regexOut), 'bloombergseries:invalidInput', ...
    'bloombergseries takes only clean inputs.');
end

% We need to have spaces in some Bloomberg series
replacementChars = {'_', ' '};
for iRep = 1:size(replacementChars, 1)
  seriesID = strrep(seriesID, replacementChars{iRep, 1}, replacementChars{iRep, 2});
end

% Handle input options
if ischar(opts.startDate)
  opts.startDate = datenum(opts.startDate);
end
if ischar(opts.endDate)
  opts.endDate = datenum(opts.endDate);
end

%% Get data from Bloomberg
% Create Connection
persistent blpconnection
if isempty(blpconnection)
  javaaddpath('C:\blp\DAPI\blpapi3.jar');
  try
    blpconnection = blp;
  catch
    error('Unable to connect Bloomberg service.');
  end
end

if ~isconnection(blpconnection)
  % Try again to see if its a network error.
  blpconnection = blp;
  assert(isconnection(blpconnection), 'bloombergseries:noConnection', ...
    'Unable to connect Bloomberg service.');
end

% Get the data
[fetch_data, security_info] = history(blpconnection, ...
  seriesID, {opts.field}, opts.startDate, opts.endDate, opts.frequency);
assert(isequal(security_info{1}, seriesID), 'Series not retrieved.');
assert(isnumeric(fetch_data), 'Series not retreived');

%% Transform to Table
startSeriesID = subsref(strsplit(seriesID, ' '), ...
  struct('type', '{}', 'subs', {{1}}));
dataRaw = cbd.private.cbdTable(fetch_data(:,2), fetch_data(:,1), {upper(startSeriesID)});

warning off cbd:getFreq:oddDates
data = cbd.disagg(dataRaw, shortFreq, 'NAN');
warning on cbd:getFreq:oddDates

dataProp = struct;
dataProp.ID = [seriesID '@' opts.dbID];
dataProp.dbInfo = 'BLOOMBERG';
dataProp.value = [];
dataProp.provider = 'bloomberg';
dataProp.freq = shortFreq;
