function added = addition(dataA, dataB, varargin)
% Find the sum of two series

% David Kelley, 2014

added = cbd.private.multiseriesFunction(dataA, dataB, @(x,y) plus(x,y), varargin{:});

end