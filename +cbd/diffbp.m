function diffed = diffbp(data, nPer)
% DIFF Returns the differenced version of a data series
%
% diffed = DIFF(data) returns the first difference of the data
%
% diffed = DIFF(data, nPer) returns the nPer difference of the data

% David Kelley, 2014


%% Check inputs
[data, rNames, vNames] = cbd.private.inputCBDdata(data);
nVar = size(data, 2);

if nargin < 2
    nPer = 1;
end
validateattributes(nPer, {'numeric'}, {'scalar', 'integer'}); 

%% Diff
diffed = 100 * (data - cbd.lag(data, nPer));

varNames = cellfun(@horzcat, repmat({['diff' num2str(nPer)]}, 1, nVar), vNames, 'UniformOutput', false);
diffed = array2table(diffed, 'RowNames', rNames, 'VariableNames', varNames);

end
