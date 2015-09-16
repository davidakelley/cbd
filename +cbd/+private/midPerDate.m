function cbdDates = midPerDate(dates)
%CBDDATE returns the middle date of a period
%
% dates = CBDDATE(dates) takes a column vector of dates and a
% finds the middle date by period.

% Copyright: David Kelley, 2015

validateattributes(dates, {'numeric'}, {'column'});
freq = cbd.private.getFreq(dates);

eopDates = cbd.private.endOfPer(dates, freq);
sopDates = cbd.private.startOfPer(dates, freq);

cbdDates = (eopDates+sopDates) ./ 2;

end
