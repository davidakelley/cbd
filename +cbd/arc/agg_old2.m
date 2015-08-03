function agg = agg(data, finalFreq, aggType)
%AGGREGATE Aggregates a data series to a lower frequency.
%   agg = AGG(data, finalFreq, aggType) aggregates a series to 
%   a lower frequency specified by finalFreq by the method of
%   aggType. 
%
%   INPUTS:
%       data        ~ column vector of data to aggregate
%       finalFreq   ~ final data frequency: either A, Q, or M.
%       aggType     ~ method of aggregation:
%           EOP - End of Period
%           AVG - Average
%           SUM - Sum of observations
%   OUTPUT:
%       agg         ~ aggregated data series
%
% See also GETFREQ

% David Kelley, 2014-2015

%% Check inputs

validateattributes(data, {'table'}, {'2d'});
assert(strcmpi(finalFreq, 'A') || strcmpi(finalFreq, 'Q') || strcmpi(finalFreq, 'M'), ...
    'haverpull:badFreq', 'Final frequency type not supported.');
assert(strcmpi(aggType, 'EOP') || strcmpi(aggType, 'AVG') || strcmpi(aggType, 'SUM'), ...
    'haverpull:badAgg', 'Aggregation type not supported.');
% warning('Allows non-complete period to be aggregated.');

dates = datenum(data.Properties.RowNames);

%% Return if no aggregation needed
[origFreq, origPer] = cbd.private.getFreq(data);
[~, finalPer] = cbd.private.getFreq(finalFreq);

if strcmpi(origFreq, finalFreq)
    agg = data;
    return
end

%% Compute aggregation
periodsToAgg = origPer / finalPer;

switch upper(finalFreq)
    case 'A'
        [~, eopInd] = unique(cbd.year(dates), 'last');
    case 'Q'
        [~, eopInd] = unique([cbd.year(dates) cbd.quarter(dates)], 'rows', 'last');
    case 'M'
        [~, eopInd] = unique([cbd.year(dates) cbd.month(dates)], 'rows', 'last');
end

eopDates = cbd.private.endOfPer(dates(eopInd), finalFreq);
validInd = eopInd(eopDates == dates(eopInd));

switch upper(aggType)
    case 'AVG'
        avg = cbd.movv(data, periodsToAgg);
        agg = avg(validInd, :);
    case 'EOP'
        agg = data(validInd, :);
    case 'SUM'
        sum = cbd.movt(data, periodsToAgg);
        agg = sum(validInd, :);
end

end


function collapseArray = groupBy(array, groupIndex, collapseFn)

if nargin < 3
    collapseFn = @nanmean;
end

groups = unique(groupIndex, 'rows');
collapseArray = nan(size(groups, 1), size(array, 2));

for iGr = 1:size(groups,1)
    grIdx = all(groupIndex == groups(iGr,:));
    collapseArray(iGr,:) = collapseFn(array(grInx,:));
end

end