function newTab = rename(table, newNames)
%RENAME renames the table variables
%
% David Kelley, 2014

% Check inputs
validateattributes(table, {'table'}, {'2d'});
validateattributes(newNames, {'cell'}, {'size', [1, width(table)]});

% Rename the variables
newTab = table;
newTab.Properties.VariableNames = newNames;

end % function