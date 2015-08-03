function added = division(dataA, dataB, varargin)
% Find the quotient of two 

% David Kelley, 2014

added = cbd.private.multiseriesFunction(dataA, dataB, @(x,y) rdivide(x,y));

end