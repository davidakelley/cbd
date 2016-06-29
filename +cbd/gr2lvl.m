function series = gr2lvl(series, initLevel)
%GR2LVL Takes a series of growth rates and an initial level and computes
%the level over the period

% David Kelley, 2015

%% Add back levels off of growth rates

startInd = find(~isnan(series{:,1}), 1, 'first');

if startInd == 1
  firstInd = 1;
else
  firstInd = startInd - 1;
end

series{firstInd,1} = 0;
cumGr = cumprod((series{firstInd:end, 1} ./ 100) + 1);
series{firstInd:end,1} = initLevel .* cumGr;