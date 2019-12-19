function middleDates = midOfPer(dates, freq)
%MIDOFPER returns the middle date of a period
%
% USAGE
%   dates = MIDOFPER(dates) takes a column vector of dates and a
%   finds the middle date by period.
%
% David Kelley, 2015
% Stephen Lee, 2019

validateattributes(dates, {'numeric'}, {'column'});

if nargin < 2
    freq = cbd.private.getFreq(dates);
end

eopDates = cbd.private.endOfPer(dates, freq);
sopDates = cbd.private.startOfPer(dates, freq);

middleDates = (eopDates + sopDates) ./ 2;

end