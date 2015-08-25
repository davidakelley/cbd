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
%   Tripwire - date to draw vertical line at
%   Interpolate - (boolean) Interpolate nans out of series
%   Labels - Legend strings (cell array)
%   LegendPos - (compass direction) legend placement
%   Colors - line colors (cell array)
%   AxHandle - axis handle to plot on (useful for subfigures)
%   YLim - Y axis limit

% David Kelley, 2015

%% Handle inputs
inP = inputParser;
inP.addParameter('Title', [], @ischar);
inP.addParameter('Grid', true, @islogical);
inP.addParameter('XLabel', [], @ischar);
inP.addParameter('YLabel', [], @ischar);
inP.addParameter('Tripwire', [], @ischar);
inP.addParameter('Interpolate', true, @islogical);
inP.addParameter('Labels', {}, @iscell);
inP.addParameter('LegendPos', 'nw', @ischar);
inP.addParameter('Colors', {}, @iscell);
inP.addParameter('AxHandle', [], @ishandle);
inP.addParameter('YLim', [], @isnumeric);
inP.addParameter('startDate', [], @ischar);
inP.addParameter('endDate', [], @ischar);

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
end
if ~istable(data)
    data = array2table(data, 'RowNames', cellstr(num2str((1:size(data,1))')));
end

%% Interpolate
if opts.Interpolate
    data = cbd.interpNan(data);
end

%% Plot data
try
    dates = datenum(data.Properties.RowNames);
    badDates = false;
catch  % Not really a cbd table
    badDates = true;
    dates = 1:height(data);
end

if isempty(opts.AxHandle)
    h1 = figure;
    h1.Color = [1 1 1];
    ax1 = gca;
else
    ax1 = opts.AxHandle;
end

hold on;

for iSer = 1:width(data)
    if iSer <= length(opts.Colors) && ~isempty(opts.Colors{iSer})
        plot(dates, data{:,iSer}, 'Color', opts.Colors{iSer});
    else
        plot(dates, data{:,iSer});
    end
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

if ~isempty(opts.Labels)
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
        otherwise
            error('Bad legend position.');
    end
    cbd.private.legendflex(opts.Labels, 'ref', gca, 'anchor', anc, 'buffer', buff);
end

if ~badDates
    ax1.XLim = [dates(1) dates(end)];
    datetick('x', 'keeplimits');
else
    labels = 6;
    labelGap = floor(height(data)/labels);
    ax1.XTick = 1:labelGap:height(data);
    ax1.XTickLabel = data.Properties.RowNames(1:labelGap:height(data));
    ax1.XLim = [dates(1) dates(end)];
end

