function assertSeries(seriesID, callFun)
%ASSERTOPTS checks if a seriesID is parsed correctly
% INPUTS:
%   seriesID    ~ char, the name of the series
%   callFun     ~ char, the result of mfilename()
%
% Santiago I. Sordo-Palacios, 2019

% Check that seriesID is not empty
isNull = isempty(seriesID);
if isNull
    nullID = [callFun ':nullSeries'];
    nullMsg = sprintf('seriesID cannot be empty for %s', callFun);
    nullME = MException(nullID, nullMsg);
    throwAsCaller(nullME);
end 

% Check for parentheses in the seriesID
illegalChar = {'(' , ')'};
hasParen = contains(seriesID, illegalChar);

if hasParen
    parenID = [callFun ':invalidParen'];
    parenMsg = sprintf('Invalid parentheses in %s for %s', ...
        seriesID, callFun);
    parenME = MException(parenID, parenMsg);
    throwAsCaller(parenME)
end % if-checkParen
    
% Check for @ sign in the seriesID
atSign = '@';
hasAtSign = contains(seriesID, atSign);

if hasAtSign
    atID = [callFun ':invalidAtSign'];
    atMsg = sprintf('Invalid @ sign in %s for %s', ...
        seriesID, callFun);
    atME = MException(atID, atMsg);
    throwAsCaller(atME);
end % if-atSign

end % function