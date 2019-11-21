function [data, dataProp] = fredseries(seriesID, opts)
%FREDSERIES Fetch single FRED series and returns it in a table
%
% FREDSERIES can also pull from ALFRED by specifying the date or the date
% range from which to pull the data
%
% The function requires that the opts structure has all necessary fields
% initialized (can be empty) except for dbID.
%
% INPUTS:
%   seriesID        ~ char, the name of the series
%   opts            ~ struct, the options structure with the fields:
%       dbID        ~ char, the name of the database
%       startDate   ~ char/double/datetime, the first date for the pull
%       endDate     ~ char/double/datetime, the cutoff date for the pull
%       asOf        ~ char/double/datetime, the realtime start&end
%       asOfStart   ~ char/double/datetime, the realtime start
%       asOfEnd     ~ char/double/datetime, the realtime end
%
% OUPTUTS:
%   data            ~ table, the table of the series in cbd format
%   props           ~ struct, the properties of the series
% 
% David Kelley, 2014-2015
% Santiago I. Sordo-Palacios, 2019

%% Parse inputs
cbd.source.assertSeries(seriesID, mfilename());
reqFields = {'dbID', 'startDate', 'endDate', ...
    'asOf', 'asOfStart', 'asOfEnd'};
cbd.source.assertOpts(opts, reqFields, mfilename());
[apiKey, fredURL] = cbd.source.connectFRED(opts.dbID);

% Parse date inputs
formatOut = 'YYYY-mm-DD';
startDate = cbd.source.parseDates(opts.startDate, ...
    'formatOut', formatOut);
endDate = cbd.source.parseDates(opts.endDate, ...
    'formatOut', formatOut);
[asOfStart, asOfEnd] = parseAsOf( ...
    opts.asOf, opts.asOfStart, opts.asOfEnd, formatOut);

%% Get Fred Data
% Built the request URL base
requestURL = [fredURL, ...
    'series/observations?series_id=', seriesID, ...
    '&api_key=', apiKey, ...
    '&file_type=json'];

% Add the realtime compoennt
if ~isempty(asOfStart) && ~isempty(asOfEnd)
    requestURL = [requestURL '&realtime_start=' asOfStart];
    requestURL = [requestURL '&realtime_end=' asOfEnd];
end

% Add a start date
if ~isempty(startDate)
    requestURL = [requestURL '&observation_start=' startDate];
end

% Add an end date
if ~isempty(endDate)
    requestURL = [requestURL '&observation_end=' endDate];
end

% Fetch the data
try
    structResp = webread(requestURL);
catch ME
    if strcmpi(ME.identifier, 'MATLAB:webservices:HTTP400StatusCodeError')
        id = 'fredseries:noPull';
        msg = sprintf('Pull failed for %s@%s', seriesID, opts.dbID);
        newME = MException(id, msg);
        newME = addCause(newME, ME); 
        throw(newME);
    else
        rethrow(ME);
    end %if-else
end %try-catch
    
    
%% Parse the response
rawD = transpose(structResp.observations);
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

assert(all(size(u_rt_s) >= size(u_rt_e)), 'fredseries:devError');

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
            cond1 = u_rt_s(iVint) >= rt_s(iUpInd);
            cond2 = u_rt_s(iVint) <= rt_e(iUpInd);
            if  cond1 && cond2 
                vintages(iDate, iVint) = values(iUpInd);
            end
        end
    end
end

dates = datenum(uDate);
cbdDates = cbd.private.endOfPer(dates, cbd.private.getFreq(dates));

strDate = num2str(u_rt_s);
sepDates = [strDate(:, 1:4), ...
    repmat('-', size(strDate, 1), 1), ...
    strDate(:, 5:6), ...
    repmat('-', size(strDate, 1), 1), ...
    strDate(:, 7:8)];
vintageDates = cellstr(datestr(datenum(sepDates)));

assert(size(vintageDates, 1) > 0, 'fredseries:devError');

if size(vintageDates, 1) == 1
    seriesNames = {seriesID};
else
    vintageDates = strrep(vintageDates, '-', '_');
    seriesNames = strcat( ...
        repmat({seriesID}, ...
        size(vintageDates,1), 1), ...
        repmat('_', size(vintageDates, 1), 1), ...
        vintageDates);
end
data = cbd.private.cbdTable(vintages, cbdDates, seriesNames);

%% Get Data Properties
if nargout == 2
    requestURL = [fredURL, ...
        'series?series_id=', seriesID, ...
        '&api_key=', apiKey, ...
        '&file_type=json'];
    
    if ~isempty(asOfStart)
        requestURL = [requestURL '&realtime_start=' asOfStart];
    end
    
    if ~isempty(asOfEnd)
        requestURL = [requestURL '&realtime_end=' asOfEnd];
    end
    
    fredProp = webread(requestURL);    
    dataProp = struct;
    dataProp.ID = [seriesID '@FRED'];
    dataProp.dbInfo = fredProp.seriess;
    dataProp.value = [];
    dataProp.provider = 'fred';
end

end % function-freseries

function [asOfStart, asOfEnd] = parseAsOf(asOf, asOfStart, asOfEnd, formatOut)
%PARSEASOF parses the asOf dates in fredseries into the realtime format
%
% INPUTS:
%   formatOut   ~ char, the format to output fromd datestr()
%   
% OUPTUS:
%   asOfStart   ~ char, the realtime start date for FRED
%   asOfEnd     ~ char, the realtime end date for FRED

% Check the specification of asOf
goodSpec = isempty(asOf) || (isempty(asOfStart) && isempty(asOfEnd));
assert(goodSpec, ...
    'fredseries:asOfSpec', ...
    'Incorrect specification of asOf periods');

% Set the correct parameters given which variables are empty
if isempty(asOfStart) && isempty(asOfEnd)
    asOfStart = asOf;
    asOfEnd = asOf;
elseif isempty(asOfStart)
    asOfStart = asOfEnd;
elseif isempty(asOfEnd)
    asOfEnd = asOfStart;
end

% datestr into FRED format
asOfStart = cbd.source.parseDates(asOfStart, 'formatOut', formatOut);
asOfEnd = cbd.source.parseDates(asOfEnd, 'formatOut', formatOut);

end % function-parseAsOf
