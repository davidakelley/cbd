function eopDates = endOfPer(dates, freq)
%ENDOFPER returns the last date within a period for each date in a vector
%
% eopDates = ENDOFPER(dates, freq) takes a column vector of dates and a
% string freq (Y, Q, M, W, or D) to find the last date by period.

% Copyright: David Kelley, 2014-2015
% Updated  : Stephen Lee, August 2019

if ischar(dates)
    dates = datenum(dates);
end

validateattributes(dates, {'numeric'}, {'column'});

switch upper(freq)
    case 'D' 
        eopDates = dates;
    case 'W'
        % Assign to Saturdays. Every Friday has mod(date,7)==0
        shift = mod(dates - 1, 7);
        adj = mod(7 - shift, 7);
        eopDates = dates + adj;
    case 'M'
        eopDates = cbd.private.endOfMonth(cbd.year(dates), cbd.month(dates));
    case 'Q'
        eopDates = cbd.private.endOfMonth(cbd.year(dates), 3*cbd.quarter(dates));
    case 'A'
        eopDates = cbd.private.endOfMonth(cbd.year(dates), repmat(12, [size(dates, 1), 1]));
    otherwise
        error('endOfPer:badFreq', 'Frequency not supported.');
end

end