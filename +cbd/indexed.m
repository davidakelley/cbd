function indexed = indexed(inputTab, indexDate)
%INDEXED Makes an index of a series by dividing the history of the series by
%the value of the series at a given date. 
%
% indexed = INDEXED(inputSeries, indexDate) creates a 100-normalized index of
% inputSeries by the value at indexDate.

% David Kelley, 2015

%% Handle Inputs
assert(istable(inputTab), 'cbd:index:needTable', 'Table input required.');

rNames = inputTab.Properties.RowNames;
data = inputTab{:,:};

if nargin < 2
    indexDate = rNames{1};
end

validateattributes(indexDate, {'char'}, {'vector'});

%% Computation
indexRow = find(datenum(indexDate) == datenum(rNames));
assert(length(indexRow) == 1, 'index:noDate', ...
    'Index date not found.');
indexVal = data(indexRow, :);

indexedData = 100 * data ./ repmat(indexVal, [size(data, 1) 1]);

indexed = inputTab;
indexed{:,:} = indexedData;
