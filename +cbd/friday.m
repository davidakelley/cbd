function data = friday(data)
% FRIDAY Adjust a weekly time series to have Friday dates. 
% 
% If the observation is on a Sunday-Thrusday, adjust it to the following
% Friday. If it occurs on Saturday, adjust it to the previous Friday. 

% David Kelley, 2016

assert(istable(data));

dates = datenum(data.Properties.RowNames);

dayOfWeek = mod(dates, 7);
assert(size(unique(dayOfWeek), 1) == 1);

% Adjust Saturday & Sunday backward
% Adjust Monday - Thursday forward
dateAdj = -dayOfWeek;
dateAdj(dayOfWeek > 2) = dateAdj(dayOfWeek > 2) + 7;

data.Properties.RowNames = cellstr(datestr(dates + dateAdj));
data.Properties.UserData.dates = dates + dateAdj;