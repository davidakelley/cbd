function divided = division(dataA, dataB, varargin)
%DIVISION Finds the quotient of two series. 
% 
% USAGE:
% divided = DIVISION(seriesA, seriesB) divides seriesA by seriesB 
% divided = DIVISION(series, constant) divides a series by a constant
% divided = DIVISION(constant, series) divides a constant by a series
% divided = DIVISION(constantA, constantB) divides constantA by constantB
%
% David Kelley, 2014

divided = cbd.private.multiseriesFunction( ...
    dataA, dataB, @(x,y) rdivide(x,y), varargin{:});

end % function