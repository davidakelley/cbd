function m = month(d)
% MONTH Get the month number
%   m = mnonth(d) Returns the month number of the serial date d.
%
% See also year, quarter, day

% David Kelley, 2014

dv = datevec(d);

m = dv(:,2);
end