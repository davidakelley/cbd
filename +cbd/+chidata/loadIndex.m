function [index, fname] = loadIndex()
%LOADINDEX opens the index file of the CHIDATA directory and performs
%error checking on the indexTable that is loaded before creating
%a container
%
% OUTPUTS:
%   index       ~ containers.Map, the index of the CHIDATA directory
%   fname       ~ char, the name of the file where the index is stored
%
% WARNING: This function should NOT be called directly by the user
%
% Santiago Sordo-Palacios, 2019

% Get the chidata directory
chidataDir = cbd.chidata.dir();

% Get the filename
fname = fullfile(chidataDir, 'index.csv');

% Check if it exists
found = isequal(exist(fname, 'file'), 2);
assert(found, ...
    'chidata:loadIndex:notFound', ...
    'Index file "%s" could not be found', fname);

% Read the index file
indexTable = readtable(fname, ...
    'Delimiter', ',', ...
    'HeaderLines', 0, ...
    'EndOfLine', '\n');
    
% Check the names of the variables in the index
varNames = {'Series', 'Section'};
correctHeaders = isequal(varNames, indexTable.Properties.VariableNames);
assert(correctHeaders, ...
    'chidata:loadIndex:badHeaders', ...
    'Index file "%s" does not have "%s" as its headers', ...
    fname, strjoin(varNames, ','));

% Return empty container if this is a new index file
emptyIndex = isequal(height(indexTable), 0);
if emptyIndex
    index = containers.Map.empty;
    return
end

% Check for empty columns, using xor to avoid cases with completely empty
emptySeries = cellfun(@isempty, indexTable.Series);
emptySections = cellfun(@isempty, indexTable.Section);
emptyCol = xor(emptySeries, emptySections);

% If there are any empty columns, error on the cases
if any(emptyCol)
    % Case when a section is defined but no series
    if any(emptySeries & emptyCol)
        sectionList = strjoin(indexTable.Section(emptySeries & emptyCol), ',');
        error('chidata:loadIndex:emptySeries', ...
            'Index file "%s" is missing Series for Sections:\n%s\n', ...
            fname, sectionList);
    end
    % Case when a series is defined but no section
    if any(emptySections & emptyCol)
        seriesList = strjoin(indexTable.Series(emptySections & emptyCol), ',');
        error('chidata:loadIndex:emptySections', ...
            'Index file "%s" is missing Sections for Series:\n%s\n', ...
            fname, seriesList);
    end 
end % if-any

% Check for duplicate series
A = sort(indexTable.Series);
N = arrayfun(@(k) sum(arrayfun(@(j) isequal(A{k}, A{j}), 1:numel(A))), 1:numel(A));
duplicateSeries = strjoin(unique(A(N>1)), ',');
assert(isempty(duplicateSeries), ...
    'chidata:loadIndex:duplicateSeries', ...
    'Index file "%s" contains duplicate Series:\n%s\n', ...
    fname, duplicateSeries);

% Replace the series with the upper case versions
series = upper(indexTable.Series);

% Create a container for the index
index = containers.Map(series, indexTable.Section);

end % function