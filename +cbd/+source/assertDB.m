function assertDB(dbID, callFun)
%ASSERTDB checks if a database is correctly specified
% INPUTS:
%   seriesID    ~ char, the name of the series
%   callFun     ~ char, the result of mfilename()
%
% Santiago I. Sordo-Palacios, 2019

% Check that seriesID is not empty
isNull = isempty(dbID);
if isNull
    nullID = [callFun ':nullDB'];
    nullMsg = sprintf('dbID cannot be empty for %s', callFun);
    nullME = MException(nullID, nullMsg);
    throwAsCaller(nullME);
end 

% Check that seriesID matches the callFun
expectDB = upper(erase(dbID, 'series'));
validDB = isequal(dbID, expectDB) || isequal('HAVER', expectDB);
if ~validDB
    nullID = [callFun ':invalidDB'];
    nullMsg = sprintf('seriesID cannot be empty for %s', callFun);
    nullME = MException(nullID, nullMsg);
    throwAsCaller(nullME);
end % if-notvalidDB


end % function-valid