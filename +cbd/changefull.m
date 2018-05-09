function [changed, startDate] = changefull(data, sDate, eDate)
% CHANGEFULL Returns the change the range where all data is observed
%
% Predominantly the same as CHANGE but trims any ragged edge data at the 
% beginning and end of sample. 
%
% changed = CHANGEFULL(data) returns the change of the data from the first
% observation to the last.
%
% changed = CHANGEFULL(data, sDate) returns the change in the data from the
% start date to the end of the data. If the start date is not present, it
% takes the change from the first date prior to the start date.
%
% changed = CHANGEFULL(data, sDate, eDate) returns the change in the data 
% between the two dates inclusively. If the end date is not present, it 
% takes the cahnge from the first date following the end date.

% David Kelley, 2015

%% Check inputs
validateattributes(data, {'table'}, {'2d'});
rNames = data.Properties.RowNames;
vNames = data.Properties.VariableNames;

if nargin < 2
    sDate = rNames{1};
end
if nargin < 3 || any(isnan(eDate))
%     [~,lastInd] = cbd.last(data);
    lastInd = find(all(~isnan(data{:,:}), 2), 1, 'last');
    if isnan(lastInd)
        lastInd = size(data, 1);
    end
    eDate = rNames{max(lastInd)};
end
if ischar(sDate)
    sDate = datenum(sDate);
elseif sDate < datenum(1800,1,1)
    % Treat sDate as code that counts backward
    sDate = datenum(data.Properties.RowNames{end-sDate-1});
end
if ischar(eDate)
    eDate = datenum(eDate);
end

validateattributes(sDate, {'numeric'}, {'scalar', 'integer'}); 
validateattributes(eDate, {'numeric'}, {'scalar', 'integer'}); 

sInd = find(sDate >= datenum(rNames), 1, 'last');
eInd = find(eDate <= datenum(rNames), 1, 'first');

windowData = data(sInd:eInd,:);
firstData = cbd.first(windowData);
lastData = cbd.last(windowData);

%% Diff
if ~isempty(firstData) && ~isempty(lastData)
    changed = lastData{1,:} - firstData{end,:};
    changed = array2table(changed, 'RowNames', rNames(eInd), 'VariableNames', vNames);
else
    changed = data(end,:);
    changed{end,:} = nan;
end

startDate = rNames(sInd);

end
