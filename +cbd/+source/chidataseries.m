function [data, props] = chidataseries(seriesID, opts)
%CHIDATASERIES fetches a series from CHIDATA directory and returns a table
%
% The function requires that the opts structure has all necessary fields
% initialized (can be empty) except for dbID.
%
% See the +chidata/folder for the functions used here
%
% INPUTS:
%   seriesID        ~ char, the name of the series
%   opts            ~ struct, the options structure with the fields:
%       dbID        ~ char, the name of the database
%       startDate   ~ datestr/datenum, the first date for the pull
%       endDate     ~ datestr/datenum, the cutoff date for the pull
%
% OUPTUTS:
%   data            ~ table, the table of the series in cbd format
%   props           ~ struct, the properties of the series
%
% David Kelley, 2015-2019
% Santiago I. Sordo-Palacios, 2019

%% Setup
index = cbd.chidata.loadIndex();

%% Parse inputs
cbd.source.assertSeries(seriesID, mfilename());
reqFields = {'dbID', 'startDate', 'endDate'};
cbd.source.assertOpts(opts, reqFields, mfilename());
assert(isequal(opts.dbID, 'CHIDATA'), ...
    'chidataseries:invaliddbID', ... 
    'dbID "%s" in chidataseries is not CHIDATA', opts.dbID);
startDate = cbd.source.parseDates(opts.startDate);
endDate = cbd.source.parseDates(opts.endDate);

%% Get file name, read the data
if ~isKey(index, seriesID)
    id = 'chidataseries:noPull';
    msg = sprintf('Series "%s" is not found in the index', seriesID);
    ME = MException(id, msg);
    throw(ME);
else
    section = index(seriesID);
end % if-else
rawData = cbd.chidata.loadData(section, seriesID);

%% Trim the data
if isempty(startDate) && isempty(endDate)
    data = rawData;
elseif isempty(startDate) && ~isempty(endDate)
    data = cbd.trim(rawData, 'endDate', endDate);
elseif ~isempty(startDate) && isempty(endDate)
    data = cbd.trim(rawData, 'startDate', startDate);
else
    data = cbd.trim(rawData, 'startDate', startDate, 'endDate', endDate);
end % if-elseif

%% Get properties
if nargout == 2
    props = struct;
    props.ID = [seriesID '@' opts.dbID];
    props.dbInfo = cbd.chidata.loadProps(section, seriesID);
    props.value = [];
    props.provider = 'chidata';
    props.chidataDir = cbd.chidata.dir();
end

end
