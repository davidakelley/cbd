function changed = change(data, sDate, eDate)
%CHANGE Returns the change over a the given period
%
% changed = CHANGE(data) returns the change of the data over the entire sample.
%
% changed = CHANGE(data, sDate) returns the change in the data from the
% start date to the end of the data
%
% changed = CHANGE(data, sDate, eDate) returns the change in the data 
% between the two dates (inclusive). 

% David Kelley, 2015

%% Check inputs
validateattributes(data, {'table'}, {'2d'});
rNames = data.Properties.RowNames;
vNames = data.Properties.VariableNames;

if nargin < 2
    sDate = rNames{1};
end
if nargin < 3 || any(isnan(eDate))
    [~,lastInd] = cbd.last(data);
    eDate = rNames{max(lastInd)};
end
if ischar(sDate)
    sDate = datenum(sDate);
else
    % Treat sDate as code that counts backward
    sDate = datenum(data.Properties.RowNames{end-sDate-1});
end
if ischar(eDate)
    eDate = datenum(eDate);
end

validateattributes(sDate, {'numeric'}, {'scalar', 'integer'}); 
validateattributes(eDate, {'numeric'}, {'scalar', 'integer'}); 

sInd = find(sDate == datenum(rNames), 1);
eInd = find(eDate == datenum(rNames), 1);

windowData = data(sInd:eInd,:);
firstData = cbd.first(windowData);
lastData = cbd.last(windowData);

%% Diff
changed = lastData{1,:} - firstData{end,:};

changed = array2table(changed, 'RowNames', rNames(eInd), 'VariableNames', vNames);

end
