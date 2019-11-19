function compareData(data, oldData, tolerance, prompt)
%COMPAREDATA is a helper function that compares old to existing data
%
% INPUTS
%   data        ~ table, the existing data table
%   oldData     ~ table, the previous data table
%   tolerance   ~ numeric, the tolerance when comparing revisiosn
%   prompt      ~ function handle, the handle to call cbd.chidata.prompt
%
% WARNING: This function should NOT be called directly by the user
%
% Santiago Sordo-Palacios, 2019

% Check if new startDate before old startDate
newStartsBeforeOld = lt( ...
    datenum(data.Properties.RowNames{1}), ...
    datenum(oldData.Properties.RowNames{1}));
if newStartsBeforeOld
    id = 'chidata:compareData:newStartsBeforeOld';
    msg = 'Overwriting with new startDate before old startDate';
    prompt(id, msg);
end

% Check if new startDate after the old startDate
newStartsAfterOld = ne( ...
    datenum(data.Properties.RowNames{1}), ...
    datenum(oldData.Properties.RowNames{1}));
if newStartsAfterOld
    id = 'chidata:compareData:newStartsAfterOld';
    msg = 'Overwriting with new startDate after the old startDate';
    prompt(id, msg);
end

% Check if new endDate before the old endDate
newEndsBeforeOld = lt( ...
    datenum(data.Properties.RowNames{end}), ...
    datenum(oldData.Properties.RowNames{end}));
if newEndsBeforeOld
    id = 'chidata:compareData:newEndsBeforeOld';
    msg = 'Overwriting with new endDate before the old endDate';
    prompt(id, msg);
end

% Note: we do not check if the new endDate is after the old endDate
% because we expect this to be true if we are updating data
% or at least the same if no new data are added

% Check if data are being revised
minLen = min(size(oldData, 1), size(data, 1));
minWid = min(size(oldData, 2), size(data, 2));
equalArray = lt( ...
    abs(oldData{1:minLen, 1:minWid}-data{1:minLen, 1:minWid}), ...
    tolerance);
nanArray = arrayfun( ...
    @isnan, oldData{1:minLen, 1:minWid}) | ...
    arrayfun(@isnan, data{1:minLen, 1:minWid});
newHasRevisions = ~all(equalArray | nanArray);
if newHasRevisions
    id = 'chidata:compareData:newHasRevisions';
    msg = 'Overwriting with revised data';
    prompt(id, msg);
end

end % function