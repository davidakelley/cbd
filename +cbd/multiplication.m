function multiplied = multiplication(dataA, dataB, varargin)
%MULTIPLICATION Finds the product of two series. 
% 
% USAGE:
% multiplied = MULTIPLICATION(seriesA, seriesB) find the product of seriesA and seriesB. 
% multiplied = MULTIPLICATION(series, constant) multiplies a series by a constant.
% multiplied = MULTIPLICATION(constant, series) multiplies a series by a constant.
% multiplied = MULTIPLICATION(constantA, constantB) multiplies the two constants together.
%
% David Kelley, 2014

multiplied = cbd.private.multiseriesFunction( ...
    dataA, dataB, @(x,y) times(x,y), varargin{:});

end % function