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
hasBadHeaders = ~isequal(varNames, indexTable.Properties.VariableNames);
assert(~hasBadHeaders, ...
    'chidata:loadIndex:badHeaders', ...
    'Index file "%s" does not contain correct variable names', ...
    fname);

% Check for empty series columns
emptySeries = all(cellfun(@isempty, indexTable.Series));
assert(~emptySeries, ...
    'chidata:loadIndex:emptySeries', ...
    'Index file "%s" contains empty Series observations', ...
    fname);

% Check for empty section columns
emptySections = all(cellfun(@isempty, indexTable.Section));
assert(~emptySections, ...
    'chidata:loadIndex:emptySections', ...
    'Index file "%s" contains empty Section observations', ...
    fname);

% Check for duplicate series
uniqueSeries = unique(sort(indexTable.Series));
sortedSeres = sort(indexTable.Series);
duplicateSeries = ~isequal(uniqueSeries, sortedSeres);
assert(~duplicateSeries, ...
    'chidata:loadIndex:duplicateSeries', ...
    'Index file "%s" contains duplicate series entries', ...
    fname);

% Create a container for the index
index = containers.Map(indexTable.Series, indexTable.Section);

end % function