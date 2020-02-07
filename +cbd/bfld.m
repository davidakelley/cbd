function outData = bfld(series, backfillLogDiffs)
% BFLD Extends a series backward by using log-differences of another series
%
% outData = BFLD(series, backfillLogDiffs) extends SERIES as far back as
% backfillLogDiffs goes by using those log-differences.

% David Kelley, 2018

%% Add back levels off of growth rates
mergeData = cbd.merge(series, backfillLogDiffs);
outData = mergeData(:,1:end-1);

% We have a series of levels. We want to take the log of them, append the backfilling
% log-differences on the beginning of that series, take the cumulative sum, adjust that
% series so that it hits the log-level series we started with, then exponentiate. 
for iSer = 1:size(outData, 2)
  lvlData = mergeData{:,iSer};

  startInd = find(~isnan(lvlData), 1, 'first');
  if startInd == 1
    startInd = 2;
  end
  logLvl = reallog(lvlData(startInd:end));
  logDiff = logLvl(2:end) - logLvl(1:end-1);
  
  logDiffFull = nan(size(lvlData));
  logDiffFull(startInd+1:end) = logDiff;
  logDiffFull(1:startInd) = mergeData{1:startInd,end};
  
  logLvlFull = cumsum(logDiffFull);
  % Compute the adjustment term so that the first log-level of the series matches the
  % input
  adjTerm = logLvl(1) - logLvlFull(startInd);
  logLvlFullAdj = logLvlFull + adjTerm;
  
  outData{:,iSer} = exp(logLvlFullAdj);
end
