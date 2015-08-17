function [freq, pers] = getFreq(dates)
%GETFREQ determines the frequency of a series of serial dates. 
%   INPUTS:
%       dates ~ serial dates
%   OUTPUTS:
%       freq  ~ character representing data frequency, either A, Q, or M.
%       pers  ~ annual periods in frequency
%
% If GETFREQ is specified with dates as a frequency identifier, it returns
% the frequency identifier and the annual periods in that frequency.

% David Kelley, 2014

if ischar(dates) && length(dates) == 1
    switch upper(dates)
        case 'A'
            pers = 1;
        case 'Q'
            pers = 4;
        case 'M'
            pers = 12;
        case 'W'
            pers = 52;
        case 'D'
            pers = 365;
    end
    freq = dates;
    return
elseif ischar(dates) && length(dates) ~= 1
    error('getFreq:dateSpec', 'Date input must be a single character (A, Q, M, W, or D).');
elseif isnumeric(dates)
    assert(size(dates, 2) == 1, 'getFreq:datenumSpec', 'Datenum input must be a column.');
    dateDiff = dates - cbd.lag(dates);
elseif istable(dates)
    % Row names must be date strings.
    tabDates = datenum(dates.Properties.RowNames);
    dateDiff = tabDates - cbd.lag(tabDates);
end

maxD = max(dateDiff);
minD = min(dateDiff);

if minD == 1 && (maxD == 3 || (maxD == 1 && size(dateDiff, 1) <=5))
    freq = 'D';
    pers = 251; % Business days
elseif maxD <= 8 && minD >= 6
    freq = 'W';
    pers = 52;
elseif maxD <= 31 && minD >= 28
    freq = 'M';
    pers = 12;
elseif maxD <= 92 && minD >= 90
    freq = 'Q';
    pers = 4;
elseif maxD <= 366 && minD >= 364
    freq = 'A';
    pers = 1;
else
    warning('cbd:getFreq:oddDates', ...
        'Dates are irregularly spaced or spaced at an unknown interval.');
    freq = 'IRREGULAR';
    pers = [min(dateDiff) max(dateDiff)];
end

end