function exponentiated = exp(data)
% EXP Returns the exponentiated version of a data series
%
% exponentiated = EXP(data) returns the exponental of the data

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

%% Diff
exponentiated = exp(data);

if returnTab
    varNames = cellfun(@horzcat, repmat({'exp'}, 1, nVar), vName, 'UniformOutput', false);
    exponentiated = array2table(exponentiated, 'RowNames', rNames, 'VariableNames', varNames);
end

end