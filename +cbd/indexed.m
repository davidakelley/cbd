function indexed = indexed(inputTab, indexDate)
% INDEXED Makes an index of a series by dividing the history of the series by
% the value of the series at a given date.
%
% indexed = INDEXED(inputSeries, indexDate) creates a 100-normalized index of
% inputSeries by the value at indexDate. If indexDate is a string, it
% should be a date that occurs in the series. If it is a number, it should
% be a year that occurs within the series. 

% David Kelley, 2015

%% Handle Inputs
assert(istable(inputTab), 'cbd:index:needTable', 'Table input required.');

rNames = inputTab.Properties.RowNames;
data = inputTab{:,:};

if nargin < 2
  indexDate = rNames{1};
end

validateattributes(indexDate, {'char', 'numeric'}, {'vector'});

%% Computation
if ischar(indexDate)
  indexDatenum = datenum(indexDate);
  
  indexRow = find(indexDatenum == datenum(rNames));
  assert(length(indexRow) == 1, 'index:noDate', ...
    'Index date not found.');
  indexVal = data(indexRow, :);
  normalizing = repmat(100, [1 size(data, 2)]) ./ indexVal;
else
  % indexDate is a year (numeric)
  yearData = data(cbd.year(datenum(rNames)) == indexDate, :);
  normalizing = repmat(100, [1 size(data, 2)]) ./ nanmean(yearData);
end

indexedData = data .* repmat(normalizing, [size(data, 1) 1]);

indexed = inputTab;
indexed{:,:} = indexedData;
