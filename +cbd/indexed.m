function indexed = indexed(inputTab, indexDate, varargin)
% INDEXED Makes an index of a series by dividing the history of the series by
% the value of the series at a given date.
%
% indexed = INDEXED(inputSeries) creates a 100-normalized index of input
% series at the first data point 
%
% indexed = INDEXED(inputSeries, indexDate) creates a 100-normalized index of
% inputSeries by the value at indexDate. If indexDate is a string, it
% should be a date that occurs in the series. If it is a number, it should
% be a year that occurs within the series. 
%
% indexed = INDEXED(...) can take on a name-value pair argument:
% FindIdxDate: Can take on values [0, 1, -1]
%        -  0:  Function will preform as if only 2 arguments were specified
%        -  1:  If the indexed date is not within the time-series,
%               choose a date forward in time closest to the specified 
%               date with data to do the index
%        - -1:  If the indexed date is not within the time-series, 
%               choose a date backwards in time closest to the specified 
%               date with data to do the index
%        - Any other numeric input will default to '0' and give a warning
%
% David Kelley, 2015
% Updated by Vamsi Kurakula, 2019

%% Handle Inputs
assert(istable(inputTab), 'cbd:index:needTable', 'Table input required.');

rNames = inputTab.Properties.RowNames;
data = inputTab{:,:};

if nargin < 2
  indexDate = rNames{1};
end

validateattributes(indexDate, {'char', 'numeric'}, {'vector'});

inP = inputParser;
inP.addParameter('FindIdxDate', 0, @isnumeric)
inP.parse(varargin{:});

opts = inP.Results;

%% Find Index Date
if opts.FindIdxDate == 1
    forwardDates = rNames(datenum(rNames) > datenum(indexDate),:);
    assert(~isempty(forwardDates), 'index:noDate', 'Index date not found.')
    indexDate = forwardDates{1,:};
elseif opts.FindIdxDate == -1
    backDates = rNames(datenum(rNames) < datenum(indexDate),:);
    assert(~isempty(backDates), 'index:noDate', 'Index date not found.')
    indexDate = backDates{end,:};  
elseif opts.FindIdxDate == 0
    
else
    warning('Not an approved option, defaulting to 0');
end
        
       
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
