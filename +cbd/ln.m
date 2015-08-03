function logged = ln(data)
%LN Returns the log version of a data series
%
% lDiffed = LN(data) returns the log of the data

% David Kelley, 2015

%% Check inputs
if istable(data)
    %validateattributes(data, {'table'}, {'column'});
    rNames = data.Properties.RowNames;
    vName = data.Properties.VariableNames;
    returnTab = true;
    data = data{:,:};
else
    %validateattributes(data, {'numeric'}, {'column'});
    returnTab = false;
end
nVar = size(data, 2);

%% Log
logged = log(data);

if returnTab
    varNames = cellfun(@horzcat, repmat({'ln'}, 1, nVar), vName, 'UniformOutput', false);
    logged = array2table(logged, 'RowNames', rNames, 'VariableNames', varNames);
end

end