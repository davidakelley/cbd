function sopDates = startOfPer(dates, freq)
%STARTOFPER finds the first serial date of each period.
%
% The first day of a period must be the day following the last day of the
% previous period. So we find the first day by computing end of the
% previous period.
%
% USAGE
%   sopDates = startOfPer(dates, frq)
%
% David Kelley, 2015

if ischar(dates)
    dates = datenum(dates);
end

validateattributes(dates, {'numeric'}, {'column'});

switch upper(freq)
    case 'A'
        prevY = cbd.year(dates) - 1;
        prevDate = cbd.private.endOfMonth( ...
            prevY, repmat(12, [size(dates, 1), 1]));
    case 'Q'
        prevY = cbd.year(dates);
        prevQ = cbd.quarter(dates) - 1;
        % Adjust for year roll over
        roll = prevQ == 0;
        prevY(roll) = prevY(roll) - 1;
        prevQ(roll) = 4;
        prevDate = cbd.private.endOfMonth(prevY, 3*prevQ);
    case 'M'
        prevY = cbd.year(dates);
        prevM = cbd.month(dates) - 1;
        % Adjust for year roll over
        roll = prevM == 0;
        prevY(roll) = prevY(roll) - 1;
        prevM(roll) = 12;
        prevDate = cbd.private.endOfMonth(prevY, prevM);
    case 'W'
        prevDate = cbd.private.endOfPer(dates, 'W') - 7;
    case 'D'
        prevDate = dates - 1;
end

sopDates = cbd.private.endOfPer(prevDate, freq) + 1;

end