function added = multiplication(dataA, dataB, varargin)
% Find the product of two series

% David Kelley, 2014

added = cbd.private.multiseriesFunction(dataA, dataB, @(x,y) times(x,y));

end