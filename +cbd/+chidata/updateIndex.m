function [updatedIndex, isNewSection] = updateIndex(index, thisSection, curSeries, prompt)
%UPDATEINDEX is the helper function to update an index container
%
% INPUTS:
%   index           ~ containers.Map, the index from cbd.chidata.loadIndex
%   section         ~ char, the name of the section being updated
%   seriesNames     ~ cell, the names from data.Properties.VariableNames
%   prompt          ~ function handle, the function handle for user prompts
%
% OUTPUTS:
%   updatedIndex    ~ containers.Map, the updated index
%
% Santiago Sordo-Palacios, 2019

% Store the keys and values of the index
indexSeries = keys(index);
indexSections = values(index);

% Check if the section is a value in the index
isNewSection = ~ismember(thisSection, indexSections);

% Check if the section has moved
movingSeries = findMovingSeries(index, thisSection, curSeries);
if ~isempty(movingSeries)
    seriesList = strjoin(movingSeries, ', ');
    id = 'chidata:updateIndex:moveSeries';
    msg = sprintf( ...
        ['The new section "%s" cannot contain series:', ...
        '\n%s\n', ...
        'Because they are already defined elsewhere in CHIDATA'], ...
        thisSection, seriesList);
    error(id, msg); %#ok<*SPERR>
end

% Get the names of all the series currently in this section
oldSeries = indexSeries(strcmpi(thisSection, indexSections));

% Check if the incoming seriesNames adds or removes series
curInOld = ismember(curSeries, oldSeries);
oldInCur = ismember(oldSeries, curSeries);

% Treat the new section cases
if isNewSection
    % When the new section has all new series
    id = 'chidata:updateIndex:addSection';
    msg = sprintf('Adding a new section "%s" to CHIDATA', ...
        thisSection);
    prompt(id, msg);
    updatedIndex = addToIndex(index, thisSection, curSeries);

% Treat the existing section cases
else 
    if all(curInOld) && all(oldInCur)
        % When the existing section has all of iis own series
        updatedIndex = index;
    elseif all(curInOld) && ~all(oldInCur)
        % When an existing section removes a series
        seriesToRemove = oldSeries(~oldInCur);
        id = 'chidata:updateIndex:removeSeries';
        msg = sprintf('Removing series from section "%s":\n%s\n', ...
            thisSection, strjoin(seriesToRemove, ', '));
        
        prompt(id, msg);
        updatedIndex = remove(index, seriesToRemove);
    elseif ~all(curInOld) && all(oldInCur)
        % When an existing section adds a series
        seriesToAdd = curSeries(~curInOld);
        id = 'chidata:updateIndex:addSeries';
        msg = sprintf('Adding series to section "%s":\n%s\n', ...
            thisSection, strjoin(seriesToAdd, ', '));
        
        prompt(id, msg);
        updatedIndex = addToIndex(index, thisSection, seriesToAdd);
    elseif ~all(curInOld) && ~all(oldInCur)
        % When an existing sections adds and removes series
        seriesToRemove = oldSeries(~oldInCur);
        seriesToAdd = curSeries(~curInOld);
        
        id = 'chidata:updateIndex:modifySeries';
        msg = sprintf( ...
            ['Removing series from section "%s":', ...
            '\n%s\n', ...
            'And adding series to it:', ...
            '\n%s\n'], ...
            thisSection, ...
            strjoin(seriesToRemove, ', '), ...
            strjoin(seriesToAdd, ', '));
        
        prompt(id, msg);
        updatedIndex = remove(index, seriesToRemove);
        updatedIndex = addToIndex( ...
            updatedIndex, thisSection, seriesToAdd);
    end % if-elseif
end % if-notNewSection

end % function

function movingSeries = findMovingSeries(index, thisSection, curSeries)
%FINDSECTION finds the sections pertaining to each element of curSeries

% Preallocate cell and size
nCurSeries = length(curSeries);
sectionList = cell(1, nCurSeries);

% Loop over each element, store section if found, store empty if not found
for i = 1:length(curSeries)
    if isKey(index, curSeries{i})
        sectionList{i} = index(curSeries{i});
    else
        sectionList{i} = '';
    end
end % for-i

moveCheck = @(x) ~isequal(thisSection, x) & ~isempty(x);
moveIndex = cellfun(moveCheck, sectionList);
movingSeries = curSeries(moveIndex);

end % function

function updatedIndex = addToIndex(index, thisSection, seriesNames)
%ADDTOINDEX adds the variables specified to a given section

curSeries = [keys(index), seriesNames];
repThisSection = repmat({thisSection}, 1, length(seriesNames));
newSections = [values(index), repThisSection];
updatedIndex = containers.Map(curSeries, newSections);

end % function
