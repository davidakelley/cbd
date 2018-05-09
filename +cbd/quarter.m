function q = quarter(d)
% QUARTER Get the quarter number
%
%   q = QUARTER(d) Returns the quarter number of the datenum d.
%
% See also year, month, day

% David Kelley, 2014

m = cbd.month(d);

q = nan(size(d));

q((m == 1 | m == 2 | m == 3)) = 1;
q((m == 4 | m == 5 | m == 6)) = 2;
q((m == 7 | m == 8 | m == 9)) = 3;
q((m == 10 | m == 11 | m == 12)) = 4;

end