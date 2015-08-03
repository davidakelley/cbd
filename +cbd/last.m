function [lastVals,endInd] = last(data, lastInd)
%LAST Pulls the last non-nan value from a vector
%
% lastVals = LAST(data) returns the last non-nan value of each series
% in the data. A row of data is returned for each observation that is the
% last occurance of a series.
%
% lastVals = LAST(data, numVals) returns the last numVals values 
% of the data 
%
% [lastVals, endInd] = LAST(...) also returns the index of the
% original data.

% David Kelley, 2014

if istable(data)
    validateattributes(data, {'table'}, {'2d'});
    rNames = data.Properties.RowNames;
    vName = data.Properties.VariableNames;
    returnTab = true;
    data = data{:,:};
else
    validateattributes(data, {'numeric'}, {'2d'});
    returnTab = false;
end
nVar = size(data, 2);

if nargin < 2
    lastInd = 1;
end

endInd = nan(1, nVar);
for iVar = 1:nVar
    foundInds = find(~isnan(data(:, iVar)), lastInd, 'last');
    endInd(iVar) = foundInds(1);
end
returnInds = unique(endInd);
lastVals = data(returnInds, :);

if returnTab
    lastVals = array2table(lastVals, 'RowNames', rNames(returnInds), 'VariableNames', vName);
end
