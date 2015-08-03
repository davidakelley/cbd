function eopDates = endOfPer(dates, freq)
%ENDOFPER returns the last date within a period for each date in a vector
%
% eopDates = ENDOFPER(dates, freq) takes a column vector of dates and a
% string freq (Y, Q, M, W, or D) to find the last date by period.

% Copyright: David Kelley, 2014-2015

if ischar(dates)
    dates = datenum(dates);
end

validateattributes(dates, {'numeric'}, {'column'});

switch upper(freq)
    case 'D' 
        eopDates = dates;
    case 'W'
        % Assign to Saturdays. Every Friday has mod(date,7)==0
        adj = mod(dates, 7);
        adj(adj~=0) = 7 - adj(adj~=0);
        eopDates = dates + adj + 1;
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