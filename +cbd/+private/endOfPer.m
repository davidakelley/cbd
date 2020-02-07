function eopDates = endOfPer(dates, freq, weeklyAsFriday)
%ENDOFPER returns the last date within a period for each date in a vector
%
% INPUTS
%   dates       ~ double, a column vector of dates
%   freq        ~ char, the frequency of the period to end on
%
% OUTPUT:
%   eopDates    ~ double, the dates at their end of period
%
% David Kelley, 2014-2015
% Stephen Lee, 2019
% Santiago Sordo Palacios, 2020

% Handle inputs
if ischar(dates)
    dates = datenum(dates);
end
validateattributes(dates, {'numeric'}, {'column'});

if nargin < 3
    weeklyAsFriday = false;
end

% Switch on the frequency provided
switch upper(freq)
    case 'D'
        eopDates = dates;
    case 'W'
        % Assign to Saturdays. Every Friday has mod(date,7)==0
        shift = mod(dates-1, 7);
        adj = mod(7-shift, 7);
        eopDates = dates + adj;
        % If weekly is specified to Friday, shift back one day
        if weeklyAsFriday
            eopDates = eopDates - 1;
        end
    case 'M'
        eopDates = cbd.private.endOfMonth( ...
            cbd.year(dates), cbd.month(dates));
    case 'Q'
        eopDates = cbd.private.endOfMonth( ...
            cbd.year(dates), 3*cbd.quarter(dates));
    case 'A'
        eopDates = cbd.private.endOfMonth( ...
            cbd.year(dates), repmat(12, [size(dates, 1), 1]));
    otherwise
        error('endOfPer:badFreq', ...
            'Invalid frequency "%s"', freq);
end

end