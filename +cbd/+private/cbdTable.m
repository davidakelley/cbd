function data = cbdTable(values, dates, varNames, sortVars)
%CBDTABLE creates CBD data table from values, dates, and variable names
%
% INPUTS:
%   values      ~ double, an array of the values in the table
%   dates       ~ double, the datenums for each observations as an array
%   varNames    ~ cell, the names of the series in the table
%   sortVars    ~ logical, whether to sorted the variables at the end
%
% OUTPUTS:
%   data    ~ table, the cbd-style table of the data
%
% David Kelley, 2015
% Santiago Sordo-Palacios, 2019

% Check the names of the series are a cell array
assert(iscell(varNames), ...
    'cbdTable:varNamesNotCell', ...
    'The varNames argument is not a cell array');

% Return an empty table if values are empty
if isempty(values)
    data = table([], ...
        'VariableNames', varNames);
    return
end

% Check the values and dates are both numeric
assert(isnumeric(values), ...
    'cbdTable:valuesNotNumeric', ...
    'The values argument is not an array of doubles');
assert(isnumeric(dates), ...
    'cbdTable:datesNotNumeric', ...
    'The dates argument is not an array of datenums');
assert(issorted(dates), ...
    'cbdTable:datesNotSorted', ...
    'The date array argument are not sorted');

% Check the sizes of series names and values
seriesFromValues = size(values, 2);
seriesFromNames = size(varNames, 2);
assert(seriesFromValues == seriesFromNames, ...
    'cbdTable:valuesSeriesMismatch', ...
    'Argument values has %0.f series while names has %0.f ', ...
    seriesFromValues, seriesFromNames);

% Check the sizes of values and dates
obsFromValues = size(values, 1);
obsFromDates = size(dates, 1);
assert(obsFromValues == obsFromDates, ...
    'cbdTable:valuesDatesMismatch', ...
    'Argument values has %0.f observations while dates has %0.f', ...
    obsFromValues, obsFromDates);

% Create the cbd table
rowNames = cellstr(cbd.private.mdatestr(dates));
data = array2table(values, ...
    'VariableNames', varNames, ...
    'RowNames', rowNames);

% Sort the variables
if nargin == 4 && sortVars
    sortedNames = sort(data.Properties.VariableNames);
    data = data(:, sortedNames);
end % if-nargin

% Save the datenum's to UserData
data.Properties.UserData.dates = dates;

end % function