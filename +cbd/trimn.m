function data = trimn(data, n)
% TRIMN deletes periods at the end of a dataset that are not observed for at
% least n series.

% David Kelley, 2015

if nargin < 2
  n = size(data, 2);
end

checkdata = data(:,~all(isnan(data{:,:})));

obsSeries = sum(~isnan(checkdata{:,:}), 2);

trimPers = find(obsSeries < n);
lastFull = find(obsSeries >= n, 1, 'last');
trimPers(trimPers < lastFull) = [];

data(trimPers,:) = [];