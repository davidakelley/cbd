function newData = merge(varargin)
%MERGE Combines two tables with dates as the row labels
%
% newData = MERGE(dataA, dataB, ...) merges the data tables, provided that
% they have date strings as row labels

% David Kelley, 2014


%% Handle inputs
tableInd = false(size(varargin));
for iTbl = 1:nargin
    if ischar(varargin{iTbl})
        arg = varargin{iTbl};
        assert(strcmpi(arg, 'inner')||strcmpi(arg, 'outer')||strcmpi(arg, 'left')||strcmpi(arg, 'right'), ...
            'merge:argument', 'String entered not a valid argument');
        opts.(arg) = true;
    else
        validateattributes(varargin{iTbl}, {'table'}, {'2d'});
        if ~isempty(varargin{iTbl})
            tableInd(iTbl) = true;
        end
    end
end

%% Disaggregate to highest frequency data
inputTables = varargin(tableInd);
freq = cell(1, length(inputTables));
numPer = zeros(1, length(inputTables));
for iTbl = 1:length(inputTables)
    [freq{iTbl}, periodDays] = cbd.private.getFreq(inputTables{iTbl});
    numPer(iTbl) = max(periodDays); % Handle irregularly spaced data
end
[~, disaggIndex] = max(numPer);

disaggTables = cell(size(inputTables));
if length(inputTables) > 1
    for iTbl = 1:length(inputTables)
        disaggTables{iTbl} = cbd.disagg(inputTables{iTbl}, freq{disaggIndex});
    end
else
    disaggTables = inputTables;
end

%% Combine tables
datesIn = cell(1, nargin);
dataIn = cell(1, nargin);
alignData = cell(1, nargin);
varNames = cell(1, nargin);

for iTbl = 1:length(disaggTables)
    datesIn{iTbl} = datenum(disaggTables{iTbl}.Properties.RowNames);
    dataIn{iTbl} = disaggTables{iTbl}{:,:};
    varNames{iTbl} = disaggTables{iTbl}.Properties.VariableNames;
end

varCell = fixDuplicateVariableNames(varNames);

if ~strcmpi(freq{disaggIndex}, 'IRREGULAR')
    newDates = [];
    for iTbl = 1:nargin
        newDates = union(newDates, datesIn{iTbl});
    end
    datestrs = cellstr(cbd.private.mdatestr(newDates));

    for iTbl = 1:nargin
        alignData{iTbl} = cbd.private.alignToDates(dataIn{iTbl}, datesIn{iTbl}, newDates);
    end

    newData = array2table([alignData{:}], 'RowNames', datestrs, 'VariableNames', varCell);
else
    newData = disaggTables{1};
    newData.DatenumKey = datenum(newData.Properties.RowNames);
    for iTb = 2:length(inputTables)
        mergeTab = disaggTables{iTb};
        mergeTab.DatenumKey = datenum(mergeTab.Properties.RowNames);
        newData = outerjoin(newData, mergeTab, 'Keys', 'DatenumKey', 'MergeKeys', true);
    end
    newData.Properties.RowNames = cellstr(datestr(newData.DatenumKey));
    newData.DatenumKey = [];
    newData.Properties.VariableNames = varCell;
end

end


function varCell = fixDuplicateVariableNames(varNames)
% Handle duplicate variable names
varCell = [varNames{:}];

if ~(all(size([varNames{:}]) == size(unique([varNames{:}]))))
    
    dupNames = zeros(size(varCell));
    for iName = 1:length(varCell)
        iDups = strcmp(varCell{iName}, varCell);
        iDups(iName) = 0;
        dupNames = dupNames | iDups;
    end
    
    % Append the variable name with the number of table it came from
    tabVars = cellfun(@length, varNames);
    dupInd = find(dupNames);
    tabTotVars = cumsum(tabVars);
    
    dupTab = zeros(size(dupInd));
    for iDupSer = 1:length(dupInd)
        temp1 = dupInd(iDupSer) >= tabTotVars;
        if any(temp1)
            dupTab(iDupSer) = find(temp1, 1, 'last');
        else
            dupTab(iDupSer) = 0;
        end
        newVarName = [varCell{dupInd(iDupSer)} '_' num2str(dupTab(iDupSer))];
        while any(strcmpi(newVarName, varCell))
            newVarName = [newVarName '_' num2str(dupTab(iDupSer))];  %#ok<AGROW>
        end
        varCell{dupInd(iDupSer)} = newVarName;
    end
end

end