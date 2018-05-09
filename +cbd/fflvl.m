function outData = fflvl(series, fillLevels)
% FFLVL Extends a series forward by using the level of another series

% outData = FFLVL(series, fillLevels) extends SERIES forward with 
% fillLevels by usng the level of that series.

% David Kelley, 2015

%% Add levels 
mergeData = cbd.merge(series, fillLevels);
forward_data = mergeData{:,end};

outData = mergeData(:,1:end-1);

for iSer = 1:size(outData, 2)
    iData = outData{:,iSer};
    lastLev = find(~isnan(iData), 1, 'last');
    
    outData{lastLev+1:end,iSer} = forward_data(lastLev+1:end);
end
