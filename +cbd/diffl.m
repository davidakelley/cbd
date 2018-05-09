function lDiffed = diffl(data, nPer)
% DIFFL Returns the log-differenced version of a data series
%
% lDiffed = DIFFL(data) returns the first log-difference of the data
%
% lDiffed = DIFFL(data, nPer) returns the nPer log-difference of the data

% David Kelley, 2014


%% Check inputs
if istable(data)
    %validateattributes(data, {'table'}, {'column'});
    rNames = data.Properties.RowNames;
    vName = data.Properties.VariableNames;
    returnTab = true;
    data = data{:,:};
else
    %validateattributes(data, {'numeric'}, {'column'});
    returnTab = false;
end
nVar = size(data, 2);

if nargin < 2
    nPer = 1;
end
validateattributes(nPer, {'numeric'}, {'scalar', 'integer'}); 

%% Diff
lDiffed = 100 * (log(data) - cbd.lag(log(data), nPer));

if returnTab
    varNames = cellfun(@horzcat, repmat({['diffl' num2str(nPer)]}, 1, nVar), vName, 'UniformOutput', false);
    lDiffed = array2table(lDiffed, 'RowNames', rNames, 'VariableNames', varNames);
end

end