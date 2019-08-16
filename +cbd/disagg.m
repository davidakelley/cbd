function disagg = disagg(data, newFreq, disaggType, extrap)
% DISAGG Disaggregates a data series to a higher frequency
%
% agg = DISAGG(data, newFreq) disaggregates the data series to a
% lower frequency specified by newFreq. 
%
% agg = DISAGG(data, newFreq, disaggType) allows the specification of how
% to fill the values in the disaggregation. The following options are
% supported:
%       NAN (default) - leave as NAN. Low-frequency values are placed in the last
%         high-frequency period of the low-frequency period they align with.
%       FILL - fill all high-frequency periods within the lower frequency period
%         with the same value.
%       INTERP - interpolate the values by linear interpolation
%       GROWTH - interpolate so that the percent growth rate is constant within
%         a low-frequency period and the aggregated high-frequency data would 
%         match the input data.
%
% agg = DISAGG(data, newFreq, disaggType, extrap) passes the extrap
% argument to cbd.interp_nan. The last argument is ignored if a different
% disaggType is specified.
%
% See also agg

% David Kelley, 2014-2015

%% Check inputs
validateattributes(data, {'table'}, {'2d'});
[oldFreq, lowFper] = cbd.private.getFreq(data);
if strcmpi(oldFreq, newFreq)
  disagg = data;
  return
end

assert(strcmp(newFreq, 'Q') || strcmp(newFreq, 'M') || strcmp(newFreq, 'W') ...
  || strcmp(newFreq, 'D') || strcmp(newFreq, 'IRREGULAR'),...
  'disagg:freq', 'Frequency type not supported.');

if nargin < 4
  extrap = false;
end
if nargin < 3
  disaggType = 'nan';
else
  assert(any(strcmp(disaggType, {'FILL', 'INTERP', 'GROWTH', 'SPLINE', 'NAN'})), ...
    'disagg:aggType', 'Aggregation type not supported.');
end

if strcmpi(newFreq, 'IRREGULAR')
  disagg = data;
  return;
end

%% Compute
if ~strcmpi(oldFreq, 'IRREGULAR')
  % Make sure to fill out all of old first period (ie, get Jan-Mar and not
  % just Mar if start with Q1)
  newStartDate = cbd.private.startOfPer(data.Properties.RowNames{1}, oldFreq);
else
  % Hopeless if you can't get the
  newStartDate = datestr(datenum(data.Properties.RowNames{1}) - max(lowFper));
end

disagg_dates = cbd.private.genDates(...
  newStartDate, ...
  cbd.private.endOfPer(data.Properties.RowNames{end}, newFreq), ...
  newFreq);

% Find end of low frequency period in high frequency
lowFdates = cbd.private.tableDates(data);
hiFInd = nan(size(lowFdates));
for iloF = 1:length(lowFdates)
  matchInd = find(disagg_dates <= lowFdates(iloF), 1, 'last');
  if ~isempty(matchInd)
    hiFInd(iloF) = matchInd;
  else
    % Date before start of loF series
    hiFInd(iloF) = nan;
  end
end

disagg_data = nan(size(disagg_dates, 1), size(data, 2));
disagg_data(hiFInd(~isnan(hiFInd)), :) = data{~isnan(hiFInd),:};
% tabDates = cellstr(cbd.private.mdatestr(disagg_dates));
disagg = cbd.private.cbdTable(disagg_data, disagg_dates, ...
  data.Properties.VariableNames);

switch upper(disaggType)
  case 'FILL'
    % Fill each period with the same value
    for iInd = size(hiFInd,1):-1:1
      if iInd == 1
        startInd = 1;
      else
        startInd = hiFInd(iInd-1)+1;
      end
      if ~isnan(startInd) && ~isnan(hiFInd(iInd))
        disagg{startInd:hiFInd(iInd),:} = ...
          repmat(disagg{hiFInd(iInd),:}, [hiFInd(iInd) - startInd + 1 1]);
      end
    end
    
  case 'INTERP'
    disagg = cbd.interp_nan(disagg, 'linear', extrap);
    
  case 'GROWTH'
    % Create same level at end of each period, smooth by using fixed
    % growth rate within a lower frequency period.
    % % If extrapolating, continue last period's growth rate (%TODO)
    grData = cbd.addition(cbd.division(cbd.diffPct(data),100),1);
    
    [~, firstInd] = cbd.first(grData);
    grData{firstInd-1,:} = 1;
    grDisagg = cbd.disagg(grData, newFreq, 'FILL');
    
    dates = datenum(grDisagg.Properties.RowNames);
    switch upper(oldFreq)
      case 'A'
        groupping = cbd.year(dates);
      case 'Q'
        groupping = [cbd.year(dates) cbd.quarter(dates)];
      case 'M'
        groupping = [cbd.year(dates) cbd.month(dates)];
      case 'W'
        groupping = weekgroup(dates);
      case 'D'
        % Can't happen, would have returned already
    end
    [~,~,uLoc] = unique(groupping, 'rows');
    [periodNumbers] = histcounts(uLoc, max(uLoc));
    periodCounts = periodNumbers(uLoc)';
    
    grDisaggData = real(grDisagg{:,:} .^ (1 ./ periodCounts));
    grDisaggData(isnan(grDisaggData)) = 1;
    
    cumGr = cumprod(grDisaggData);
    cumGr(1:hiFInd(firstInd-1)-1) = nan;
    disagg{hiFInd(1)+1:end,:} = cumGr(hiFInd(1)+1:end) * disagg{hiFInd(firstInd-1),:};
    
%   case 'SPLINE'
%     disaggData =  
%     disagg{:,:} = disaggData;
  case 'NAN'
    % Do nothing
end

end

function groupping = weekgroup(dates)
% Generate a list of weekly dates encompassing all daets, find the last
% weekly date that falls in the period given.

% Matlab's weeknum function returns 2 different values for 12/30
% and 1/2 even if they are the same week, so we have to loop.

wDates = cbd.private.genDates(dates(1)-7, dates(end), 'W');
groupping = nan(size(dates));
for iD = 1:length(dates)
  groupping(iD) = find(wDates < dates(iD), 1, 'last');
end

end