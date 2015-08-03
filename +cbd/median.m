function medianed = median(data, sDate, eDate)
%MEDIAN Returns the median value of a dataset over the given period
%
% medianed = MEDIAN(data) returns the median value over the whole sample
%
% medianed = MEDIAN(data, sDate, eDate) returns the median between the start date
% and end date (inclusive)
%
% medianed = MEDIAN(data, sDate) or medianed = MEDIAN(data, [], eDate) returns the 
% median after or before the given date (inclusive)

% David Kelley, 2014

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
else
    % Treat sDate as code that counts backward
    sDate = datenum(data.Properties.RowNames{end-sDate});
end
if ischar(eDate)
    eDate = datenum(eDate);
end

validdates = rNames >= sDate & rNames <= eDate;
validdata = data(validdates, :);

median_data = median(validdata{:,:});

medianed = array2table(median_data, 'VariableNames', data.Properties.VariableNames, ...
    'RowNames', validdata.Properties.RowNames(end));
