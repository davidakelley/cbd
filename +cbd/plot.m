function h1 = plot(data, varargin)
%PLOT plots a cbd data set
%
% h1 = plot(data) plots the data in the cbd table data and returns the
% figure handle
%
% h1 = plot(...) takes a number of name-value pair arguments:
%   Title - Plot title
%   Grid - (boolean) draw grid
%   XLabel, YLabel - Title for X and Y axes
%   Tripwire - date to draw vertical line at a given date
%   Interpolate - (boolean) Interpolate nans out of series
%   Labels - Legend strings (cell array)
%   LegendPos - (compass direction) legend placement (empty for no legend)
%   Colors - line colors (cell array)
%   AxHandle - axis handle to plot on (useful for subfigures)
%   YLim - Y axis limit

% David Kelley, 2015

%% Handle inputs
defaultColors = {[0 110 147]./255, [204 0 0]./255, [102 153 0]./255, ...
  [255 136 0]./255, [153 51 204]./255, [51 181 229]./255, ...
  [255 68 68]./255, [153 204 0]./255, [255 187 51]./255, [170 102 204]./255};

ischarcell = @(x) all(cellfun(@ischar, x));

inP = inputParser;
inP.addParameter('Title', [], @ischar);
inP.addParameter('Grid', true, @islogical);
inP.addParameter('XLabel', [], @ischar);
inP.addParameter('YLabel', [], @ischar);
inP.addParameter('Tripwire', [], @ischar);
inP.addParameter('Interpolate', true, @islogical);
inP.addParameter('Labels', {}, @iscell);
inP.addParameter('LegendPos', 'nw', @ischar);
inP.addParameter('LegendRows', 0, @isnumeric);
inP.addParameter('Colors', defaultColors, @iscell);
inP.addParameter('AxHandle', [], @ishandle);
inP.addParameter('YLim', [], @isnumeric);
inP.addParameter('startDate', [], @ischar);
inP.addParameter('endDate', [], @ischar);
inP.addParameter('Marker', 'none', @ischar);
inP.addParameter('LineStyle', '-', @ischar);
inP.addParameter('DateFormat', '', @ischar);
inP.addParameter('Type', repmat({'Line'}, [1 size(data, 2)]), ischarcell);
recessValid = @(x) islogical(x) | isnumeric(x);
inP.addParameter('Recess', false, recessValid);

inP.parse(varargin{:});

opts = inP.Results;
if iscell(data) || ischar(data)
  if ~isempty(opts.startDate) && ~isempty(opts.endDate)
    data = cbd.data(data, 'startDate', opts.startDate, 'endDate', opts.endDate);
  elseif ~isempty(opts.startDate)
    data = cbd.data(data, 'startDate', opts.startDate);
  elseif ~isempty(opts.endDate)
    data = cbd.data(data, 'endDate', opts.endDate);
  else
    data = cbd.data(data);
  end
else
  rawDates = data.Properties.RowNames;
  startInd = 1; endInd = size(rawDates, 1);
  if ~isempty(opts.startDate) && ~isempty(opts.endDate)
    data = cbd.trim(data, 'startDate', opts.startDate, 'endDate', opts.endDate);
    startInd = find(strcmpi(rawDates, data.Properties.RowNames(1)));
    endInd =find(strcmpi(rawDates, data.Properties.RowNames(end)));
  elseif ~isempty(opts.startDate)
    data = cbd.trim(data, 'startDate', opts.startDate);
    startInd = find(strcmpi(rawDates, data.Properties.RowNames(1)));
  elseif ~isempty(opts.endDate)
    data = cbd.trim(data, 'endDate', opts.endDate);
    endInd = find(strcmpi(rawDates, data.Properties.RowNames(end)));
  end
  if length(opts.Recess) > 1
    opts.Recess = opts.Recess(startInd:endInd);
  end
end
if ~istable(data)
  data = array2table(data, 'RowNames', cellstr(num2str((1:size(data,1))')));
end

%% Interpolate
if opts.Interpolate
  data = cbd.interpNan(data);
end

%% Set up plot
if isempty(opts.AxHandle)
  h1 = figure;
  h1.Color = [1 1 1];
  ax1 = gca;
else
  ax1 = opts.AxHandle;
end

hold on;

%% Plot data
try
  dates = cbd.private.midPerDate(datenum(data.Properties.RowNames));
  badDates = false;
catch  % Not really a cbd table
  badDates = true;
  dates = 1:height(data);
end

plotObjs = gobjects(width(data), 1);
for iSer = 1:width(data)
  if strcmpi(opts.Type{iSer}, 'Bar')
    plotObjs(iSer) = bar(ax1, dates, data{:,iSer});
  elseif strcmp(opts.Type{iSer}, 'Line')
    if iSer <= length(opts.Colors) && ~isempty(opts.Colors{iSer})
      plotObjs(iSer) = plot(ax1, dates, data{:,iSer}, 'Color', opts.Colors{iSer}, ...
        'Marker', opts.Marker, 'LineStyle', opts.LineStyle, 'LineWidth', 1);
    else
      plotObjs(iSer) = plot(ax1, dates, data{:,iSer}, ...
        'Marker', opts.Marker, 'LineStyle', opts.LineStyle, 'LineWidth', 1);
    end
  else
    error('Unknown plot type.');
  end
end

%% Plot recessions
frq = cbd.private.getFreq(dates);

if any(opts.Recess)
  if length(opts.Recess) > 1
    recessData = opts.Recess;
  else
    if badDates
      warning('Cannot interpret dates, not plotting recessions.');
    end
    if strcmpi(frq, {'Q', 'M'})
      recess = cbd.data(['RECESS' frq]);
    elseif strcmpi(frq, 'A')
      recess = cbd.data('AGG(RECESSQ, "A", "ANY")');
    else
      recess = cbd.disagg(cbd.data('RECESSM'), frq, 'FILL');
    end
    
    recessMerge = cbd.merge(data, recess);

    startDate = find(cbd.private.tableDates(recessMerge) == datenum(data.Properties.RowNames(1)));
    endDate = find(cbd.private.tableDates(recessMerge) == datenum(data.Properties.RowNames(end)));
    recessData = recessMerge{startDate:endDate,end};
  end
  
  if ~isempty(opts.YLim)
    ylims = opts.YLim;
  else
    ylims = ylim;
  end
  recessTrue = recessData == -1;
  recessFalse = recessData == 1;
  recessData(recessTrue) = ylims(1);
  recessData(recessFalse) = ylims(2);
  
  ylims = ax1.YLim;
  
  area(ax1, dates, recessData, 'BaseValue', ylims(1), ...
    'FaceColor',[0.75 0.75 0.75], 'EdgeColor', 'none');
  ax1.Children = ax1.Children([2:size(ax1.Children,1) 1]);
  
  ax1.YLim = ylims;
end

%% Options
if ~isempty(opts.Title)
  title(opts.Title);
end

if ~isempty(opts.Tripwire)
  lineInd = datenum(opts.Tripwire);
  plot([lineInd lineInd], ylim, 'k');
end

if opts.Grid
  grid on;
end

if ~isempty(opts.XLabel)
  xlabel(opts.XLabel);
end

if ~isempty(opts.YLabel)
  ylabel(opts.YLabel);
end

if ~isempty(opts.YLim)
  ylim(opts.YLim);
end

% Add legend
if ~isempty(opts.LegendPos)
  if isempty(opts.Labels)
    opts.Labels = data.Properties.VariableNames;
  end
  
  box = 'on';
  switch lower(opts.LegendPos)
    case 'nw'
      anc = [1 1];
      buff = [10 -10];
    case 'sw'
      anc = [7 7];
      buff = [10 10];
    case 'se'
      anc = [5 5];
      buff = [-10 10];
    case 'ne'
      anc = [3 3];
      buff = [-10 -10];
    case 'no'
      anc = [2 6];
      buff = [0 10];
      box = 'off';
    case 'so'
      anc = [6 2];
      buff = [0 -25];
      box = 'off';
    otherwise
      error('Bad legend position.');
  end
  cbd.private.legendflex(plotObjs, opts.Labels, ...
    'ref', gca, 'anchor', anc, 'buffer', buff, ...
    'Interpreter', 'none', 'nrow', opts.LegendRows, 'box', box);
end

% Fix dates
if ~badDates
%   ax1.XLim = [dates(1) dates(end)];
  if isempty(opts.DateFormat)
    switch frq
      case 'D', dateFormat = 'mmm-YY';
      case 'W', dateFormat = 'mmm-YY';
      case 'M', dateFormat = 'YYYY';
      case 'Q', dateFormat = 'YYYY';
      case 'A', dateFormat = 'YYYY';
    end
  else
    dateFormat = opts.DateFormat;
  end
  ax1.XLim = [dates(1) dates(end)];
  datetick('x', dateFormat, 'keeplimits');
else
  labels = 6;
  labelGap = floor(height(data)/labels);
  ax1.XTick = 1:labelGap:height(data);
  ax1.XTickLabel = data.Properties.RowNames(1:labelGap:height(data));
  ax1.XLim = [dates(1) dates(end)];
end

