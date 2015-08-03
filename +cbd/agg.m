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
%         groupping = [cbd.year(dates) weeknum(dates)];
        error('Aggregation to W not yet developed.');
        % Matlab's weeknum function returns 2 different values for 12/30
        % and 1/2 even if they are the same week. Write a new week function.
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

groups = unique(groupIndex, 'rows');
collapseArray = nan(size(groups, 1), size(array, 2));

for iGr = 1:size(groups,1)
    grIdx = all(groupIndex == repmat(groups(iGr,:), [size(groupIndex,1), 1]), 2);
    collapseArray(iGr,:) = collapseFn(array(grIdx,:));
end

end