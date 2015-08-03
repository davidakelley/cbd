function avged = avg(data, sDate, eDate)
%AVG Returns the average value of a dataset over the given period
%
% avged = avg(data) returns the the average value over the sample
%
% avged = avg(data, sDate, eDate) returns the average between the start date
% and end date (inclusive)
%
% avged = avg(data, sDate) or avged = avg(data, [], eDate) returns the 
% average after or before the given date (inclusive)
%
% David Kelley, 2014

%% Check inputs
validateattributes(data, {'table'}, {'2d'});

rNames = datenum(data.Properties.RowNames);
vNames = data.Properties.VariableNames;

if nargin < 2 || isempty(sDate)
    sDate = rNames(1);
end

if nargin < 3 || isempty(eDate)
    eDate = rNames(end);
end

validdates = rNames >= datenum(sDate) & rNames <= datenum(eDate);
validdata = data(validdates, :);

avgVals = nanmean(validdata{:,:}, 1);

avged = array2table(avgVals, 'VariableNames', vNames);