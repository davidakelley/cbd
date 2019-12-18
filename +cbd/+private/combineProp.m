function props = combineProp(fnHandle, varargin)
%COMBINEPROP creates the data properties from functions and its series
%
% INPUTS:
%   fnHandle    ~ function_handle, the handle of the function executed
%   varargin    ~ cell, list of the props structures used in the function
%
% OUTPUTS:
%   props       ~ struct, the properties combined for the new series
%
% David Kelley, 2015

props = struct();
props.func = fnHandle;
props.series = varargin;

end % function