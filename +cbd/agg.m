function agg = agg(data, finalFreq, aggType)
%AGG Aggregates a data series to a lower frequency
%
% agg = AGG(data, finalFreq, aggType) aggregates a series to 
% a lower frequency specified by finalFreq by the method of
% aggType. 
%
% INPUTS:
%   data      - column vector of data to aggregate
%   finalFreq - final data frequency: either A, Q, or M.
%   aggType   - method of aggregation:
%       EOP - End of Period
%       AVG - Average
%       SUM - Sum of observations
% OUTPUT:
%   agg       - aggregated data series
%
% See also GETFREQ

% David Kelley, 2014

%% Check inputs

validateattributes(data, {'table'}, {'2d'});
assert(~isempty(strfind('AQMWD', upper(finalFreq))), ...
    'haverpull:badFreq', 'Final frequency type not supported.');
assert(strcmpi(aggType, 'EOP') || strcmpi(aggType, 'AVG') || strcmpi(aggType, 'SUM') ...
    || strcmpi(aggType, 'NANAVG') || strcmpi(aggType, 'NANSUM'), ...
    'haverpull:badAgg', 'Aggregation type not supported.');
% warning('Allows non-complete period to be aggregated.');

dates = datenum(data.Properties.RowNames);

%% Return if no aggregation needed
try
    [origFreq, ~] = cbd.private.getFreq(data);
catch
    origFreq = nan;
end
% [~, finalPer] = cbd.private.getFreq(finalFreq);

if strcmpi(origFreq, finalFreq)
    agg = data;
    return
end

%% Compute aggregation
% periodsToAgg = origPer / finalPer;

switch upper(finalFreq)
    case 'A'
        groupping = cbd.year(dates);
    case 'Q'
        groupping = [cbd.year(dates) cbd.quarter(dates)];
    case 'M'
        groupping = [cbd.year(dates) cbd.month(dates)];
    case 'W'
        warning('Aggregation to W not yet tested.');
        % Matlab's weeknum function returns 2 different values for 12/30
        % and 1/2 even if they are the same week. Write a new week function.
        wDates = cbd.private.genDates(dates(1)-7, dates(end), 'W');
        groupping = nan(size(dates));
        for iD = 1:length(dates)
          groupping(iD) = find(wDates < dates(iD), 1, 'last');
        end
    case 'D'
        groupping = [cbd.year(dates) cbd.day(dates)];
end

% eopDates = cbd.private.endOfPer(dates(eopInd), finalFreq);
% validInd = eopInd(eopDates == dates(eopInd));

switch upper(aggType)
    case 'AVG'
        aggFn = @mean;
    case 'EOP'
        aggFn = @(array) array(end,:);
    case 'SUM'
        aggFn = @sum;
    case 'NANAVG'
        aggFn = @nanmean;
    case 'NANSUM'
        aggFn = @nansum;
end

groupdata = groupBy(data{:,:}, groupping, aggFn); 
[groupdates, firstAggPerDate, groupEopInd] = unique(cbd.private.endOfPer(dates,finalFreq));

if length(firstAggPerDate) > 1 && ...
    sum(groupEopInd(end) == groupEopInd) < sum(groupEopInd(firstAggPerDate(end-1)) == groupEopInd)
    groupdata(end, :) = [];
    groupdates(end) = [];
end

agg = array2table(groupdata, 'RowNames', cellstr(datestr(groupdates)), ...
    'VariableNames', data.Properties.VariableNames);

end


function collapseArray = groupBy(array, groupIndex, collapseFn)

if nargin < 3
    collapseFn = @nanmean;
end

[~, ~, iC] = unique(groupIndex, 'rows');
collapseArray = nan(max(iC), size(array, 2));

for iSer = 1:size(array, 2)
  collapseArray(:,iSer) = accumarray(iC, array(:,iSer), [max(iC) 1], collapseFn);
end


end