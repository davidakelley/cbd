function data = gen(value, freq, varargin)
% GEN Generates a time series from scalar values. Input scalar values can be
% either numeric of single-row tables. Specify a frequency for the final
% series and optionally add startDate and endDate values. 
% 
% data = GEN(value, freq) generates a constant series with all values equal to 
% 	value from 1921 to present.
% 
% data = GEN(..., 'startDate', sDate) starts the constant series at sDate.
% 
% data = GEN(..., 'endDate', eDate) ends the constant series at eDate.

% David Kelley & Jon Yu, 2016

inP = inputParser;
dateValid = @(x) validateattributes(x, {'numeric', 'char'}, {'vector'});
inP.addParameter('startDate', '1/1/1921', dateValid);
inP.addParameter('endDate', cbd.private.endOfPer(now, 'A'), dateValid);

inP.parse(varargin{:});
opts = inP.Results;

if istable(value)
  assert(size(value, 1) == 1, 'Table inputs must have only 1 row.');
  value = value{:,:};
end

datenum = cbd.private.genDates(opts.startDate, opts.endDate, freq);
dates = cellstr(datestr(datenum));

values = repmat(value, [size(dates, 1) 1]);
vNames = arrayfun(@(x) ['C' strrep(num2str(x), '.', '_')], value, 'Uniform', false);

data = array2table(values, 'RowNames', dates, 'VariableNames', vNames);

end