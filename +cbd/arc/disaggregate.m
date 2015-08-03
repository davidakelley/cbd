function disagg = disaggregate(data, disaggType, newDates, extrap)
%DISAGGREGATE Disaggregates a data series to a higher frequency.
%   agg = AGGREGATE(data, dates, aggType, finalFreq) aggregates the data
%   series to the lower frequency specified by finalFreq by the method of
%   aggType. Note that the dates of the series are required.
%
%   INPUTS:
%       data        ~ column vector of data to aggregate
%       dates       ~ serial dates corresponding to observations
%       aggType     ~ method of aggregation:
%           FILL - End of Period
%           INTERP - Average
%           NAN - Place nans everywhere except at the end of the period
%       newDates    ~ final data frequency, either A, Q, or M.
%   OUTPUT:
%       disagg         ~ aggregated data series
%
% See also GETFREQ

% David Kelley, 2014

%% Check inputs
validateattributes(data, {'numeric'}, {'column'});
assert(strcmp(disaggType, 'FILL') || strcmp(disaggType, 'INTERP') || strcmp(disaggType, 'NAN'), ...
    'disagg:badAgg', 'Aggregation type not supported.');
validateattributes(newDates, {'numeric'}, {'column'});
assert(size(newDates, 1) > size(data,1), 'There are fewer dates to disaggregate to than the original series has.');

if nargin < 5
    extrap = false;
end

%% Compute 
disagg = nan(size(newDates));

oldDInd = ismember(dates, newDates);
newDInd = ismember(newDates, dates);
switch disaggType
    case 'FILL'
        avg = cbd.movv(data, periodsToAgg);
        disagg = avg(eopInd);
        error('not dev.');
    case 'INTERP'
        disaggNans = disagg;
        disaggNans(newDInd) = data(oldDInd);
        disagg = cbd.interpNan(disaggNans, 'linear', extrap);
    case 'NAN'
        disagg(newDInd) = data(oldDInd);
end

end