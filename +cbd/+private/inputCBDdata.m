function [data, rNames, vNames] = inputCBDdata(data)
%INPUTCBDDATA takes apart a cbd table into its components

validateattributes(data, {'table'}, {'2d'});

rNames = data.Properties.RowNames;
vNames = data.Properties.VariableNames;
data = data{:, :};

end % function