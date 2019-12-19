function dates = genDates(sDate, eDate, freq)
%GENDATES creates a vector of serial dates at the end of the period
%type specified by freq from sDate to eDate.
%
% USAGE
%   dates = genDates(sDate, eDate, freq) returns a list of dates at the
%   frequency specified by freq starting in sDate and ending at eDate with
%   each date aligned to the end of the month.
%
% David Kelley, 2015

if ischar(sDate)
    sDate = datenum(sDate);
end
if ischar(eDate)
    eDate = datenum(eDate);
end

switch upper(freq)
    case 'D'
        allDays = (sDate:eDate)';
        % 0:Sunday, 1:Monday, ..., 6:Saturday
        dayVec = mod(allDays+5, 7);
        dates = allDays(dayVec ~= 0 & dayVec ~= 6);
        
    case 'W'
        allDays = (sDate:eDate)';
        % 5:Friday
        dayVec = mod(allDays+5, 7);
        dates = allDays(dayVec == 5);
        
    case 'M'
        nMonths = (cbd.year(eDate) - cbd.year(sDate) - 1) * 12 + ...
            (13 - cbd.month(sDate)) + cbd.month(eDate);
        monthList = nan(nMonths, 1);
        yearList = nan(nMonths, 1);

        % index of the end of first year
        e1Year = 13 - cbd.month(sDate); 
        
        % index of the start of last year
        sLYear = (length(monthList) - cbd.month(eDate) + 1); 

        % Fill the (partial) first year
        monthList(1:e1Year) = cbd.month(sDate):12;
        yearList(1:e1Year) = cbd.year(sDate);

        % Fill the (partial) last year
        if sLYear > 0
            monthList(sLYear:end) = 1:(length(monthList) - sLYear + 1);
            yearList(sLYear:end) = cbd.year(eDate);
        end

        % Fill whole years in between
        wholeYears = e1Year + 1:sLYear - 1;
        monthList(wholeYears) = repmat((1:12)', length(wholeYears)/12, 1);
        yearList(wholeYears) = sort( ...
            repmat((cbd.year(sDate) + 1:cbd.year(eDate) - 1)', 12, 1));

        dates = cbd.private.endOfMonth(yearList, monthList);
        
    case 'Q'
        nQuarters = (cbd.year(eDate) - cbd.year(sDate) - 1) * 4 + ...
            (5 - cbd.quarter(sDate)) + cbd.quarter(eDate);
        quartList = nan(nQuarters, 1);
        yearList = nan(nQuarters, 1);

        % index of the end of first year
        e1Year = 5 - cbd.quarter(sDate); 
        
        % index of the start of last year
        sLYear = (length(quartList) - cbd.quarter(eDate) + 1); 

        % Fill the (partial) first year
        quartList(1:e1Year) = cbd.quarter(sDate):4;
        yearList(1:e1Year) = cbd.year(sDate);

        % Fill the (partial) last year
        if sLYear > 0
            quartList(sLYear:end) = 1:(length(quartList) - sLYear + 1);
            yearList(sLYear:end) = cbd.year(eDate);
        end

        % Fill whole years in between
        wholeYears = e1Year + 1:sLYear - 1;
        quartList(wholeYears) = repmat((1:4)', length(wholeYears)/4, 1);
        yearList(wholeYears) = sort( ...
            repmat((cbd.year(sDate) + 1:cbd.year(eDate) - 1)', 4, 1));

        dates = cbd.private.endOfMonth(yearList, 3*quartList);
        
    case 'A'
        yearList = cbd.year(sDate):cbd.year(eDate);
        dates = cbd.private.endOfMonth( ...
            yearList, repmat(12, [size(yearList, 1), 1]));
    otherwise
        error('genDates:badFreq', ...
            'Frequency "%s" not supported', freq);
end

end