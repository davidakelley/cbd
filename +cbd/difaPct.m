function pChange = difaPct(data, nPer)
%DIFAPCT Returns the annualized differenced of a data series
%
% pChange = DIFAPCT(data) returns the first difference of the data
%
% pChange = DIFAPCT(data, nPer) returns the nPer difference of the data

% David Kelley, 2014


%% Check inputs
validateattributes(data, {'table'}, {'2d'});
rNames = data.Properties.RowNames;
vName = data.Properties.VariableNames;
data = data{:,:};
dates = datenum(rNames);
validateattributes(dates, {'numeric'}, {'column'});
nVar = size(data, 2);

if nargin < 2
    nPer = 1;
end
validateattributes(nPer, {'numeric'}, {'scalar', 'integer'}); 

%% Diff
[~, pers] = cbd.private.getFreq(dates);

pChange = 100 * ((data ./ cbd.lag(data, nPer)) .^ (pers/nPer) - 1);

varNames = cellfun(@horzcat, repmat({['difaPct' num2str(nPer)]}, 1, nVar), vName, 'UniformOutput', false);
pChange = array2table(pChange, 'RowNames', rNames, 'VariableNames', varNames);


end
