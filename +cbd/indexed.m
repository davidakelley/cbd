function indexed = indexed(inputTab, indexDate, dirFlag)
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
% indexed = INDEXED(..., dirFlag) can take on a name-value pair argument:
% dirFlag: Can take on values [0, 1, -1]
%        -  0:  Function will preform as if only 2 arguments were specified
%        -  1:  If the indexed date is not within the time-series,
%               choose a date forward in time closest to the specified 
%               date with data to do the index
%        - -1:  If the indexed date is not within the time-series, 
%               choose a date backwards in time closest to the specified 
%               date with data to do the index
%
% David Kelley, 2015
% Updated by Vamsi Kurakula, 2019

%% Handle Inputs
assert(istable(inputTab), 'indexed:inputNotTable', 'Table input required.');

rNames = inputTab.Properties.RowNames;
data = inputTab{:,:};

if nargin == 3      
   assert(any(ismember(dirFlag, [0 1 -1])),...
        'index:invalidDirFlag','Invalid dirFlag. Option must be 0, 1, or -1');
else
    dirFlag = 0;
end % Evaluate Flag


if nargin < 2
  indexDate = rNames{1};
end

validateattributes(indexDate, {'char', 'numeric'}, {'vector'});

       
%% Computation
if ischar(indexDate)
    
    % Find index date
    switch dirFlag
        case 1
            forwardDates = rNames(datenum(rNames) >= datenum(indexDate),:);
            assert(~isempty(forwardDates), 'indexed:noForwardDate', 'Forward index date not found in data.')
            dataFilled = fillmissing(data, 'next');
            indexDate = forwardDates{1,:};
        case -1
            backDates = rNames(datenum(rNames) <= datenum(indexDate),:);
            assert(~isempty(backDates), 'indexed:noBackDate', 'Backward index date not found in data.')
            dataFilled = fillmissing(data, 'previous');
            indexDate = backDates{end,:};
        case 0
            setDate = rNames(datenum(rNames) == datenum(indexDate),:);
            assert(~isempty(setDate), 'indexed:noDate', 'Index date not found in data.')
            dataFilled = data;
    end   
   
  indexDatenum = datenum(indexDate);
  
  indexRow = indexDatenum == datenum(rNames);
  indexVal = dataFilled(indexRow, :);
  normalizing = repmat(100, [1 size(data, 2)]) ./ indexVal;
else
  % indexDate is a year (numeric)
  yearData = data(cbd.year(datenum(rNames)) == indexDate, :);
  normalizing = repmat(100, [1 size(data, 2)]) ./ nanmean(yearData);
end

indexedData = data .* repmat(normalizing, [size(data, 1) 1]);

indexed = inputTab;
indexed{:,:} = indexedData;
