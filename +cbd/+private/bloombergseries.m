function [data, props] = bloombergseries(seriesID, opts)
%BLOOMBERGSERIES Fetch single Bloomberg series and returns it in a table
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
% David Kelley, 2017
% Santiago I. Sordo-Palacios, 2019

%% Parse inputs
% Check validity of inputs
cbd.private.assertSeries(seriesID, mfilename());
reqFields = {'dbID', 'startDate', 'endDate', 'frequency', 'field'};
cbd.private.assertOpts(opts, reqFields, mfilename());

% Set defaults
defaultStartDate = datenum('1/1/1900');
defaultEndDate = floor(now);
defaultFreq = 'D';
defaultField = 'LAST_PRICE';

% Parse the inputs
c = cbd.private.connectBloomberg(opts.dbID);
s = parseSeriesID(seriesID);
startDate = cbd.private.parseDates(opts.startDate, ...
    'defaultDate', defaultStartDate, ...
    'formatOut', 'datenum');
endDate = cbd.private.parseDates(opts.endDate, ...
    'defaultDate', defaultEndDate, ...
    'formatOut', 'datenum');
frequency = parseFrequency(opts.frequency, defaultFreq);
field = parseField(opts.field, defaultField);

% Get the data
[fetch_data, security_info] = history( ...
    c, s, {field}, startDate, endDate, frequency);

% Check the pull
noPull = ...
    ~isequal(security_info{1}, s) || ...
    ~isnumeric(fetch_data) || ...
    isempty(fetch_data);
if noPull
    id = 'bloombergseries:noPull';
    msg = sprintf('Pull failed for "%s@%s" with field "%s"', ...
        s, opts.dbID, field);
    ME = MException(id, msg);
    throw(ME);
end % if-noPull

%% Format to cbd-style
% Create the table
dataCol = fetch_data(:,2);
timeCol = fetch_data(:,1);
seriesName = {upper(matlab.lang.makeValidName(seriesID))};
dataRaw = cbd.private.cbdTable(dataCol, timeCol, seriesName);

% Disaggregate the data
warning off cbd:getFreq:oddDates
data = cbd.disagg(dataRaw, frequency(1), 'NAN');
warning on cbd:getFreq:oddDates

% create the properties
if nargout == 2
    props = struct;
    props.ID = [seriesID '@' opts.dbID];
    props.dbInfo = 'BLOOMBERG';
    props.value = [];
    props.provider = 'bloomberg';
    props.frequency = frequency;
    props.field = field;
end % if-nargin

end % function-bloombergseries

function seriesID = parseSeriesID(seriesID)
%PARSESERIESID checks the validity of the seriesID and cleans for bloobmerg
%
% INPUTS:
%   seriesID    ~ char, the name of the series being pull
% OUPUTS:
%   seriesID    ~ char, the cleaned version of the seriesID being pulled

% Check for the yellow keys in SeriesID
yellowKeys = {'GOVT', 'CORP', 'MTGE', 'M-MKT', 'Muni', ...
    'PDF', 'EQUITY', 'COMDTY', 'INDEX', 'CURNCY', 'PORT'};
hasYellowKey = contains(upper(seriesID), yellowKeys);

if ~hasYellowKey
    ykID = 'bloombergseries:noYellowKey';
    ykMsg = 'No yellowKeys found in "%s" of bloombergseries';
    warning(ykID, ykMsg, seriesID);
end % if-nothasYellowKey

% Add spaces to Bloomberg Series
replacementChars = {'_', ' '; '|', '/'};
for iRep = 1:size(replacementChars, 1)
    seriesID = strrep(seriesID, ...
        replacementChars{iRep, 1}, ...
        replacementChars{iRep, 2});
end

end % function-parseSeriesID

function freqOut = parseFrequency(freqIn, defaultFreq)
%PARSEFREQUENCY parses the frequency input and returns cbd.disagg one
%
% INPUTS:
%   frequency   ~ char, the input frequency
%   defaultFreq ~ char, the default frequency if frequency is empty
%
% OUPUTS:
%   frequency   ~ char, the output frequency expected by cbd.disagg

if isempty(freqIn)
    freqIn = defaultFreq;
end % if isempty

longFreqs = {'DAILY', 'WEEKLY', 'MONTHLY', 'QUARTERLY', 'YEARLY'};
shortFreqs = {'D', 'W', 'M', 'Q', 'Y'};

if length(freqIn) == 1
    [~, loc] = ismember(freqIn, shortFreqs);
else
    [~, loc] = ismember(freqIn, longFreqs);
end

if isequal(loc, 0)
    id = 'bloombergseries:invalidFrequency';
    msg = sprintf('Invalid frequency "%s"', freqIn);
    ME = MException(id, msg);
    throw(ME);
end % if-isempty

freqOut = longFreqs{loc};

end % function-parseFreq

function bbfield = parseField(bbfield, defaultField)
%PARSEFIELD parses the field input for bloomberg
%
% INPUTS:
%   field           ~ char, the input field
%   defaultField    ~ char, the default field if field is empty
%
% OUPUTS:
%   field           ~ char, the output field

if isempty(bbfield)
    bbfield = defaultField;
end

end % function-parseField



