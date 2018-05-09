function difaed = difa(data, nPer)
% DIFA Returns the annualized difference of a data series
%
% difaed = DIFA(data) returns the annualized first difference of the data
%
% difaed = DIFA(data, nPer) returns the annualized nPer difference of the data

% David Kelley, 2015

%% Check inputs
validateattributes(data, {'table'}, {'column'});

rNames = data.Properties.RowNames;
vName = data.Properties.VariableNames;
returnTab = true;
data = data{:,:};
dates = datenum(rNames);
nVar = size(data, 2);

validateattributes(dates, {'numeric'}, {'column'});
assert(length(dates) == length(data));

if nargin < 2
    nPer = 1;
end
validateattributes(nPer, {'numeric'}, {'scalar', 'integer'}); 

%% Diff
[~, pers] = cbd.private.getFreq(dates);

difaed = (data - cbd.lag(data, nPer)) * (pers/nPer);

if returnTab
    varNames = cellfun(@horzcat, repmat({['difa' num2str(nPer)]}, 1, nVar), vName, 'UniformOutput', false);
    difaed = array2table(difaed, 'RowNames', rNames, 'VariableNames', varNames);
end

end
