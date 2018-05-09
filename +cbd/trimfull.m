function data = trimfull(data)
% TRIMFULL deletes periods at the end of a dataset that have nans in any series

% David Kelley, 2015

checkdata = data(:,~all(isnan(data{:,:})));

trimPers = find(any(isnan(checkdata{:,:}), 2));
lastFull = find(all(~isnan(checkdata{:,:}), 2), 1, 'last');
trimPers(trimPers<lastFull) = [];

data(trimPers,:) = [];