function [updatedIndex, isNewSection] = updateIndex(index, thisSection, newSeries, prompt)
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

% Check if the series exists anywhere in the index
check4new = @(x) ~ismember(x, indexSeries);
isNewSeries = cellfun(check4new, newSeries);

% Get the names of all the series newrently in the section
oldSeries = indexSeries(strcmpi(thisSection, indexSections));

% Check if the incoming seriesNames add new series
newInOld = ismember(newSeries, oldSeries);
oldInNew = ismember(oldSeries, newSeries);

% Treat the new section cases
if isNewSection
    if all(isNewSeries)
        % When the new section has all new series
        id = 'chidata:updateIndex:addSection';
        msg = sprintf('Adding a new section "%s" to CHIDATA', ...
            thisSection);
        prompt(id, msg);
        updatedIndex = addToIndex(index, thisSection, newSeries);
    else
        % When the new section contains existing series
        seriesList = strjoin(newSeries(~isNewSeries), ', ');
        id = 'chidata:updateIndex:moveSeries';
        msg = sprintf( ...
            ['The new section "%s" cannot contain series:', ...
            '\n%s\n', ...
            'Because they are already defined in CHIDATA'], ...
            thisSection, seriesList);
        error(id, msg); %#ok<*SPERR>
    end
end % if-newSection

% Treat the existing section cases
if ~isNewSection
    if all(newInOld) && all(oldInNew)
        % When the existing section has all of iis own series
        updatedIndex = index;
    elseif all(newInOld) && ~all(oldInNew)
        % When an existing section removes a series
        seriesToRemove = oldSeries(~oldInNew);
        seriesList = strjoin(seriesToRemove, ', ');
        id = 'chidata:updateIndex:removeSeries';
        msg = sprintf('Removing series from section "%s":\n%s\n', ...
            thisSection, seriesList);
        prompt(id, msg);
        updatedIndex = remove(index, seriesToRemove);
    elseif ~all(newInOld) && all(oldInNew)
        % When an existing section adds a series
        seriesToAdd = newSeries(~newInOld);
        seriesList = strjoin(seriesToAdd, ', ');
        id = 'chidata:updateIndex:addSeries';
        msg = sprintf('Adding series to section "%s":\n%s\n', ...
            thisSection, seriesList);
        prompt(id, msg);
        updatedIndex = addToIndex(index, thisSection, seriesToAdd);
    elseif ~all(newInOld) && ~all(oldInNew)
        if ~all(isNewSeries)
            % When an existing section adds series already defined
            seriesList = strjoin(newSeries(~isNewSeries), ', ');
            id = 'chidata:updateIndex:moveSeries';
            msg = sprintf( ...
                ['The existing section "%s" cannot contain series:', ...
                '\n%s\n', ...
                'Because they are already defined in CHIDATA'], ...
                thisSection, seriesList);
            error(id, msg);
        elseif all(isNewSeries)
            % When an existing sections adds and removes series
            seriesToRemove = oldSeries(~oldInNew);
            seriesToRemoveList = strjoin(seriesToRemove, ', ');
            seriesToAdd = newSeries(~newInOld);
            seriesToAddList = strjoin(seriesToAdd, ', ');
            
            id = 'chidata:updateIndex:modifySeries';
            msg = sprintf( ...
                ['Removing series from section "%s":', ...
                '\n%s\n', ...
                'And adding series to it:', ...
                '\n%s\n'], ...
                thisSection, seriesToRemoveList, seriesToAddList);
            
            prompt(id, msg);
            updatedIndex = remove(index, seriesToRemove);
            updatedIndex = addToIndex( ...
                updatedIndex, thisSection, seriesToAdd);
        end % if-elseif
    end % if-elseif
end % if-notNewSection

end % function

function updatedIndex = addToIndex(index, thisSection, seriesNames)
%ADDTOINDEX adds the variables specified to a given section

newSeries = [keys(index), seriesNames];
repThisSection = repmat({thisSection}, 1, length(seriesNames));
newSections = [values(index), repThisSection];
updatedIndex = containers.Map(newSeries, newSections);

end % function
