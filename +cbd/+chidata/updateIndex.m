function [updatedIndex, isNewSection] = updateIndex(index, thisSection, curSeries, prompt)
%UPDATEINDEX is the helper function to update an index container
%
% INPUTS:
%   index       ~ containers.Map, the index from cbd.chidata.loadIndex
%   section     ~ char, the name of the section being updated
%   seriesNames ~ cell, the names from data.Properties.VariableNames
%   prompt      ~ function handle, the function handle for user prompts
%
% OUTPUTS:
%   updatedIndex~ containers.Map, the updated index
%
% Santiago Sordo-Palacios, 2019

% Store the keys and values of the index
indexSeries = keys(index);
indexSections = values(index);

% Check if the section is a value in the index
isNewSection = ~ismember(thisSection, indexSections);

% Check if the series exists anywhere in the index
check4new = @(x) ~ismember(x, indexSeries);
isNewSeries = cellfun(check4new, curSeries);

% Get the names of all the series currently in the section
oldSeries = indexSeries(strcmp(thisSection, indexSections));

% Check if the incoming seriesNames add new series
curInOld = ismember(curSeries, oldSeries);
oldInCur = ismember(oldSeries, curSeries);

% Treat the new section cases
if isNewSection
    if all(isNewSeries)
        % When the new section has all new series
        id = 'chidata:updateIndex:addSection';
        msg = sprintf('Adding new section "%s" to the index', thisSection);
        prompt(id, msg);
        updatedIndex = addToIndex(index, thisSection, curSeries);
    else
        % When the new section contains existing series
        error('chidata:updateIndex:moveSeries', ...
            'The new section "%s" contain existing series', ...
            thisSection);
    end
end % if-newSection

% Treat the existing section cases
if ~isNewSection
    if all(curInOld) && all(oldInCur)
        % When the existing section has all is own series
        updatedIndex = index;
    elseif all(curInOld) && ~all(oldInCur)
        % When an existing section removes a series
        id = 'chidata:updateIndex:removeSeries';
        msg = sprintf('Removing series from section "%s"', thisSection);
        prompt(id, msg);
        seriesToRemove = oldSeries(~oldInCur);
        updatedIndex = remove(index, seriesToRemove);
    elseif ~all(curInOld) && all(oldInCur)
        % When an existing section adds a series
        id = 'chidata:updateIndex:addSeries';
        msg = sprintf('Adding series to section "%s"', thisSection);
        prompt(id, msg);
        seriesToAdd = curSeries(~curInOld);
        updatedIndex = addToIndex(index, thisSection, seriesToAdd);
    elseif ~all(curInOld) && ~all(oldInCur) && ~all(isNewSeries)
        error('chidata:updateIndex:moveSeries', ...
            'The section "%s" cannot contain series already defined', ...
            thisSection);
    elseif ~all(curInOld) && ~all(oldInCur) && all(isNewSeries)
            id = 'chidata:updateIndex:modifySeries';
            msg = sprintf('Adding and removing series from section "%s"', ...
                thisSection);
            prompt(id, msg);
            seriesToRemove = oldSeries(~oldInCur);
            updatedIndex = remove(index, seriesToRemove);
            seriesToAdd = curSeries(~curInOld);
            updatedIndex = addToIndex(updatedIndex, thisSection, seriesToAdd);
    end % if-elseif
end % if-notNewSection

end % function

function updatedIndex = addToIndex(index, thisSection, seriesNames)
%ADDTOINDEX adds the variables specified to a given section

newSeries = [keys(index) seriesNames];
repThisSection = repmat({thisSection}, 1, length(seriesNames));
newSections = [values(index) repThisSection];
updatedIndex = containers.Map(newSeries, newSections);

end % function
