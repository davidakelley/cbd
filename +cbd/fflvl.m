function outData = fflvl(series, fillLevels)
%FFLVL Extends a series forward by using the level of another series

% outData = fflvl(series, fillLevels) extends SERIES forward with 
% fillLevels by usng the level of that series.

% David Kelley, 2015

%% Add levels 
mergeData = cbd.merge(series, fillLevels);
back_data = mergeData{:,end};

outData = mergeData(:,1:end-1);

for iSer = 1:size(outData, 2)
    iData = outData{:,iSer};
    firstLev = find(~isnan(iData), 1, 'first');
    
    outData{1:firstLev-1,iSer} = back_data(1:firstLev-1);
end
