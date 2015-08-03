function outData = ld2llvl(series, initLevel)
%LD2LLVL Takes a series of log fist differences and a series of
%levels and creates a realtime series of log levels 

% David Kelley, 2015

%% Add back levels off of growth rates
mergeData = cbd.merge(series, initLevel);
startInd = find(~isnan(mergeData{:,1}), 1, 'first');
assert(~isnan(mergeData{startInd-1, end}), 'Initial level not avaliable for date before log-differences.');

outData = mergeData(:,1:end-1);

for iSer = 1:size(outData, 2)
    grData = mergeData{:,iSer};
    level = nan(size(grData));
    level(startInd-1) = log(mergeData{startInd-1, end});
    level(startInd:end) = cumsum(grData(startInd:end)) + level(startInd-1);
    outData{:,iSer} = level;
end
