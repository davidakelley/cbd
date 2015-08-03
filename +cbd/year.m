function y = year(d)
%YEAR Get the year number
%   y = year(d) Returns the year of the serial date d.
%
% See also MONTH, QUARTER

% David Kelley, 2014

dv = datevec(d);

y = dv(:,1);
end