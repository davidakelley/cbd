function outData = bfdiff(series, backfillLevels)
% BFDIFF Extends a series backward by using the differences in another series
%
% outData = BFDIFF(series, backfillLevels) extends SERIES as far back as
% backfillLevels goes by usng the differences of that series.

% David Kelley, 2018

%% Add back levels off of growth rates
mergeData = cbd.merge(series, backfillLevels);
back_data = mergeData{:,end};
back_diff = [nan; back_data(2:end) - back_data(1:end-1)];

outData = mergeData(:,1:end-1);

for iSer = 1:size(outData, 2)
    iData = outData{:,iSer};
    firstLev = find(~isnan(iData), 1, 'first');
    
    for iLvl = firstLev-1:-1:1
        iData(iLvl) = iData(iLvl+1) - back_diff(iLvl+1);
    end
    
    outData{:,iSer} = iData;
end
