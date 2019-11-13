function [index, fname] = loadIndex()
%LOADINDEX opens the index file of the CHIDATA directory
%
% OUTPUTS:
%   index       ~ table, the index of the CHIDATA directory
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
index = readtable(fname);

% Check the names of the variables in the index
varNames = {'Series', 'Section'};
assert(isequal(varNames, index.Properties.VariableNames), ...
    'chidata:loadIndex:badHeaders', ...
    'Index file "%s" does not contain correct variables names', ...
    fname);

end % function