function [data, rNames, vNames] = inputCBDdata(data)
%INPUTCBDDATA takes

validateattributes(data, {'table'}, {'2d'}); 

rNames = data.Properties.RowNames;
vNames = data.Properties.VariableNames;
data = data{:,:};