function [valid, Struct] = validateSeriesID(series)
% VALIDATESERIESID checks if a series is a valid cbd pull
%
% [valid, Struct] = checkSeries(series)
%
% INPUTS:
%   series      ~ char, cell with seriesID@dbID
%
% OUTPUTS:
%   valid       ~ logical for whether the pull is valid
%   Struct      ~ structure array with the following fields:
%       series      ~ char, the input series
%       valid       ~ logical array, whether the individual series is valid
%       ME          ~ Matlab/CBD Exception encountered, empty if none

% Santiago Sordo Palacios, 2019

%% Error checking
validateattributes(series, {'cell', 'char'}, {'row'});
if ischar(series)
    series = {series};
end

%% Initialize structures
nSer = length(series);
validArray = false(nSer, 1);
Struct(nSer).series = [];
Struct(nSer).valid = false;
Struct(nSer).ME = [];

%% check the series
for iSer = 1:nSer
    thisSeries = series{iSer};
    Struct(iSer).series = thisSeries;
    try
        cbd.data(thisSeries);
        validArray(iSer) = true;
        Struct(iSer).valid = true;
        Struct(iSer).ME = MException.empty(0,1);
    catch ME
        validArray(iSer) = false;
        Struct(iSer).valid = false;
        Struct(iSer).ME = ME;
    end
end

valid = all(validArray(:));

end
