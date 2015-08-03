function difved = difv(data, nPer)
%DIFV Returns the average difference of a series
%
% difved = DIFV(data) returns the first difference of the data
%
% difved = DIFV(data, nPer) returns the nPer average difference of the data

% David Kelley, 2015


%% Check inputs
[data, rNames, vNames] = cbd.private.inputCBDdata(data);
nVar = size(data, 2);

if nargin < 2
    nPer = 1;
end
validateattributes(nPer, {'numeric'}, {'scalar', 'integer'}); 

%% Diff
difved = (data - cbd.lag(data, nPer)) ./ nPer;

varNames = cellfun(@horzcat, repmat({['diff' num2str(nPer)]}, 1, nVar), vNames, 'UniformOutput', false);
difved = array2table(difved, 'RowNames', rNames, 'VariableNames', varNames);

end
