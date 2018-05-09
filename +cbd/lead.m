function leaded = lead(data, nPer)
% LEAD Shifts a data series forward by a given number of periods
%
% leaded = LEAD(data) leads data by 1 period. data can be either a
% numeric vector or a table.
%
% leaded = LEAD(data, nPer) leads data by nPer periods. data can be either a
% numeric vector or a table.

% David Kelley, 2016

if nargin < 2
    nPer = 1;
end

leaded = cbd.lag(data, -nPer);