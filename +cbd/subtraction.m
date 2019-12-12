function subtrated = subtraction(dataA, dataB, varargin)
%SUBTRACTION Finds the difference of two series
% 
% USAGE:
% subtrated = subtraction(seriesA, seriesB) subtracts seriesB from seriesA.
% subtrated = subtraction(series, constant) subtracts a constant from a series. 
% subtrated = subtraction(constant, series) subtracts a series from a constant.
% subtrated = subtraction(constantA, constantB) subtracts constantA from constantB.
%
% David Kelley, 2014

subtrated = cbd.private.multiseriesFunction(...
    dataA, dataB, @(x,y) minus(x,y), varargin{:});

end % function