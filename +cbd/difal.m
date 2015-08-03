function lDiffed = difal(data, nPer)
%DIFAL Returns the log-differenced version of a data series
%
% lDiffed = DIFAL(data) returns the first difference of the data
%
% lDiffed = DIFAL(data, nPer) returns the nPer difference of the data

% David Kelley, 2014


%% Check inputs
validateattributes(data, {'table'}, {'column'});
rNames = data.Properties.RowNames;
dates = datenum(rNames);
vName = data.Properties.VariableNames;
returnTab = true;
data = data{:,:};

nVar = size(data, 2);

if nargin < 2
    nPer = 1;
end
validateattributes(nPer, {'numeric'}, {'scalar', 'integer'}); 

%% Diff
[~, pers] = cbd.private.getFreq(dates);

lDiffed = 100 * (log(data) - cbd.lag(log(data), nPer)) * (pers/nPer);

if returnTab
    varNames = cellfun(@horzcat, repmat({['diffl' num2str(nPer)]}, 1, nVar), vName, 'UniformOutput', false);
    lDiffed = array2table(lDiffed, 'RowNames', rNames, 'VariableNames', varNames);
end

end