function datenum = datelast(data, lastInd)
% Returns the datenum of the last date in a series. 

% David Kelley, 2016

if nargin == 1 
  lastVals = cbd.last(data);
else
  lastVals = cbd.last(data, lastInd);
end
  
datenum = lastVals.Properties.RowNames{1};