function divided = ratio(numerTab, denomTab)
%RATIO creates a ratio out of two data series
%
% divided = RATIO(tab) takes a two column table and divides the first
% series by the second series. 
%
% divided = RATIO(numerTab, denomTab) takes the ratio of numerTab over
% denomTab. Each must be a table with only one series.

% David Kelley, 2014

%% Check inputs
if nargin == 1
    mTab = numerTab;
    validateattributes(mTab, {'table'}, {'ncols', 2});
    cnames = mTab.Properties.VariableNames;
    [nName, dName] = deal(cnames{:});
else
    validateattributes(numerTab, {'table'}, {'ncols', 1});
    validateattributes(denomTab, {'table'}, {'ncols', 1});
    nName = numerTab.Properties.VariableNames{1};
    dName = denomTab.Properties.VariableNames{1};
    mTab = cbd.merge(numerTab, denomTab);
end

%% Divide
divided = array2table(mTab.(nName) ./ mTab.(dName), ...
    'RowNames', mTab.Properties.RowNames, 'VariableNames', {[nName '_' dName]});
