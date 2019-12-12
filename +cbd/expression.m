function [data, props] = expression(series, varargin)
%EXPRESSION evaluates a cbd expression and return a table and properties
%
% This function is the base function that handles downloading cbd data.
% It evaluates a cbd expression and returns a cbd table and properties
% A cbd expression is a string that defines a raw data series along with
% any cbd.function() transformation that should be applied to that series.
% A cbd expression can nest multiple transformation and used data passed
% to the function as '%d' to perform calculation. The cbd table is a table
% where the row names are dates in 'dd-mmm-yyyy' format, all of variables
% are doubles, and the datenum's are stored in UserData. The properties
% are a structure of the information provided by the database regarding
% the specified series.
%
% INPUTS:
%   series      ~ cell/char, the name(s) of the series requested and any
%               transformations that should be applied to those series
%
% TABLE INPUTS:
%   %d          ~ table, a table of data in cbd format which is used in the
%               expression whenever a '%d' is included
%
% NAME-VALUE PAIRS: (must be specified after any '%d' inputs)
%   dbId        ~ char, the database where the series is stored, which is
%               BLOOMBERG, CHIDATA, FRED, or any HAVER database with the
%               default being USECON.
%   startDate   ~ char/double/datetime, the start of the series where the 
%               default fetches the entire time series
%   endDate     ~ char/double/datetime, the end of the series where the 
%               default fetches the entire time series
%   aggFreq     ~ char, the frequency to aggregate the data to
%   ignoreNan   ~ logical, whether NaN's should be ignored in calculations
%               where NaN's are treated as 0's in addition and subtraction
%               and 1's in multiplication and division
%   asOf        ~ char/double/datetime, the vintage date parameter for FRED
%               as if pulling the data at some date in the past
%   asOfStart   ~ char/double/datetime, the vintage start date for FRED
%               with asOfEnd pulls all the vintages between the two
%               dates specified
%   asOfEnd     ~ char/double/datetime, the vintage end date for FRED
%               requires an asOfStart
%   frequency   ~ char, the frequency to request for Bloomberg data
%   bbfield     ~ char, the field to request for Bloomberg data found
%               see the FIELDSEARCH function for more information
%
% OUTPUTS:
%   data        ~ table, a cbd-style table of the data requested
%   props       ~ struct, the properties of the data requested
%
% USAGE:
%
%   % 2Y Treasury Yields from Haver
%   series = 'FCM2@DAILY';
%   [data, props] = cbd.expression(series); % returns data and props
%
%   % 2Y and 10Y Treasuries in a table together
%   series = {'FCM2@DAILY', 'FCM10@DAILY'};
%   data = cbd.expression(series);
%
%   % 10Y Treasury - 2Y Treasury with minus sign and # hash argument
%   series = '(FCM10 - FCM2)#dbID:"DAILY"';
%   data = cbd.expression(series);
%
%   10Y Treasury - 2Y Treasury with subtraction() call and 'dbID' argument
%   series = 'SUBTRACTION(FCM10, FCM2)';
%   data = cbd.expression(series, 'dbID', 'DAILY');
%
%   10Y Treasury - existing 2Y Treasury
%   fcm2 = cbd.expression('FCM2@DAILY');
%   series = 'FCM10@DAILY - %d';
%   data = cbd.expression(series, fcm2);
%
%   % 2Y Treasury ending on 31-Dec-2018
%   series = 'FCM2@DAILY';
%   endDate = '31-Dec-2018';
%   data = cbd.expression(series, 'endDate', endDate);
%
%   For more examples of usage, see the cbd README file
%
% David Kelley, 2014-2015
% Santiago I. Sordo-Palacios, 2019

%% Handle inputs
% Ensure that series is formatted propertly
validateattributes(series, {'cell', 'char'}, {'row'});
if ischar(series)
    series = {series};
end

% Extract the 3rd argument through the first string as input tables
firstString = find(cellfun(@ischar, varargin), 1, 'first');
if isempty(firstString)
    inTables = varargin;
    varargin = {};
else
    inTables = varargin(1:firstString-1);
    varargin = varargin(firstString:end);
end

% Set-up the input parser
inP = inputParser;
dateValid = @(x) ...
    validateattributes(x, {'numeric', 'char', 'datetime'}, {'vector'});
inP.addParameter('dbID', 'USECON', @ischar);
inP.addParameter('startDate', [], dateValid);
inP.addParameter('endDate', [], dateValid);
inP.addParameter('aggFreq', [], @ischar);
inP.addParameter('ignoreNan', false, @islogical);
inP.addParameter('asOf', [], dateValid);
inP.addParameter('asOfStart', [], dateValid);
inP.addParameter('asOfEnd', [], dateValid);
inP.addParameter('frequency', [], dateValid);
inP.addParameter('bbfield', [], @ischar);

% Parse the inputs and store them to options
inP.parse(varargin{:});
opts = inP.Results;

%% Pull each individual series
% Set-up containers for calls
rawData = cell(length(series), 1);
props = cell(length(series), 1);

% Start loop over each series
for iSer = 1:length(series)

    % Clean each series name
    clean_ser = series{iSer};
    clean_ser(clean_ser == ' ') = [];
    
    % Pass the inputs to expression_eval
    [rawResponse, props{iSer}] = ...
        cbd.private.expression_eval(clean_ser, opts, inTables{:});
    
    % If the rawResponse is not empty, set that series data equal to it
    if ~isempty(rawResponse)
        rawData{iSer} = rawResponse;
    end
end

%% Combine the series together
if length(rawData) > 1
    data = cbd.merge(rawData{:});
else
    data = rawData{1};
end

end
