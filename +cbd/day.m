function day = day(d)
% DAY Get the day within a month
%
% day = DAY(day) Returns the day of the month of the serial date d.
%
% See also year, quarter, month

% David Kelley, 2014

dv = datevec(d);

day = dv(:,3);
end