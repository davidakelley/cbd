function added = addition(dataA, dataB, varargin)
%ADDITION Finds the sum of two series
% 
% USAGE:
% added = ADDITION(seriesA, seriesB) find the sum of seriesA and seriesB. 
% added = ADDITION(series, constant) adds a constant to the series.
% added = ADDITION(constant, series) adds a constant to the series.
% added = ADDITION(constantA, constantB) adds the two constants together.
%
% David Kelley, 2014

added = cbd.private.multiseriesFunction( ...
    dataA, dataB, @(x,y) plus(x,y), varargin{:});

end % function