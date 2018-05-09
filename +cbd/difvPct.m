function pChange = difvPct(data, nPer)
% DIFVPCT Returns the average percent-difference of a series
%
% pChange = DIFVPCT(data) returns the first percent-difference of the data
%
% pChange = DIFVPCT(data, nPer) returns the nPer average percent-difference of the data

% David Kelley, 2015

%% Check inputs
if istable(data)
    validateattributes(data, {'table'}, {'column'});
    rNames = data.Properties.RowNames;
    vName = data.Properties.VariableNames{1};
    returnTab = true;
    data = data{:,:};
else
    validateattributes(data, {'numeric'}, {'column'});
    returnTab = false;
end


validateattributes(data, {'numeric'}, {'column'});
if nargin < 2
    nPer = 1;
end
validateattributes(nPer, {'numeric'}, {'scalar', 'integer'}); 

%% Diff
pChange = 100 * ((data ./ cbd.lag(data, nPer)).^(1/nPer) - 1);

if returnTab
    pChange = array2table(pChange, 'RowNames', rNames, 'VariableNames', {['diffPct' num2str(nPer) vName]});
end

end
