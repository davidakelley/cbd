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
defaultStartDate = datenum('01-Jan-1900');
defaultEndDate = floor(now);

% Parse the inputs
c = cbd.source.connectBloomberg(opts.dbID);
sec = parseSeriesID(seriesID);
startDate = cbd.private.parseDates(opts.startDate, ...
    'defaultDate', defaultStartDate, ...
    'formatOut', 'datenum');
endDate = cbd.private.parseDates(opts.endDate, ...
    'defaultDate', defaultEndDate, ...
    'formatOut', 'datenum');
frequency = parseFrequency(opts.frequency);
bbfield = parseBbfield(c, opts.bbfield);

%% Get the data
fetch_data = history(c, sec, {bbfield}, startDate, endDate, frequency);

%If the security was invalid, then Bloomberg returns a character
if ischar(fetch_data)
    id = 'bloombergseries:noPull';
    msg = sprintf('Invalid Bloomberg security "%s@%s"', ...
        seriesID, opts.dbID);
    ME = MException(id, msg);
    throw(ME);
end % if-notisnumeric

if isempty(fetch_data)
    % If the security is empty, manually return a NaN table
    warning('bloombergseries:nanPull', ...
        ['Bloomberg request returned empty for valid "%s@%s" \n' ...
        'Using valid bbfield "%s", startDate "%s", and endDate "%s"\n' ...
        'Returning a NaN table of frequency "%s" instead'], ...
        seriesID, opts.dbID, bbfield, ...
        cbd.private.mdatestr(startDate), ...
        cbd.private.mdatestr(endDate), frequency);
    data = getNanTable(frequency(1));
else
    % Otherwise format the fetched data as a cbd table
    dataCol = fetch_data(:,2);
    timeCol = cbd.private.endOfPer(fetch_data(:,1), frequency(1), true);
    seriesName = {upper(matlab.lang.makeValidName(seriesID))};
    data = cbd.private.cbdTable(dataCol, timeCol, seriesName);
end % if-isempty

% Trim out the extraneous dates before startDate
% NOTE: This a fix for the @blp/history bug
actualStartDate = datenum(data.Properties.RowNames{1});
if actualStartDate < startDate
    data = cbd.trim(data, 'startDate', startDate);
end % if-startDate 

% Trim out the extraneous dates after endDate
% NOTE: This a fix for Bloomberg having observations for current month
actualEndDate = datenum(data.Properties.RowNames{end});
if actualEndDate > endDate
    data = cbd.trim(data, 'endDate', endDate);
end % if-startDate 

%% create the properties
if nargout == 2
    props = struct;
    props.ID = [seriesID '@' opts.dbID];
    props.dbInfo = 'BLOOMBERG';
    props.value = data;
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

% Make uppercase because history() is case sensitive
seriesID = upper(seriesID);

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
    id = 'bloombergseries:invalidfrequency';
    msg = sprintf('Invalid frequency "%s"', freqIn);
    ME = MException(id, msg);
    throw(ME);
end % if-isempty

freqOut = longFreqs{loc};

end % function-parseFreq

function bbfield = parseBbfield(c, bbfield)
%PARSEFIELD parses the field input for bloomberg and checks if valid
%
% INPUTS:
%   bbfield         ~ char, the input field
%
% OUPUTS:
%   bbfield         ~ char, the output field

if isempty(bbfield)
    bbfield = 'LAST_PRICE';
else 
    % Check if the field is defined in Bloomberg
    fieldResults = fieldinfo(c, bbfield);
    validField = ~strcmpi(fieldResults{5}, 'Unknown Field Id/Mnemonic');
    if ~validField
        id = 'bloombergseries:invalidbbfield';
        msg = sprintf('Invalid bbfield "%s"', bbfield);
        ME = MException(id, msg);
        throw(ME);
    end % if-notvalidField
end

end % function-parseBbfield

function data = getNanTable(freq)
%GETNANTABLE downlaods a NaN filler table for an empty Bloomberg pull
%
% This is done by going to Haver and downloading a series of the same
% frequency with the given start and end dates. We then convert
% the zero's into NaN's
%
% INPUTS:
%   freq        ~ char, the frequency of the data requested
% 
% OUTPUTS:
%   data        ~ table, the NaN table 

switch freq
    case 'D'
        ticker = 'C00@DAILY';
    case 'W'
        ticker = 'C00@WEEKLY';
    case 'M'
        ticker = 'C0@USECON';
    case 'Q'
        ticker = 'AGG(C0@USECON, "Q", "EOP")';
end 

tickerAsNaN = ['ZERO2NAN(' ticker ')'];
data = cbd.data(tickerAsNaN);

end % function-getNanTable
