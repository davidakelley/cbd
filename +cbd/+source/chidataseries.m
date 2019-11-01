function [data, props] = chidataseries(seriesID, opts)
%CHIDATASERIES Reads a series from CHIDATA and returns a table
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
% SEE ALSO:
%   CBD.CHIDATA_SAVE
%   CBD.CHIDATA_PROP
%   CBD.CHIDATA_DIR
%
% David Kelley, 2015-2019
% Santiago I. Sordo-Palacios, 2019

%% Setup
index = cbd.chidata.loadIndex();

%% Parse inputs
cbd.source.assertSeries(seriesID, mfilename());
reqFields = {'dbID', 'startDate', 'endDate'};
cbd.source.assertOpts(opts, reqFields, mfilename());
% TODO: better handling of the following:
assert(isequal(opts.dbID, 'CHIDATA'), 'chidataseries:invaliddbID', ... 
    'dbID "%s" in chidataseries is not CHIDATA', opts.dbID);
startDate = cbd.source.parseDates(opts.startDate);
endDate = cbd.source.parseDates(opts.endDate);

%% Get file name, read the data
section = cbd.chidata.findSection(seriesID, index);
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
end

end
