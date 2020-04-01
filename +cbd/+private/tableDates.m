function dates = tableDates(tabIn)
%TABLEDATES returns the observation dates as datenum integers
%
% David Kelley, 2015

% Check if the User Dates already exist
hasUserDates = ...
    isfield(tabIn.Properties.UserData, 'dates') && ...
    ~isempty(tabIn.Properties.UserData.dates);

if hasUserDates
    dates = tabIn.Properties.UserData.dates;
    % Check that the size of the dates match those of the table 
    datesMatch = size(dates, 1) == size(tabIn, 1);
    if ~datesMatch
        dates = cbd.private.mdatenum(tabIn.Properties.RowNames);
    end
else
    dates = cbd.private.mdatenum(tabIn.Properties.RowNames);
end

end % function