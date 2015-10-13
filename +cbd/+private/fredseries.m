function [data, dataProp] = fredseries(series, opts)
%FREDSEREIES gets a requested data series from FRED.
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

% David Kelley, 2014-2015

%% Properties
apiKey = 'b973f7ef7fa2e9f17722a5f364c9d477';
fredURL =  'https://api.stlouisfed.org/fred/';

%% Handle date inputs
if ischar(opts.startDate)
    opts.startDate = datenum(opts.startDate);
end
if ischar(opts.endDate)
    opts.endDate = datenum(opts.endDate);
end 

assert(isfield(opts, 'asOf'), 'data:fredseries:optsIn', 'opts structure missing date inputs.');
assert(isfield(opts, 'asOfStart'), 'data:fredseries:optsIn', 'opts structure missing date inputs.');
assert(isfield(opts, 'asOfEnd'), 'data:fredseries:optsIn', 'opts structure missing date inputs.');

assert(isempty(opts.asOf) || (isempty(opts.asOfStart) && isempty(opts.asOfEnd)), ...
    'fredseries:asOfSpec', 'Incorrect specification of asOf periods.');

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
    'series/observations?series_id=', series, ...
    '&api_key=', apiKey, ...
    '&file_type=json'];

if ~isempty(opts.asOfStart)
    requestURL = [requestURL '&realtime_start=' opts.asOfStart '&realtime_end=' opts.asOfEnd];
end

if isfield(opts, 'startDate') && ~isempty(opts.startDate)
    opts.startDate = datestr(opts.startDate, 'YYYY-mm-DD');
    requestURL = [requestURL '&observation_start=' opts.startDate];
end
if isfield(opts, 'endDate') && ~isempty(opts.endDate)
    opts.endDate = datestr(opts.endDate, 'YYYY-mm-DD');
    requestURL = [requestURL '&observation_end=' opts.endDate];
end

urlResponse = cbd.private.urlread2(requestURL);

%% Parse data
structResp = cbd.private.parse_json(urlResponse);

if isfield(structResp, 'error_message')
    assert(~isfield(structResp, 'error_code'), ...
        'fredseries:fredError', ['FRED error for series ' series ': "' structResp.error_message '"']);
end

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
cbdDates = cbd.private.endOfPer(dates, cbd.private.getFreq(dates));

strDate = num2str(u_rt_s);
sepDates = [strDate(:, 1:4), repmat('-', size(strDate, 1), 1), strDate(:, 5:6), repmat('-', size(strDate, 1), 1), strDate(:, 7:8)];
vintageDates = cellstr(datestr(datenum(sepDates)));

assert(size(vintageDates, 1) > 0, 'Development error.');

if size(vintageDates, 1) == 1
    seriesNames = {series};
else
    vintageDates = strrep(vintageDates, '-', '_');
    seriesNames = strcat(repmat({series}, size(vintageDates,1), 1), repmat('_', size(vintageDates, 1), 1), vintageDates);    
end
data = cbd.private.cbdTable(vintages, cbdDates, seriesNames);


%% Get Data Properties
if nargout == 2
    requestURL = [fredURL, ...
        'series?series_id=', series, ...
        '&api_key=', apiKey, ...
        '&file_type=json'];
    
    if ~isempty(opts.asOfStart)
        requestURL = [requestURL '&realtime_start=' opts.asOfStart '&realtime_end=' opts.asOfEnd];
    end
    
    urlResponse = urlread(requestURL);
    fredProp = cbd.private.parse_json(urlResponse);
    
    dataProp = struct;
    dataProp.ID = [series '@FRED'];
    dataProp.dbInfo = fredProp.seriess{1};
    dataProp.value = [];
    dataProp.provider = 'fred';
end

end
