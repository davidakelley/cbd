function [data, dataProp] = data(series, varargin)
% DATA Get data series from Haver, FRED, Bloomberg or CHIDATA databases.
%
% dataTable = cbd.DATA(seriesID) returns the data requested in seriesID 
% in a table format. seriesID can be a string or cell array of strings. 
% Each individual seriesID is a string that specifies a series mnemonic and
% optionally a database, functions of a series, or other options on how to
% retrieve the data. A full explanation of how to specify a series is
% included in the cbd documenation file.
%
% [dataTable, dataInfo] = cbd.DATA(...) also returns a cell array
% containing information on the series pulled.
%
% cbd.DATA also takes a number of optional arguments (name-value pairs):
%   dbID      - Database name used for unlabeled series (default USECON).
%               Can be any of the Haver database names, FRED, or CHIDATA.
%   startDate - Date string or datenum of first date to get data 
%               e.g., '01/01/2015' (default fetches whole series)
%   endDate   - Date string or datenum of last date to get data
%   asOf      - For FRED data, specify to pull the data as if at some date
%               in the past (using ALFRED). 
%   asOfStart - For FRED data, get all of the vintages between the
%               asOfStart date and the asOfEnd date (requires asOfEnd). 
%   asOfEnd   - For FRED data, get all of the vintages between the
%               asOfStart date and the asOfEnd date (requires asOfStart). 
%
% For more information, see the cbd documentation file.

% David Kelley, 2014-2015

% Call expression function
[data, dataProp] = cbd.expression(series, varargin{:});

end


