function dates = tableDates(tabIn)
% Return the observation dates as Matlab datenum integers

% David Kelley, 2015

if isfield(tabIn.Properties.UserData, 'dates') && ...
    ~isempty(tabIn.Properties.UserData.dates)
  dates = tabIn.Properties.UserData.dates;
  if size(dates, 1) ~= size(tabIn,1)
    dates = cbd.private.mdatenum(tabIn.Properties.RowNames);
  end
else
  dates = cbd.private.mdatenum(tabIn.Properties.RowNames);
end