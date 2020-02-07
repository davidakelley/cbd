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
    msg = sprintf( ...
        'Overwriting data with new startDate "%s" BEFORE old startDate "%s"', ...
        data.Properties.RowNames{1}, oldData.Properties.RowNames{1});
    prompt(id, msg);
end

% Check if new startDate after the old startDate
newStartsAfterOld = gt( ...
    datenum(data.Properties.RowNames{1}), ...
    datenum(oldData.Properties.RowNames{1}));
if newStartsAfterOld
    id = 'chidata:compareData:newStartsAfterOld';
    msg = sprintf( ...
        'Overwriting data with new startDate "%s" AFTER old startDate "%s"', ...
        data.Properties.RowNames{1}, oldData.Properties.RowNames{1});
    prompt(id, msg);
end

% Check if new endDate before the old endDate
newEndsBeforeOld = lt( ...
    datenum(data.Properties.RowNames{end}), ...
    datenum(oldData.Properties.RowNames{end}));
if newEndsBeforeOld
    id = 'chidata:compareData:newEndsBeforeOld';
    msg = sprintf( ...
        'Overwriting data with new endDate "%s" BEFORE old endDate "%s"', ...
        data.Properties.RowNames{end}, oldData.Properties.RowNames{end});
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
    msg = sprintf( ...
        'Overwriting with new values that DIFFER from old values (tolerance: "%s")', ...
        num2str(tolerance));
    prompt(id, msg);
end

end % function