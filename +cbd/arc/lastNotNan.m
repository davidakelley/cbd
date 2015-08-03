function [lastVals,endInd]  = last(data)
%LASTNOTNAN Pulls the last non-nan value from a vector
%
% lastVals = LASTNOTNAN(data) returns the last non-nan value of each series
% in the data. A row of data is returned for each observation that is the
% last occurance of a series.
%
% [lastVals, endInd] = LASTNOTNAN(...) also returns the index of the
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

%validateattributes(vector, {'numeric'}, {'vector'});
endInd = nan(1, nVar);
for iVar = 1:nVar
    endInd(iVar) = find(~isnan(data(:, iVar)), 1, 'last');
end
returnInds = unique(endInd);
lastVals = data(returnInds, :);

if returnTab
    lastVals = array2table(lastVals, 'RowNames', rNames(returnInds), 'VariableNames', vName);
end
