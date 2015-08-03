function inTable = trim(inTable, varargin)
% TRIM Returns data between given a startDate or endDate
%
% trimmedData = trim(inTable, 'startDate', sDate) returns the data 
% following the start date
%
% trimmedData = trim(inTable, 'endDate', eDate) returns the data 
% preceeding the end date

% David Kelley, 2015

%% Handle inputs
inP = inputParser;
dateValid = @(x) validateattributes(x, {'numeric', 'char'}, {'vector'});
inP.addParameter('startDate', [], dateValid);
inP.addParameter('endDate', [], dateValid);

inP.parse(varargin{:});
opts = inP.Results;

if ~isempty(opts.startDate)
    if ~isnumeric(opts.startDate)
        opts.startDate = datenum(opts.startDate);
    end
    dates = datenum(inTable.Properties.RowNames);
    inTable = inTable(dates >= opts.startDate, :);
end

if ~isempty(opts.endDate)
    if ~isnumeric(opts.endDate)
        opts.endDate = datenum(opts.endDate);
    end
    dates = datenum(inTable.Properties.RowNames);
    inTable = inTable(dates <= opts.endDate, :);
end