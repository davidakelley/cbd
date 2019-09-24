function assertOpts(opts, reqFields, callFun)
%ASSERTOPTS checks whether the required fields are all in opts
%
% INPUTS
%   opts        ~ struct, the structure passed to the source funciton
%   reqFields   ~ cell, the required fields in the opts structure
%   callFun     ~ char, the result of mfilename()
%
% Santiago I. Sordo-Palacios

nFields = length(reqFields);
for iField = 1:nFields
    thisField = reqFields{iField};
    hasField = isfield(opts, thisField);
    if ~hasField
        missID = [callFun ':miss' thisField];
        missMsg = sprintf('Missing %s field for %s', thisField, callFun);
        missME = MException(missID, missMsg);
        throwAsCaller(missME);
    end % if-nothasField
end % for-iField

dbField = 'dbID';
checkDB = any(ismember(reqFields, dbField));
if checkDB
    if isempty(opts.dbID)
        nullID = [callFun ':nulldbID'];
        nullMsg = sprintf('Null %s field for %s', dbField, callFun);
        nullME = MException(nullID, nullMsg);
        throwAsCaller(nullME);
    end % if-isempty
end % if-hasDB

end % function