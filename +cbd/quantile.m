function meaned = quantile(data, percent, sDate, eDate)
%MEAN Returns the mean value of a dataset over the given period
%
% meaned = MEAN(data) returns the mean value over the whole sample
%
% meaned = MEAN(data, sDate, eDate) returns the mean between the start date
% and end date (inclusive)
%
% meaned = MEAN(data, sDate) or meaned = MEAN(data, [], eDate) returns the 
% mean after or before the given date (inclusive)

% David Kelley, 2014

%% Check inputs
validateattributes(data, {'table'}, {'2d'});

rNames = datenum(data.Properties.RowNames);

if nargin < 3 || isempty(sDate)
    sDate = datestr(rNames(1));
end

if nargin < 4 || isempty(eDate)
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

mean_data = nan(1, width(validdata));
for iSer = 1:width(validdata)
    nonNan = validdata{:, iSer};
    nonNan(isnan(nonNan)) = [];
    mean_data(iSer)= quantile(nonNan,percent);
end

meaned = array2table(mean_data, 'VariableNames', data.Properties.VariableNames, ...
    'RowNames', validdata.Properties.RowNames(end));
