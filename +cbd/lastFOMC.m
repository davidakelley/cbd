function LastFOMCDate = lastFOMC(varargin)
% LastFOMCDate = LastFOMC(date)
% Returns the last FOMC date if no input is provided
% 
% If a date input is added, LastFOMC returns a series of FOMC dates that
% have occured after the input date
% Input date must be formatted dd-MMM-yyyy
% 
% Examples:
% LastFOMCDate = LastFOMC()
% LastFOMCDate = 1×1 cell array
% {'29-Jan-2019'}
%
% LastFOMCDate = LastFOMC('1-Jan-2018')
% LastFOMCDate = 8×1 cell array  
%    {'30-Jan-2018'}
%    {'20-Mar-2018'}
%    {'01-May-2018'}
%    {'12-Jun-2018'}
%    {'25-Sep-2018'}
%    {'07-Nov-2018'}
%    {'18-Dec-2018'}
%    {'29-Jan-2019'}
%
%
% Written by Vamsi Kurakula
% Last Updated 2/5/2019



% Making sure that if there are input arguments that they are the correct
% length and type

if isempty(varargin)
    DateOfInterest = datetime('today');
elseif length(varargin) == 1         
    if isdatetime(varargin{1})
        DateOfInterest = varargin{1}; 
    else
        try 
            DateOfInterest = datetime(varargin,'InputFormat','dd-MMM-yyyy');    
        catch
            error('LastFOMC:NotADate', 'Function only accepts a single date input');
        end % End Try 
    end  % End if for making sure varargin is a datetime 
else    
    error('LastFOMC:MultipleInputs', 'Function only accepts a single date input');   
end % End if for length of inputs of function  
    
    
% Setting StartDate
StartDate = datestr(DateOfInterest - calyears(1));

% Collecting the data
fomcdata = cbd.data('FOMC@DAILY','startDate',StartDate,'endDate',datenum(datetime('today')));

% Cutting out Things that are not FOMC Dates
fomcdata(fomcdata.FOMC == -1,:) = [];
fomcdata.Date = datetime(fomcdata.Row);

% We only care abput collecting the first of the two consecutive dates 
IsFirst = (fomcdata.Date(2:end) - fomcdata.Date(1:end-1)) < days(10);

% dealing with the last date in the list separately 
if (fomcdata.Date(end)  - fomcdata.Date(end-1)) < days(10)
   IsFirst = [IsFirst; false];
else
   IsFirst = [IsFirst; true];
end

% Cutting out the extra FOMC dates
fomcdata(~IsFirst,:) = [];


% if there is no inputs we want to return only the last FOMC Date
% Otherwise we want to collect dates after the date of interest (input)

if isempty(varargin)    
     LastFOMCDate = fomcdata.Row(end);
else    
     LastFOMCDate = fomcdata.Row(datetime(fomcdata.Row) >= DateOfInterest);
end %End if


end % End Function 