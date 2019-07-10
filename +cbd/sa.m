function saSeries = sa(nsaSeries, varargin)
% Seasonally adjust a series using the X13ARIMA-SEATS package.
%
% saSeries = sa(nsaSeries) seasonally adjusts nsaSeries. 
% 
% saSeries = sa(nsaSeries, ...) allows for inputs to specify the seasonal adjustment. A
% number of shortcuts are available. See the list in cbd.private.x13.makespec. Individual
% arguments can also be passed optionally as 'section:key:value' inputs.

% David Kelley, 2017-2019

%% Parse inputs and generate spec object

% We need to save d11 (the final seasonally adjusted series)
reqArg = 'x11:save:d11';

if ~isempty(varargin)
  % Check that all inputs match the patern we want
  nColons = cellfun(@(x) length(strfind(x, ':')), varargin);
  assert(all(nColons == 2 | nColons == 0), ...
    'cbd:sa:inputSpec', 'Spec inputs must each have either zero or two colons.');
  
  % Make sure we are saving the final seasonally adjusted series that we want
  if ~any(strcmpi(varargin, reqArg))
    varargin = [varargin, {reqArg}];
  end

  % Split at the colons
  specSplits = cellfun(@(x) strsplit(x, ':'), varargin, 'Uniform', false);
  specs = cat(2, specSplits{:});
  
  % Build spec object  
  specObj = cbd.private.sax13.makespec(specs{:});  
  
else 
  % Use default spec
  reqSpec = strsplit(reqArg, ':');
  
  specObj = cbd.private.sax13.makespec('DEFAULT', reqSpec{:});
end

%% Call Census program

% Preallocate output
saSeries = nsaSeries;

% Run separately on each series
for iS = 1:size(saSeries, 2)
  usePeriods = ~isnan(nsaSeries{:,iS});
  dates = cbd.private.tableDates(nsaSeries(usePeriods, iS));

  xOut = cbd.private.sax13.x13([dates nsaSeries{usePeriods, iS}], specObj, 'quiet', '-n'); 
  
  errMsgCell = strsplit(xOut.err, '\n');
  if any(strncmp(errMsgCell, ' ERROR', 5))
    errMsg = strjoin(errMsgCell(3:end), '\n');
    error('cbd:sa:sax13', errMsg);
  end
  
  saSeries{usePeriods,iS} = xOut.d11.d11;
end