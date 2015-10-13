function tabOut = cbdTable(data, obsDates, seriesNames)
% Create CBD data table from components

% David Kelley, 2015

if isempty(data)
  tabOut = table([], 'VariableNames', seriesNames);
  return
end

tabOut = array2table(data, 'VariableNames', seriesNames, ...
  'RowNames', cellstr(cbd.private.mdatestr(obsDates)));
tabOut.Properties.UserData.dates = obsDates;