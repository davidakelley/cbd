function maxed = max(data, sDate, eDate)
%MAX Returns the maximum value of a dataset over the given period
%
% maxed = MAX(data) returns the observations for which the maximum value
% was recorded over the whole sample
%
% maxed = MAX(data, sDate, eDate) returns the max between the start date
% and end date (inclusive)
%
% maxed = MAX(data, sDate) or maxed = MAX(data, [], eDate) returns the 
% max after or before the given date (inclusive)

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

[~, iMax] = max(validdata{:,:}, [], 1);

maxed = validdata(iMax, :);
