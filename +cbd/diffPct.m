function pChange = diffPct(data, nPer)
% DIFFPCT Returns the percent-differenced version of a data series
%
% pChange = DIFFPCT(data) returns the first percent-difference of the data
%
% pChange = DIFFPCT(data, nPer) returns the nPer percent-difference of the data

% David Kelley, 2015

%% Check inputs
% if istable(data)
% %     validateattributes(data, {'table'}, {'column'});
%     rNames = data.Properties.RowNames;
%     vName = data.Properties.VariableNames{1};
%     returnTab = true;
%     data = data{:,:};
% else
% %     validateattributes(data, {'numeric'}, {'column'});
%     returnTab = false;
% end

[data, rNames, vNames] = cbd.private.inputCBDdata(data);
nVar = size(data, 2);

% validateattributes(data, {'numeric'}, {'column'});
if nargin < 2
    nPer = 1;
end
validateattributes(nPer, {'numeric'}, {'scalar', 'integer'}); 

%% Diff
pChange = 100 * (data ./ cbd.lag(data, nPer) - 1);

% if returnTab
    varNames = cellfun(@horzcat, repmat({['diffPct' num2str(nPer)]}, 1, nVar), vNames, 'UniformOutput', false);
    pChange = array2table(pChange, 'RowNames', rNames, 'VariableNames', varNames);
% end

end
