function dataProp = combineProp(fnName, varargin)
%COMBINEPROP creates a new structure of data properties from a function of series
%
% dataProp = COMBINEPROP (fnName, seriesProp...) takes the name of a function
% and a list of other dataProp structures and returns a structure of the
% properties for the new series.

% David Kelley, 2015

dataProp = struct;
dataProp.func = fnName;
dataProp.series = varargin;