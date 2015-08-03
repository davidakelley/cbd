function added = subtraction(dataA, dataB, varargin)
% Find the difference of two series

% David Kelley, 2014

added = cbd.private.multiseriesFunction(dataA, dataB, @(x,y) minus(x,y));

end