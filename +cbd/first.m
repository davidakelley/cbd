function [firstVals,beginInd]  = first(data, firstInd)
%FIRST Pulls the first non-nan value from a vector
%
% firstVals = FIRST(data) returns the first non-nan value of each series
% in the data. A row of data is returned for each observation that is the
% last occurance of a series.
%
% firstVals = FIRST(data, numVals) returns the first numVals values 
% of the data 
%
% [firstVals, firstInd] = FIRST(...) also returns the index of the
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
    firstInd = 1;
end

%validateattributes(vector, {'numeric'}, {'vector'});
beginInd = nan(1, nVar);
for iVar = 1:nVar
    foundInds = find(~isnan(data(:, iVar)), firstInd, 'first');
    if isempty(foundInds)
        beginInd(iVar) = nan;
    else
        beginInd(iVar) = foundInds(1);
    end
end
returnInds = unique(beginInd);
returnInds(isnan(returnInds)) = [];
firstVals = data(returnInds, :);

if returnTab
    firstVals = array2table(firstVals, 'RowNames', rNames(returnInds), 'VariableNames', vName);
end
