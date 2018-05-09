function outData = ffdiff(series, backfillLevels)
% FFDIFF Extends a series forward by using the differences in another series
%
% outData = FFDIFF(series, fillLevels) extends SERIES as far forward as
% fillLevels goes by usng the differences of that series.

% David Kelley, 2018

%% Add back levels off of growth rates
mergeData = cbd.merge(series, backfillLevels);
back_data = mergeData{:,end};
fwd_diff = [nan; back_data(2:end) - back_data(1:end-1)];

outData = mergeData(:,1:end-1);

for iSer = 1:size(outData, 2)
    iData = outData{:,iSer};
    lastLev = find(~isnan(iData), 1, 'last');
    
    for iLvl = lastLev+1:size(iData, 1)
        iData(iLvl) = iData(iLvl-1) + fwd_diff(iLvl);
    end
    
    outData{:,iSer} = iData;
end
