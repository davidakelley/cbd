function y = year(d)
% YEAR Get the year number
%   y = YEAR(d) Returns the year of the serial date d.
%
% See also quarter, month, day

% David Kelley, 2014

dv = datevec(d);

y = dv(:,1);
end