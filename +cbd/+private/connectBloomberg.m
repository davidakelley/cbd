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
    assert(isequal(dbID, 'BLOOMBERG'), ...
        'bloombergseries:invaliddbID', ...
        'bloombergseries dbID "%s" is not BLOOMBERG', dbID);
end % if-nargin

% Store location of the jar file
jarFile = 'C:\blp\DAPI\blpapi3.jar';

% Call the persistent variable
persistent blpconn
if isempty(blpconn)
    
    % Check for the existence of the jarFile
    [~, fmsg] = fileattrib(jarFile);
    foundFile = ~ischar(fmsg);
    assert(foundFile, ...
        'connectBloomberg:jarNotFound', ...
        '%s cannot be found', jarFile);
    assert(fmsg.UserRead, ...
        'connectBloomberg:jarNotRead', ...
        '%s cannot be read', jarFile);
    
    % Add the jar file to the Java path
    jpath = javaclasspath('-all');
    onPath = ismember(jpath, jarFile);
    if ~onPath
        javaaddpath(jarFile);
    end % if-notonPath
    
    % Establish a conenction to BLP
    blpconn = blp;
    
end % if-isempty

% Test the connection and add if it fails
if ~isconnection(blpconn)
    blpconn = blp;
end 

% Store as c to output
c = blpconn;

end % function-connectBloomberg