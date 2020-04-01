function c = connectBloomberg(dbID)
%CONNECTBLOOMBERG establishes a connection to a Bloomberg BLP
%
% INPUTS:
%   dbID    ~ char, the dbID, should be equal to BLOOMBERG
%
% OUPUTS:
%   c       ~ bloomberg connection object for dbID
%
% Santiago I. Sordo-Palacios, 2019

if nargin == 1
    assert(strcmpi(dbID, 'BLOOMBERG'), ...
        'bloombergseries:invaliddbID', ...
        'bloombergseries dbID "%s" is not BLOOMBERG', dbID);
end % if-nargin

% Add the jar file to the Java path
jarFile = 'C:\blp\DAPI\blpapi3.jar';
jpath = javaclasspath('-all');
onPath = ismember(jpath, jarFile);
if ~onPath
    [~, fmsg] = fileattrib(jarFile);
    foundFile = ~ischar(fmsg);
    assert(foundFile, ...
        'connectBloomberg:jarNotFound', ...
        'The BLP jar file "%s" cannot be found', jarFile);
    javaaddpath(jarFile);
end % if-notonPath

% Create the Bloomberg connection
maxWait = 30000; % in miliseconds
c = blp([], [], maxWait);

end % function-connectBloomberg