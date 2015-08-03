function [agg, aggDates] = agg(data, dates, aggType, finalFreq)
%AGGREGATE Aggregates a data series to a lower frequency.
%   agg = AGGREGATE(data, dates, aggType, finalFreq) aggregates the data
%   series to the lower frequency specified by finalFreq by the method of
%   aggType. Note that the dates of the series are required.
%
%   INPUTS:
%       data        ~ column vector of data to aggregate
%       dates       ~ serial dates corresponding to observations
%       aggType     ~ method of aggregation:
%           EOP - End of Period
%           AVG - Average
%           SUM - Sum of observations
%       finalFreq   ~ final data frequency, either A, Q, or M.
%   OUTPUT:
%       agg         ~ aggregated data series
%
% See also GETFREQ

% David Kelley, 2014

%% Check inputs
validateattributes(data, {'numeric'}, {'column'});
validateattributes(dates, {'numeric'}, {'column', 'size', size(data)});
assert(strcmp(aggType, 'EOP') || strcmp(aggType, 'AVG') || strcmp(aggType, 'SUM'), ...
    'haverpull:badAgg', 'Aggregation type not supported.');
assert(strcmp(finalFreq, 'A') || strcmp(finalFreq, 'Q') || strcmp(finalFreq, 'M'), ...
    'haverpull:badFreq', 'Final frequency type not supported.');
warning('Allows non-complete period to be aggregated.');

%% Return if no aggregation needed
[origFreq, origPer] = cbd.getFreq(dates);
[~, finalPer] = cbd.getFreq(finalFreq);

if strcmp(origFreq, finalFreq)
    agg = data;
    aggDates = dates;
    return
end

%% Compute aggregation

switch finalFreq
    case 'A'
        [~, eopInd] = unique(cbd.year(dates), 'last');
    case 'Q'
        [~, eopInd] = unique([cbd.year(dates) cbd.quarter(dates)], 'rows', 'last');
    case 'M'
        [~, eopInd] = unique([cbd.year(dates) cbd.month(dates)], 'rows', 'last');
end
aggDates = dates(eopInd, :);

periodsToAgg = origPer / finalPer;

switch aggType
    case 'AVG'
        avg = cbd.movv(data, periodsToAgg);
        agg = avg(eopInd);
    case 'EOP'
        agg = data(eopInd, :);
    case 'SUM'
        sum = cbd.movv(data, periodsToAgg) .* (periodsToAgg-1);
        agg = sum(eopInd);
end

end