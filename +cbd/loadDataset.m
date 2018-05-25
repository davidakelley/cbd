function [dataTab, rawData, transData, raggedData] = loadDataset(specifications, varargin)
% Load the a dataset from a specification file
%
% dataTab = loadDataset(specifications) loads a dataset from the cbd series specified in 
% specifications. specifications may be either a string or a cell array of strings. 
%
% dataTab = loadDataset(specifications, Name, Value) loads the dataset with
% options specified by the Name-Value pairs described below. 
%
% Other series within the dataset can be reffered to by their name followed
% by '@LOCAL' (e.g., TEMP@LOCAL) to make the specifications more readable. Any series may
% be referenced by name in a series specified after it in the ordering. Any series 
% without a transformation will be assumed to be used temporarily in the construction of 
% another series and discarded. The '%d' transformation can be used to prevent discarding 
% a series.
%
% The following options can be passed as name-value pairs: 
%   OutlierAdj      (boolean): adjust for outliers
%   OutThresh       (numeric): replace any values more than OutThresh*iqr away
%     from the median
%   FillJagged      (boolean): Fill the jagged edge with AR(p) models
%   AROrder         (numeric): Maximum lag order for the AR models
%   ARCrit          (string) : Criteria for AR models - BIC, AIC, fixed
%   Standardize     (boolean): Demean and standardize the final dataset
%   DataStart       (string) : Date to start series at
%   DataEnd         (string) : Date to end series at
%   Display         (string) : Screen display detail: verbose, default, none
%   Names           (cell)   : Cell of strings for final names of series
%   Transformations (cell)   : Cell of strings of transformations to series 

% David Kelley, 2016-2018

%% Manage inputs
% specifications should be a string or cell input of series to pull
if ~iscell(specifications)
  validateattributes(specifications, {'char'}, {'row'});
  specifications = {specifications};
else
  validateattributes(specifications, {'cell'}, {'vector'});
end
nSeries = length(specifications);

inP = inputParser;
inP.addParameter('DatasetName', '', @ischar);
inP.addParameter('OutlierAdj', false, @islogical);
inP.addParameter('OutThresh', 6, @isnumeric);
inP.addParameter('FillJagged', false, @islogical);
inP.addParameter('AROrder', 5, @isnumeric);
inP.addParameter('ARCrit', 'BIC', @ischar);
inP.addParameter('Standardize', false, @islogical);
inP.addParameter('DataStart', '', @ischar);
inP.addParameter('DataEnd', '', @ischar);
inP.addParameter('Display', 'default', @ischar); % default, verbose, none
defaultNames = arrayfun(@(x) ['Series' num2str(x)], 1:nSeries, 'Uniform', false);
inP.addParameter('Names', defaultNames, @iscell);
inP.addParameter('Transformations', repmat({'%d'}, [nSeries, 1]), @iscell);
inP.parse(varargin{:});
opts = inP.Results;

% Display
line = @(char, len) repmat(char, [1 len]);
if any(strcmpi(opts.Display, {'default', 'verbose'}))
  if ~isempty(opts.DatasetName)
    fprintf('\nRetrieving dataset: %s\n%s\n', ...
      opts.DatasetName, line('=', 20+length(opts.DatasetName)));
  else
    fprintf('\nRetrieving data: \n%s\n', line('=', 20+length(opts.DatasetName)));
  end
end

finalMarker = ~cellfun(@isempty, opts.Transformations);

%% Get data from cbd
dataseries = cell(1, nSeries);
dataProps = cell(1, nSeries);
serIndexes = cell(1, nSeries);
outStr = '';

for iSer = 1:nSeries
  if any(strcmpi(opts.Display, {'default', 'verbose'}))
    % Report on progress
    bspace = repmat('\b', [1 length(outStr)+(iSer>1)]*desktop('-inuse'));
    outStr = sprintf('Retrieving series %d of %d (%s)', ...
      max(1, sum(finalMarker(1:iSer))), sum(finalMarker), opts.Names{iSer});
    fprintf([bspace '%s\n'], outStr);
  end
  
  % Get next series
  [newStr, serIndexes{iSer}] = prepareExpression(specifications{iSer}, opts.Names);
  iSers = dataseries(serIndexes{iSer});
  try
    [dataseries{iSer}, dataProps{iSer}] = cbd.expression(newStr, iSers{:});
  catch ex
    fprintf('\nError while retrieving %s: %s\n', opts.Names{iSer}, specifications{iSer});
    rethrow(ex)
  end
end

if any(strcmpi(opts.Display, {'default', 'verbose'}))
  bspace = repmat('\b', [1 (length(outStr)+1)]*desktop('-inuse'));
  fprintf([bspace 'Completed retrieval of %d%s\n'], ...
    sum(finalMarker), ' series.');
end

%% Clean up raw series
[rawCell, dbInfo] = cellfun(@stripSeries, dataProps, 'Uniform', false);
rawSeries = cbd.merge(rawCell{:}); 

% Find the (potentially duplicated) ordering where the temp series are used
tempSerUsed = [serIndexes{:}];
baseNames = @(y) cellfun(@(x) ...
  subsref(strsplit(x, '_'), struct('type', '{}', 'subs', {{1}})), ...
  y.Properties.VariableNames, 'Uniform', false);

% Remove duplicate pulled series (after checking they really are duplicate)
rawNames = baseNames(rawSeries);
localSeries = strcmpi(unnest(dbInfo), 'local'); % need names replaced
rawNames(localSeries) = opts.Names(tempSerUsed);
[uniqueRawNames, sortOrder, duplicateIndex] = unique(rawNames);
arrayfun(@(iS) assertSameSeries(...
  rawSeries(:, duplicateIndex' == iS)), 1:length(uniqueRawNames)); 
rawData = rawSeries(:, sortOrder');
rawData.Properties.VariableNames = uniqueRawNames;

%% Filter series that are not "Final" series
tempSer = ~finalMarker;
dataseries(tempSer) = [];
opts.Names(tempSer) = [];
opts.Transformations(tempSer) = [];

% Combine into one table
dataTab = cbd.merge(dataseries{:});
if contains('Names', inP.UsingDefaults)
  % Using default names, try to use series mnemonics
  goodPullNames = ~cellfun(@(x) strncmpi('dataseries', x, 9), dataTab.Properties.VariableNames);
  opts.Names(goodPullNames) = dataTab.Properties.VariableNames(goodPullNames);
end

dataTab.Properties.VariableNames = opts.Names';

% Trim if there are any all nan periods at the end
[~, inds] = cbd.last(dataTab);
if max(inds) < size(dataTab, 1)
  dataTab = cbd.trim(dataTab, 'endDate', dataTab.Properties.RowNames{max(inds)});
end

%% Apply transformations and trim 
nSeries = size(dataTab, 2);
transformSeries = cell(size(dataseries));
for iSer = 1:nSeries
  transformSeries{iSer} = cbd.expression(opts.Transformations{iSer}, dataseries{iSer});
end
dataTab = cbd.merge(transformSeries{:});
dataTab.Properties.VariableNames = opts.Names;

if isempty(opts.DataEnd)
  opts.DataEnd = dataTab.Properties.RowNames{end};
end
% Trim if there are any all nan periods at the end
[~, inds] = cbd.last(dataTab);
if max(inds) < size(dataTab, 1)
  dataTab = cbd.trim(dataTab, 'endDate', dataTab.Properties.RowNames{max(inds)});
end
if ~isempty(opts.DataStart)
  dataTab = cbd.trim(dataTab, 'startDate', opts.DataStart);
end

transData = dataTab;

%% Check for outliers
% Replace any values greater than 6 times the interquartile range with
% the median plus 6 times the interquartile range
if opts.OutlierAdj
  dataTab = adjustOutliers(dataTab, opts);
end
dataTab = cbd.trim(dataTab, 'endDate', opts.DataEnd);

raggedData = dataTab;

%% Forecast series that end early with an AR
% Use the BIC to selecct the optimal AR model up to an AR(5). Then forecast
% any series that end before the sample with the optimal AR.
if opts.FillJagged
  dataTab = fillJagged(dataTab, opts);
end

%% Check for nan values 
nanvals = sum(sum(isnan(dataTab{:,:})));
if nanvals > 0 && any(strcmpi(opts.Display, {'verbose', 'default'}))
  fprintf('%d nan values occur in final data.\n', nanvals);
end

%% Demean & standardize
if opts.Standardize    
  dataTab = cbd.stddm(dataTab);
  if nanvals > 0 && any(strcmpi(opts.Display, {'verbose', 'default'}))
    fprintf('Data demeaned and standardized.\n');
  end  
end

%% Report number of series that end by period
if any(strcmpi(opts.Display, {'default', 'verbose'}))
  lastObsCount = zeros(size(transData, 1), 1);
  for iSer = 1:nSeries
    [~,iLastObs] = cbd.last(transData(:,iSer)); 
    lastObsCount(iLastObs) = lastObsCount(iLastObs) + 1;
  end
  
  fullPer = find(lastObsCount ~= 0, 1, 'first')-1;
  fprintf('\nSeries by last observation\n%s\n', line('-', 26));
  for iPer = fullPer+1:size(transData, 1)
    fprintf('  %s  |  %3.0f \n', ...
      transData.Properties.RowNames{iPer}, lastObsCount(iPer))
  end
  fprintf('%s\n', line('-', 26));
end

if any(strcmpi(opts.Display, {'verbose'}))
  loadMsg = sprintf('Loaded data through %s', ...
    datestr(datenum(dataTab.Properties.RowNames{end}), 'mmm. yyyy'));
  fprintf('\n%s\n%s\n', loadMsg, line('=', length(loadMsg)));
end

end

%% Specification processing functions
function [newStr, seriesIndexes] = prepareExpression(strIn, serNames)
% Replace strings of "local" series with "%d" symbols and note the indexes
% of the series for use with cbd.expression later

newStr = upper(strIn);
serInds = [];
serLocs = [];
for iS = 1:length(serNames)
  iSname = [upper(serNames{iS}) '@LOCAL'];
  
  % Replace names of local series
  newStr = strrep(newStr, iSname, '%d');
  
  % Find where the series was in what will be the string of %d's
  iStrInds = strfind(upper(strIn), iSname);
  
  serInds = [serInds repmat(iS, [1 length(iStrInds)])]; %#ok<AGROW>
  serLocs = [serLocs iStrInds]; %#ok<AGROW>
end

[~,serLocOrder] = sort(serLocs);
seriesIndexes = serInds(serLocOrder);

end

function [series, dbSource] = stripSeries(cbdProps)
% Returns a single table of all series used in constructing an indicator. 

nSeries = size(cbdProps, 2);
components = cell(nSeries, 1);
dbSource = cell(nSeries, 1);

for iS = 1:nSeries
  if isfield(cbdProps{iS}, 'value') 
    if istable(cbdProps{iS}.value)
      components{iS} = cbdProps{iS}.value;
      
      if isfield(cbdProps{iS}, 'provider') && ~isempty(cbdProps{iS}.provider)
        dbSource{iS} = cbdProps{iS}.provider;
      else
        dbSource{iS} = 'local';
      end
    end

  elseif isfield(cbdProps{iS}, 'series')
    [components{iS}, dbSource{iS}] = stripSeries(cbdProps{iS}.series);
  end
end

nonempty = ~cellfun(@isempty, components);
series = cbd.merge(components{nonempty});
dbSource = dbSource(nonempty);
end

function assertSameSeries(datatable)
% Asserts that all of the series in a table have the same data
areDuplicates = all(all(datatable{:,:} == ...
  repmat(datatable{:,1}, [1 size(datatable, 2)]) | ...
  isnan(datatable{:,:})));
assert(areDuplicates);  
end

function out = unnest(cellIn)
% Unnest a nested cell array

if iscell(cellIn)
  oneLevel = cellfun(@unnest, cellIn, 'Uniform', false);
  out = [oneLevel{:}];
else
  out = {cellIn};
end
end

%% Panel Balancing / Data Cleanng functions
function dataTab = fillJagged(dataTab, opts)
% Fill any nan values at the end of the data with AR(p) forecasts where p
% is determined by the optimal BIC.

% David Kelley, 2016

serNames = dataTab.Properties.VariableNames;
nSeries = size(dataTab, 2);

line = @(char, len) repmat(char, [1 len]);
wspace = @(len) repmat(' ', [1 len]);

if any(strcmpi(opts.Display, {'verbose'}))
  fprintf('\nFilling jagged edge\n');
  fprintf('%s\n  Series   | Periods Filled | AR Order\n%s\n', ...
    line('=', 40), line('-', 40));
end

% Loop over series: compute optimal AR(p), forecast missing observations
freqList = 'DWMQY';
baseFreq = cbd.private.getFreq(dataTab);
freqs = freqList(strfind(freqList, baseFreq):end);
for iSer = 1:nSeries
  series = dataTab(:,iSer);
  
  % Check that series is really at the base frequency
  testSeries = series;
  trueFreq = baseFreq;
  for iF = 2:length(freqs)
    testAgg = cbd.agg(testSeries, freqs(iF), 'EOP');
    
    if isequal(testSeries{~isnan(testSeries{:,:}),:}, testAgg{~isnan(testAgg{:,:}),:})
      trueFreq = iF;
    else
      break
    end
  end
  if ~strcmpi(trueFreq, baseFreq)
    series = cbd.agg(series, trueFreq, 'EOP');
  end
  
  fcastPers = size(series,1) - find(~isnan(series{:,:}), 1, 'last');
  if fcastPers == 0
    continue
  end
  
  % Optimal AR(p)
  if ~strcmpi(opts.ARCrit, 'FIXED')
    optimAR = minBIC(series, opts.AROrder, opts.ARCrit);
  else
    optimAR = opts.AROrder;
  end

  % Forecast missing values
  mdl = fitAR(series, optimAR, 'startDate', '3/31/1967');
  coef = mdl.Coefficients{:,1}';
  for iT = size(series,1)-fcastPers+1:size(series,1)
    series{iT,1} = coef * [1; series{iT-1:-1:iT-(optimAR),1}];
  end
  if strcmpi(trueFreq, baseFreq)
    dataTab(:,iSer) = series;
  else
    tempTab = cbd.merge(cbd.disagg(series, baseFreq, 'NAN'), dataTab(:,1));
    dataTab(:,iSer) =  tempTab(:,1);
  end
  
  if any(strcmpi(opts.Display, {'verbose'}))
    fprintf('  %s%s|       %d        |     %d\n', serNames{iSer}, ...
      wspace(9-length(serNames{iSer})), fcastPers, optimAR);
  end
end

if any(strcmpi(opts.Display, {'verbose'}))
  fprintf('%s\n', line('-', 40));
end

end

function optim = minBIC(series, maxlag, crit)
% Get optimal lag order by BIC

% Use the same sample period for all regressions
[~, firstObs] = cbd.first(series);
startSamp = series.Properties.RowNames{firstObs + maxlag};

bic = nan(maxlag+1,1);
for iAr = 0:maxlag
  % Intentionally using different startDate
  mdl = fitAR(series, iAr, 'startDate', startSamp);
  switch upper(crit)
    case 'BIC'
      bic(iAr+1) = log(mdl.SSE / mdl.NumObservations) + ...
        (mdl.NumPredictors + 1)/mdl.NumObservations * log(mdl.NumObservations);
    case 'AIC'
      bic(iAr+1) = log(mdl.SSE / mdl.NumObservations) + ...
        2 * (mdl.NumPredictors + 1)/mdl.NumObservations;
  end
  
end

% Rerun optimal AR model
[~,optimAR] = min(bic);
optim = optimAR - 1;
end

function mdl = fitAR(series, lagorder, varargin)
inP = inputParser;
dateValid = @(x) validateattributes(x, {'numeric', 'char'}, {'vector'});
inP.addParameter('startDate', '', dateValid);
inP.addParameter('endDate', '', dateValid);

inP.parse(varargin{:});
opts = inP.Results;

% Set up lags
data = series{:,:};

lagData = lagmat(data, lagorder);

if ~isempty(opts.startDate)
  matchDate = find(strcmpi(datestr(datenum(opts.startDate)), series.Properties.RowNames), 1);
  if isempty(matchDate), matchDate = 1; end
  firstInd = max(matchDate, lagorder+1);
else
  firstInd = lagorder+1;
end
if ~isempty(opts.endDate)
  matchDate = find(strcmpi(datestr(datenum(opts.startDate)), series.Properties.RowNames), 1);
  if isempty(matchDate), matchDate = size(series, 1); end
  endInd = min(matchDate, size(series, 1));
else
  endInd = size(series, 1);
end

y = lagData(firstInd:endInd, 1);
x = lagData(firstInd:endInd, 2:end);
mdl = fitlm(x, y);
end

function dataTab = adjustOutliers(dataTab, opts)
% Adjust outliers toward median 

% David Kelley, 2016

serNames = dataTab.Properties.VariableNames;
nSeries = size(dataTab, 2);

line = @(char, len) repmat(char, [1 len]);
wspace = @(len) repmat(' ', [1 len]);

if any(strcmpi(opts.Display, {'verbose'}))
  fprintf('\nCorrecting for outliers\n');
  fprintf('%s\n  Series   | Replacements\n%s\n', ...
    line('=', 27), line('-', 27));
end

reptotal = 0;
for iSer = 1:nSeries
  % Comput interquartile range
  cleanInd = ~isnan(dataTab{:,iSer});
  
  series = dataTab{cleanInd,iSer};
  medianVal = median(series);
  
  % Matlab and RATS take percentiles differently. Do the RATS way
  interQ = ratsPercentile(series, 75) - ratsPercentile(series, 25);
  
  hiReplace = series - medianVal >= opts.OutThresh * interQ;
  loReplace = series - medianVal <= -opts.OutThresh * interQ;
  
  % Replace any value more than a threshold times outside the IQR
  if sum(hiReplace) + sum(loReplace) > 0
    series(hiReplace) = medianVal + opts.OutThresh * interQ;
    series(loReplace) = medianVal - opts.OutThresh * interQ;
    allrep = hiReplace | loReplace;
    
    if any(strcmpi(opts.Display, {'verbose'}))
      fprintf('  %s%s|      %d\n', serNames{iSer}, ...
        wspace(9-length(serNames{iSer})), sum(allrep));
    end
    
    reptotal = reptotal + sum(allrep);
  end
  dataTab{cleanInd,iSer} = series;
end

if any(strcmpi(opts.Display, {'verbose'}))
  fprintf('%s\n', line('-', 27));
end
if any(strcmpi(opts.Display, {'default', 'verbose'}))
  fprintf('Corrected %d outlier observations.\n', reptotal);
end

end

function value = ratsPercentile(series, pct)

sortSer = sort(series);
pctPos = (pct/100) * (size(series,1)-1) + 1;
value = [floor(pctPos)+1-pctPos pctPos-floor(pctPos)] * ...
  sortSer([floor(pctPos) ceil(pctPos)]);

end