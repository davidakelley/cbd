function inTable = trim(inTable, varargin)
% TRIM Returns data between given a startDate or endDate
%
% trimmedData = TRIM(inTable, 'startDate', sDate) returns the data
% following the start date
%
% trimmedData = TRIM(inTable, 'endDate', eDate) returns the data
% preceeding the end date
%
% trimmedData = TRIM(inTable, 'Inclusive', true, ...) returns the smallest
% data range which includes the start and end dates passed.

% David Kelley, 2015

%% Handle inputs
firstDate = datenum(inTable.Properties.RowNames{1});
lastDate = datenum(inTable.Properties.RowNames{end});

inP = inputParser;
dateValid = @(x) validateattributes(x, {'numeric', 'char'}, {'vector'});
inP.addParameter('startDate', firstDate, dateValid);
inP.addParameter('endDate', lastDate, dateValid);
inP.addParameter('Inclusive', false, @islogical);

inP.parse(varargin{:});
opts = inP.Results;

if ~isnumeric(opts.startDate)
  opts.startDate = datenum(opts.startDate);
end

if ~isnumeric(opts.endDate)
  opts.endDate = datenum(opts.endDate);
end

dates = datenum(inTable.Properties.RowNames);
if ~opts.Inclusive
  % Get dates starting at or after startDate and before or on endDate
  sInd = find(dates < opts.startDate, 1, 'last') + 1;
  eInd = find(dates > opts.endDate, 1, 'first')  - 1;
else
  % Get range that includes startDate and endDate
  sInd = find(dates <= opts.startDate, 1, 'last');
  eInd = find(dates >= opts.endDate, 1, 'first');
end

sInd(sInd > size(dates,1)) = size(dates,1);
eInd(eInd < 1) = 1;
eInd(isempty(eInd)) = size(dates,1);
sInd(isempty(sInd)) = 1;

dates = cbd.private.tableDates(inTable);
inTable = inTable(sInd:eInd,:);
inTable.Properties.UserData = dates(sInd:eInd,:);



