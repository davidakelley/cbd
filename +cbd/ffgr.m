function outData = ffgr(series, backfillLevels)
%FFGR Extends a series forward by using the growth rate of another series
%
% outData = ffgr(series, fillLevels) extends SERIES as far forward as
% fillLevels goes by usng the growth rate of that series.

% David Kelley, 2015

%% Add back levels off of growth rates
mergeData = cbd.merge(series, backfillLevels);
back_data = mergeData{:,end};
fwd_gr = [nan; back_data(2:end)./back_data(1:end-1)];

outData = mergeData(:,1:end-1);

for iSer = 1:size(outData, 2)
    iData = outData{:,iSer};
    firstLev = find(~isnan(iData), 1, 'first');
    
    for iLvl = firstLev-1:-1:1
        iData(iLvl) = iData(iLvl+1) / fwd_gr(iLvl+1);
    end
    
    outData{:,iSer} = iData;
end
