function outData = ld2lvl(series, initLevel)
% LD2LVL Takes a series of log fist differences and an initial level and 
% creates a series of levels. 
%
% data = LD2LVL(series, initialLevel) constructs a level series from the 
%   log-difference data in series and an initial level in initialLevel.

% David Kelley, 2015

%% Add back levels off of growth rates
mergeData = cbd.merge(series, initLevel);
startInd = find(~isnan(mergeData{:,1}), 1, 'first');
if startInd == 1
  startInd = 2;
end

assert(~isnan(mergeData{startInd-1, end}), ...
  'Initial level not avaliable for date before log-differences.');

outData = mergeData(:,1:end-1);

for iSer = 1:size(outData, 2)
    grData = mergeData{:,iSer};
    level = nan(size(grData));
    level(startInd-1) = log(mergeData{startInd-1, end});
    level(startInd:end) = cumsum(grData(startInd:end)) + level(startInd-1);
    outData{:,iSer} = exp(level);
end
