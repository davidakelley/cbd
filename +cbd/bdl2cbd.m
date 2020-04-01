function [data, props] = bdl2cbd(fname)
%bdl2cbd converts Bloomberg Data License file into a cbd table
%
% This function takes the output of a Bloomberg Data License Per Security
% request ouput, reads it in with MATLAB's bddlloader() function, and then
% reformats it into a cbd-style table. It will return also return a props
% structure that can be used in cbd.chidata_save call.
%
% Input:
%   fname   ~ char, input filename
%
% Ouput:
%   data    ~ table, the data in cbd-style table format of wide
%   props   ~ struct, the structure containing properties from the Header
% 
% Santiago Sordo-Palacios, 2019

% Import the DataLicense file with MATLAB's bdlloader
d = bdlloader(fname);
longData = cell2table(d.Data);

% Rename variables in the table
longData.Properties.VariableNames{1} = 'ticker';
longData.Properties.VariableNames{2} = 'date';
longData.Properties.VariableNames{3} = 'value'; 

% Drop out the 'START SECURITY' and 'END SECURITY' rows
startIdx = strcmpi(longData.ticker, 'START SECURITY');
info = longData(startIdx, :);
longData = longData(~startIdx, :);
endIdx = strcmpi(longData.ticker, 'END SECURITY');
longData = longData(~endIdx, :);

% Clean-up the info for user later
varNames = info.date;
varFields = info.value;

% Fix the variable names
yellowKeys = {'GOVT', 'CORP', 'MTGE', 'M-MKT', 'Muni', ...
    'PDF', 'EQUITY', 'COMDTY', 'INDEX', 'CURNCY', 'PORT'};
nVars = length(varNames);
newVarNames = cell(nVars, 1);

for iVar = 1:nVars
    % Check for a yellow key in the variable name
    hasYK = contains(varNames{iVar}, yellowKeys, 'IgnoreCase', true);
    if hasYK
        % If it has a yellow key, then store as is
        newVarNames{iVar} = varNames{iVar};
    else 
        % If no yellow key, add the one from the Header and store that
        assert(isfield(d.Header, 'YELLOWKEY'), ...
            'datalicense2cbd:missingYellowKey', ....
            'No key in %s and no field YELLOWKEY in Header', ...
            varNames{iVar});
        newVarNames{iVar} = [varNames{iVar}, '_' d.Header.YELLOWKEY];
    end % if-nothasYK
    
    % Add the field name to each variable
    newVarNames{iVar} = [newVarNames{iVar} '_' varFields{iVar}];
    
    % Replace all spaces with underscores
    newVarNames{iVar} = strrep(newVarNames{iVar}, ' ', '_');
end

% Replace varNames with newVarNames
nameMap = containers.Map(varNames, newVarNames);
replaceFun = @(x) nameMap(x);
longData.ticker = cellfun(replaceFun, longData.ticker, ...
    'UniformOutput', false);

% Replace variables with correct formats
longData.date = cellstr(datestr(longData.date));
longData.value = str2double(longData.value);

% Reshape to a wide table
data = unstack(longData, 'value', 'ticker');

% Add dates as row names
data.Properties.RowNames = data.date;
data = sortrows(data, 'date');
data = removevars(data, 'date');

% Create the properties structure
props = struct();
props.Header = d.Header;
props.AggType = '';
props.DataType = '';
props.Frequency = cbd.private.getFreq(data);
props.Magnitude = [];
props.Source = 'BloombergDataLicense';
nSer = width(data);
for iSer = 2:nSer
    props(iSer) = props(1);
end

end % function