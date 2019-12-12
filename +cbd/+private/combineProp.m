function props = combineProp(fnName, varargin)
%COMBINEPROP creates a new structure of data properties from a function of series
%
% INPUTS:
%   fnName      ~ char, the name of the function execited
%   varargin    ~ cell, list of the props structures used in the function
%
% OUTPUTS:
%   props       ~ struct, the properties combined for the new series
%
% David Kelley, 2015

props = struct;
props.func = fnName;
props.series = varargin;

end % function