function lagged = lag(data, nPer)
%LAG Shifts a data series by a given number of periods
%
% laggged = lag(data) lags data by 1 period. data can be either a
% numeric vector or a table.
%
% laggged = lag(data, nPer) lags data by nPer periods. data can be either a
% numeric vector or a table.

% David Kelley, 2014

%% Check inputs
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
    nPer = 1;
end
validateattributes(nPer, {'numeric'}, {'scalar', 'integer'}); 

%% Lag
if nPer > 0
    lagged = [nan(nPer, nVar); data(1:end-nPer, :);];
elseif nPer < 0
    nPer = -nPer;
    lagged = [data(nPer+1:end,:); nan(nPer, nVar)];
else
    lagged = data;
end

if returnTab
    varNames = cellfun(@horzcat, repmat({['L' num2str(nPer)]}, 1, nVar), vName, 'UniformOutput', false);
    lagged = array2table(lagged, 'RowNames', rNames, 'VariableNames', varNames);
end

end