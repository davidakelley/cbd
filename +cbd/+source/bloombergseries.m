function [data, props] = bloombergseries(seriesID, opts)
%BLOOMBERGSERIES fetches a single Bloomberg series and returns as a table
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
%       bbfield     ~ char, the field pulled from Bloomberg
%
% OUPTUTS:
%   data            ~ table, the table of the series in cbd format
%   props           ~ struct, the properties of the series
%
% David Kelley, 2017
% Santiago I. Sordo-Palacios, 2019

%% Parse inputs
% Check validity of inputs
cbd.source.assertSeries(seriesID, mfilename());
reqFields = {'dbID', 'startDate', 'endDate', 'frequency', 'bbfield'};
cbd.source.assertOpts(opts, reqFields, mfilename());

% Set defaults
defaultStartDate = datenum('1/1/1900');
defaultEndDate = floor(now);

% Parse the inputs
c = cbd.source.connectBloomberg(opts.dbID);
sec = parseSeriesID(seriesID);
startDate = cbd.source.parseDates(opts.startDate, ...
    'defaultDate', defaultStartDate, ...
    'formatOut', 'datenum');
endDate = cbd.source.parseDates(opts.endDate, ...
    'defaultDate', defaultEndDate, ...
    'formatOut', 'datenum');
frequency = parseFrequency(opts.frequency);
bbfield = parseBbfield(opts.bbfield);

% Get the data
fetch_data = history(c, sec, {bbfield}, startDate, endDate, frequency);

% Check the fetch
noPull = ~isnumeric(fetch_data) || isempty(fetch_data);
if noPull
    id = 'bloombergseries:noPull';
    msg = sprintf('Pull failed for "%s@%s" with bbfield "%s"', ...
        seriesID, opts.dbID, bbfield);
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

% Trim out the extraneous dates before startDate
% NOTE: This a fix for the @blp/history bug
actualStartDate = datenum(data.Properties.RowNames{1});
if actualStartDate < startDate
    data = cbd.trim(data, 'startDate', startDate);
end % if-startDate 

% create the properties
if nargout == 2
    props = struct;
    props.ID = [seriesID '@' opts.dbID];
    props.dbInfo = 'BLOOMBERG';
    props.value = [];
    props.provider = 'bloomberg';
    props.frequency = frequency;
    props.bbfield = bbfield;
end % if-nargin

end % function-bloombergseries

function seriesID = parseSeriesID(seriesID)
%PARSESERIESID checks the validity of the seriesID and cleans for history
%
% INPUTS:
%   seriesID    ~ char, the name of the series being pull
% OUPUTS:
%   seriesID    ~ char, the cleaned version of the seriesID being pulled

% Add spaces to Bloomberg Series
replacementChars = {'_', ' '; '|', '/'};
for iRep = 1:size(replacementChars, 1)
    seriesID = strrep(seriesID, ...
        replacementChars{iRep, 1}, ...
        replacementChars{iRep, 2});
end

end % function-parseSeriesID

function freqOut = parseFrequency(freqIn)
%PARSEFREQUENCY parses the frequency input and returns the history() one
%
% INPUTS:
%   frequency   ~ char, the input frequency
%
% OUPUTS:
%   frequency   ~ char, the output frequency expected by cbd.disagg

if isempty(freqIn)
    freqOut = 'DAILY';
    return
end % if isempty

longFreqs = {'DAILY', 'WEEKLY', 'MONTHLY', 'QUARTERLY'};
shortFreqs = {'D', 'W', 'M', 'Q'};

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

function bbfield = parseBbfield(bbfield)
%PARSEFIELD parses the field input for bloomberg
%
% INPUTS:
%   bbfield         ~ char, the input field
%
% OUPUTS:
%   bbfield         ~ char, the output field

if isempty(bbfield)
    bbfield = 'LAST_PRICE';
end

end % function-parseBbfield
