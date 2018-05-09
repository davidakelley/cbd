function rho = corr(tabA, tabB)
% CORR Finds the correlation between data series
%
% rho = CORR(tabA) finds the correlation matrix of all variables in a table
%
% rho = CORR(tabA, tabB) finds the correlations between the variables in
% tabA and the variable in tabB

% David Kelley, 2014

%% Check inputs
if nargin == 1
    validateattributes(tabA, {'table'}, {'2d'});
    tab2offset = 0;
    nVarA = size(tabA,2);
    nVarB = nVarA;
    data = tabA;
else
    validateattributes(tabA, {'table'}, {'2d'});
    validateattributes(tabB, {'table'}, {'2d'});
    tab2offset = size(tabA, 2);
    nVarA = size(tabA,2);
    nVarB = size(tabB,2);
    data = cbd.merge(tabA, tabB);
end

%% Compute correlations
rho = nan(nVarA, nVarB);

for iaVar = 1:nVarA
    for ibVar = 1:nVarB
        iData = [data.(iaVar) data.(tab2offset+ibVar)];
        keepInd = all(~isnan(iData), 2);
        iData = iData(keepInd, :);
        try
            rawRho = corr(iData);
            rho(iaVar, ibVar) = rawRho(2, 1);
        catch
            rho(iaVar, ibVar) = nan;
        end
    end
end
