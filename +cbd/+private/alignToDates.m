function newSeries = alignToDates(data, dates, newDates)
%ALIGNTODATES aligns a dataset to a different set of dates
%
% newSeries = ALIGNTODATES(data, dates, newDates) takes any observations
% that line up with the original set of dates and creates a new table that
% has those observations aligned to the new set of dates.

% David Kelley, 2014

newSeries = nan([size(newDates, 1), size(data, 2)]);

oldDInd = ismember(dates, newDates);
newDInd = ismember(newDates, dates);

newSeries(newDInd, :) = data(oldDInd, :);
