function outData = bflvl(series, backfillLevels)
% BFLVL Extends a series backward by using the level of another series

% outData = BFLVL(series, backfillLevels) extends SERIES as far back as
% backfillLevels goes by usng the level of that series.

% David Kelley, 2015

%% Add back levels off of growth rates
mergeData = cbd.merge(series, backfillLevels);
back_data = mergeData{:,end};

outData = mergeData(:,1:end-1);

for iSer = 1:size(outData, 2)
    iData = outData{:,iSer};
    firstLev = find(~isnan(iData), 1, 'first');
    
    outData{1:firstLev-1,iSer} = back_data(1:firstLev-1);
end
