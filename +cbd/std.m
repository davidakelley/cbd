function stded = std(data, sDate, eDate)
% STD Returns the standard devation of a dataset over the given period
%
% stded = STD(data) returns the standard deviation value over the whole sample
%
% stded = STD(data, sDate, eDate) returns the standard deviation between the 
% start date and end date (inclusive)
%
% stded = STD(data, sDate) or stded = STD(data, [], eDate) returns the 
% standard deviation after or before the given date (inclusive)

% David Kelley, 2017

%% Check inputs
validateattributes(data, {'table'}, {'2d'});

rNames = datenum(data.Properties.RowNames);

if nargin < 2 || isempty(sDate)
    sDate = datestr(rNames(1));
end

if nargin < 3 || isempty(eDate)
    eDate = datestr(rNames(end));
end

if ischar(sDate)
    sDate = datenum(sDate);
elseif sDate < datenum(1800,1,1)
    % Treat sDate as code that counts backward
    sDate = datenum(data.Properties.RowNames{end-sDate});
end
if ischar(eDate)
    eDate = datenum(eDate);
end

validdates = rNames >= sDate & rNames <= eDate;
validdata = data(validdates, :);

std_data = nan(1, width(validdata));
for iSer = 1:width(validdata)
    nonNan = validdata{:, iSer};
    nonNan(isnan(nonNan)) = [];
    std_data(iSer)= std(nonNan);
end

stded = array2table(std_data, 'VariableNames', data.Properties.VariableNames, ...
    'RowNames', validdata.Properties.RowNames(end));
