function pChange = changePct(data, sDate, eDate)
%CHANGEPCT Returns the percent change in a window
%
% pChange = CHANGEPCT(data) returns the percent change of the data over the
% entire sample.
%
% pChange = CHANGEPCT(data, sDate) returns the percent change in the
% data from the start date to the end of the data
%
% pChange = CHANGEPCT(data, sDate, eDate) returns the percent change in the
% data between the two dates (inclusive). 

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
pChange = 100 * (lastData{1,:} ./ firstData{end,:} - 1);

pChange = array2table(pChange, 'RowNames', rNames(eInd), 'VariableNames', vNames);

end
