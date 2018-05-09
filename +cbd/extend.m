function outTable = extend(inTable, varargin)
% EXTEND Ensures data extends to at least startDate or endDate
%
% extendedData = EXTEND(inTable, 'startDate', sDate) extends the data back
% with nans if it doesn't already go back to startDate.
%
% extendedData = EXTEND(inTable, 'endDate', eDate) extends the data forward
% with nans if it doesn't already go to endDate.
%
% See also: extend_last

% David Kelley, 2016

%% Handle inputs
firstDate = datenum(inTable.Properties.RowNames{1});
lastDate = datenum(inTable.Properties.RowNames{end});

inP = inputParser;
dateValid = @(x) validateattributes(x, {'numeric', 'char'}, {'vector'});
inP.addParameter('startDate', firstDate, dateValid);
inP.addParameter('endDate', lastDate, dateValid);
inP.addParameter('startCount', 0, @isnumeric);
inP.addParameter('endCount', 0, @isnumeric);

inP.parse(varargin{:});
opts = inP.Results;

if ~any(strcmpi('startDate', inP.UsingDefaults)) && ~any(strcmpi('startCount', inP.UsingDefaults))
  error('Cannot specify both a startDate and a startCount.');
end
if ~any(strcmpi('endDate', inP.UsingDefaults)) && ~any(strcmpi('endCount', inP.UsingDefaults))
  error('Cannot specify both an endDate and an endCount.');
end

% Make dates into datenums
if ~isnumeric(opts.startDate)
  startDate = datenum(opts.startDate);
else
  startDate = opts.startDate;
end
if ~isnumeric(opts.endDate)
  endDate = datenum(opts.endDate);
else
  endDate = opts.endDate;
end

%% Find appropriate end dates
[serFrq, serPers] = cbd.private.getFreq(inTable);

startDate = startDate - opts.startCount * (365/serPers);
endDate = endDate + opts.endCount * (365/serPers);
datenumList = cbd.private.genDates(startDate, endDate, serFrq);

%% Create table with new dates
newDates = cellstr(datestr(datenumList));
newDateTab = array2table(nan(size(newDates)), 'RowNames', newDates);

newTab = cbd.merge(inTable, newDateTab);

outTable = newTab(:,1:size(inTable, 2));

