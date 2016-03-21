function outTable = extend(inTable, varargin)
% EXTEND Ensures data extends to at least startDate or endDate
%
% extendedData = extend(inTable, 'startDate', sDate) extends the data back
% with nans if it doesn't already go back to startDate.
%
% extendedData = extend(inTable, 'endDate', eDate) extends the data forward
% with nans if it doesn't already go to endDate.

% David Kelley, 2016

%% Handle inputs
firstDate = datenum(inTable.Properties.RowNames{1});
lastDate = datenum(inTable.Properties.RowNames{end});

inP = inputParser;
dateValid = @(x) validateattributes(x, {'numeric', 'char'}, {'vector'});
inP.addParameter('startDate', firstDate, dateValid);
inP.addParameter('endDate', lastDate, dateValid);

inP.parse(varargin{:});
opts = inP.Results;

if ~isnumeric(opts.startDate)
  opts.startDate = datenum(opts.startDate);
end

if ~isnumeric(opts.endDate)
  opts.endDate = datenum(opts.endDate);
end

serFrq = cbd.private.getFreq(inTable);

newDates = cellstr(datestr(cbd.private.genDates(opts.startDate, opts.endDate, serFrq)));

newTab = cbd.merge(inTable, array2table(nan(size(newDates)), 'RowNames', newDates));

outTable = newTab(:,1:size(inTable, 2));