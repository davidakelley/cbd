function extended = extend_last(data)
%EXTEND_LAST Extends the data series 
%
% extended = EXTEND_LAST(data) copies the last value through to
% the end of the series if nan values are present.

% David Kelley, 2015

[lastVal, lastInd] = cbd.last(data);

extended = data;
extended{lastInd+1:end,:} = lastVal{1,1};