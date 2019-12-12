function [data, dataProp] = data(series, varargin)
%DATA gets data series from BLOOMBERG, CHIDATA, FRED, and HAVER
% 
% For the documentation of this function, see CBD.EXPRESSION
%
% David Kelley, 2014-2015

% Call expression function
[data, dataProp] = cbd.expression(series, varargin{:});

end


