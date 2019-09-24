function [data, props] = haverseries(seriesID, opts)
%HAVERSERIES Fetch single Haver series and returns it in a table
%
% The function requires that the opts structure has all necessary fields
% initialized (can be empty) except for dbID.
%
% INPUTS:
%   seriesID        ~ char, the name of the series
%   opts            ~ struct, the options structure with the fields:
%       dbID        ~ char, the name of the Haver database
%       startDate   ~ datestr/datenum, the first date for the pull
%       endDate     ~ datestr/datenum, the cutoff date for the pull
%
% OUPTUTS:
%   data            ~ table, the table of the series in cbd format
%   props           ~ struct, the properties of the series
%
% David Kelley, 2015
% Santiago I. Sordo-Palacios, 2019

%% Parse inputs
cbd.private.assertSeries(seriesID, mfilename());
reqFields = {'dbID', 'startDate', 'endDate'};
cbd.private.assertOpts(opts, reqFields, mfilename());
c = cbd.private.connectHaver(opts.dbID);

%% Connect to Haver
% Pull seriesInfo from database and check output
try
    seriesInfo = info(c, seriesID);
catch ME
    id = 'haverseries:noPull';
    msg = sprintf('Pull failed for %s@%s', seriesID, opts.dbID);
    newME = MException(id, msg);
    newME = addCause(newME, ME);
    throw(newME);
end

% Parse date inputs
defaultStartDate = cbd.private.parseDates(seriesInfo.StartDate, ...
    'formatOut', 'datenum');
startDate = cbd.private.parseDates(opts.startDate, ...
    'formatOut', 'dd-mmm-yyyy', ...
    'defaultDate', defaultStartDate);

defaultEndDate = cbd.private.parseDates(seriesInfo.EndDate, ...
    'formatOut', 'datenum');
endDate = cbd.private.parseDates(opts.endDate, ...
    'formatOut', 'dd-mmm-yyyy', ...
    'defaultDate', defaultEndDate);

% Fetch the data from Haver
fetch_data = fetch(c, seriesID, startDate, endDate);

%% Format to cbd-style
% Create the data table
dataCol = fetch_data(:,2);
timeCol = fetch_data(:,1);
seriesName = {upper(seriesID)};
data = cbd.private.cbdTable(dataCol, timeCol, seriesName);

% create the properties
if nargout == 2
    props = struct;
    props.ID = [seriesID '@' opts.dbID];
    props.dbInfo = seriesInfo;
    props.value = [];
    props.provider = 'haver';
end % if-nargout

end % function-haverseries
