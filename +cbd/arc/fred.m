function [data, dates, vintageDates] = fred(seriesName, varargin)
%FRED gets a requested data series from FRED.
%
% data = FRED(seriesName) pulls a series from FRED
%
% [data, dates] = FRED(seriesName) returns the serial dates associated with
% the observations
%
%FRED also pulls data from ALFRED by specifying the date, or a range of
%dates, to pull the data for:
%
% data = FRED(seriesName, 'asOf', date) takes a date in serial format and
% returns the data as it was at that time.
%
% [data, dates, vintageDates] = FRED(seriesName, 'asOfStart', startDate, 'asOfEnd', endDate) 
% takes a pair of dates and returns every vintage of the data 
% between (including) those dates. The vintages are labeled by the 
% release date (or the start of the realtime period).

% David Kelley, 2014

%% Properties
apiKey = 'b973f7ef7fa2e9f17722a5f364c9d477';
fredURL =  'http://api.stlouisfed.org/fred/';

%% Input Parser
inP = inputParser;
datevalid = @(x) validateattributes(x, {'numeric'}, {'scalar'});
inP.addParameter('asOf', [], datevalid);
inP.addParameter('asOfStart', [], datevalid);
inP.addParameter('asOfEnd', [], datevalid);

inP.parse(varargin{:});

opts = inP.Results;

if ~isempty(opts.asOf) && (~isempty(opts.asOfStart) || ~isempty(opts.asOfEnd))
    error('fred:asOfSpec', 'Incorrect specification of asOf periods.');
end

if isempty(opts.asOfStart) && isempty(opts.asOfEnd)
    opts.asOfStart = opts.asOf;
    opts.asOfEnd = opts.asOf;
elseif isempty(opts.asOfStart)
    opts.asOfStart = opts.asOfEnd;
elseif isempty(opts.asOfEnd)
    opts.asOfEnd = opts.asOfStart;
end

opts.asOfStart = datestr(opts.asOfStart, 'YYYY-mm-DD');
opts.asOfEnd = datestr(opts.asOfEnd, 'YYYY-mm-DD');

%% Get Fred Data
requestURL = [fredURL, ...
    'series/observations?series_id=', seriesName, ...
    '&api_key=', apiKey, ...
    '&file_type=json'];

if ~isempty(opts.asOfStart)
    requestURL = [requestURL '&realtime_start=' opts.asOfStart '&realtime_end=' opts.asOfEnd];
end

fprintf(['Downloading FRED series ' seriesName '... ']);
urlResponse = urlread(requestURL);
fprintf('Processing... ');

%% Parse data
structResp = cbd.private.parse_json(urlResponse);

rawD = cell2mat(structResp.observations);

temp = struct2cell(rawD);
rt_s = str2double(strrep(temp(1, :)', '-', ''));
rt_e = str2double(strrep(temp(2, :)', '-', ''));
dates = temp(3, :)';
values = str2double(temp(4, :)');

nObs = size(rawD, 2);

%% Create vintages at dates of change

[u_rt_s, ~, rt_sInd] = unique(rt_s);
[u_rt_e, ~, ~] = unique(rt_e);
[uDate, ~, dateInd] = unique(dates);

assert(all(size(u_rt_s) >= size(u_rt_e)), 'Development error.');

nVint = size(u_rt_s, 1);
nDates = size(uDate, 1);

updates = nan(nDates, nVint);
for iObs = 1:nObs
    updates(dateInd(iObs), rt_sInd(iObs)) = iObs;
end

vintages = nan(nDates, nVint);
for iVint = 1:nVint
    for iDate = 1:nDates
        iUpInd = nan;
        jVint = -1;
        while isnan(iUpInd) && ~(iVint <= jVint + 1)
            jVint = jVint + 1;
            iUpInd = updates(iDate, iVint - jVint);
        end
        
        if ~isnan(iUpInd)
            if u_rt_s(iVint) >= rt_s(iUpInd) && u_rt_s(iVint) <= rt_e(iUpInd)
                vintages(iDate, iVint) = values(iUpInd);
            end
        end
    end
end

dates = datenum(uDate);
strDate = num2str(u_rt_s);
sepDates = [strDate(:, 1:4), repmat('-', size(strDate, 1), 1), strDate(:, 5:6), repmat('-', size(strDate, 1), 1), strDate(:, 7:8)];
vintageDates = cellstr(datestr(datenum(sepDates)));

data = vintages;

fprintf('Done. \n');


end
