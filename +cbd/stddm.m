function sdmData = stddm(data)
% STDDM Demeans and stardardizes the input data.
%
% sdmData = STDDM(data) returns the standardized and demeaned version of data.

% David Kelley, 2014

%% Check inputs
if istable(data)
    rnames = data.Properties.RowNames;
    vnames = data.Properties.VariableNames;
    tabOut = true;
    data = data{:,:};
else
    tabOut = false;
    validateattributes(data, {'numeric'}, {'2d'});
end

nRows = size(data, 1);
nCols = size(data, 2);

means = nan(1, nCols);
stds = nan(1, nCols);

for iCol = 1:nCols
    means(iCol) = mean(data(~isnan(data(:,iCol)), iCol));
    stds(iCol) = std(data(~isnan(data(:,iCol)), iCol));
end

sdmData = (data - repmat(means, nRows, 1)) ./ repmat(stds, nRows, 1);

if tabOut
   sdmData = array2table(sdmData, 'RowNames',  rnames, 'VariableNames', vnames);
end