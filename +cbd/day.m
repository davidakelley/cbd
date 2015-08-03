function day = day(d)
%DAY Get the day of month
%
% day = month(day) Returns the day of the month of the serial date d.
%
% See also YEAR, QUARTER

% David Kelley, 2014

dv = datevec(d);

day = dv(:,3);
end