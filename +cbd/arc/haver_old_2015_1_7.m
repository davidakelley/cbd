function [data, dataProp] = haver(seriesID, varargin)
%HAVER Get Haver data 
% Initially attempts to use the datafeed toolbox to create connection to a
%   Haver database. 
% If no Datafeed toolbox license can be found, use haverpull_stata to 
%   pull the data (limits the amount of metadata returned, slower, less reliable).
%
% INPUTS:
%   REQUIRED:
%   seriesID  ~ string or cell array of strings. Can be either just the 
%               series ID or seriesID@dbID. Can also include Haver
%               functions implemented in CBD, e.g., DIFF(LANAGRA@USECON).
%
%   OPTIONAL:   (name value pairs)
%   dbID      ~ Haver database name used for unlabeled series (default USECON)
%   aggFreq   ~ specify a freqency for the data to be output at. If not
%               specified, data is returned using a simple merge of the individual
%               series pulled.
%   startDate ~ date string of first date to get data 
%               e.g., '01/01/1900' (default fetches whole series)
%   endDate   ~ date string of last date to get data
%
% OUTPUTS:
%   data      ~ a table of the data requested in the order of the series.
%   dataProp  ~ structre with the data properties, including those from Haver.
%
% TODO - add support for higher frequency data (currently supports M, Q, & Y)
% TODO - add support for nested functions
% TODO - add support for aggregating to lower frequency data

% Coppyright: David Kelley, 2014


%% Error checking
validateattributes(seriesID, {'cell', 'char'}, {'row'});
if ischar(seriesID)
    seriesID = {seriesID};
end

inP = inputParser;
inP.addParameter('dbID', 'USECON', @ischar);
dateValid = @(x) validateattributes(x, {'numeric', 'char'}, {'vector'});
inP.addParameter('startDate', [], dateValid);
inP.addParameter('endDate', [], @ischar);
inP.addParameter('aggFreq', [], @ischar);

inP.parse(varargin{:});
opts = inP.Results;

%% Parse series IDs 
series = cbd.private.parseSeries(seriesID, opts.dbID);

%% Pull Data
rawdata = cell(1, length(series));
dataProp = struct('ID', [], 'HaverInfo', []);
for iSer = 1:length(series)
    [rawdata{iSer}, dataProp(iSer)] = cbd.haverpull(series(iSer), datenum(opts.startDate), datenum(opts.endDate));
end

for iSer = 1:length(series)
    dataProp(iSer).series = series;
end

%% Combine series
data = cbd.merge(rawdata{:});

end


