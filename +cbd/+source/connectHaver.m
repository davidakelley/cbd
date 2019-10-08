function [c, fullDB] = connectHaver(dbID)
%CONNECTHAVER establishes a connection to a Haver database
%
% INPUTS:
%   dbID    ~ char, the name of the database of interest
%
% OUPUTS:
%   c       ~ haver connection object for dbID
%   fullDB  ~ char, the path to the connection object c
%
% Santiago I. Sordo-Palacios

% Store the full path database
loc = 'R:\_appl\Haver\DATA\';
ext = '.DAT';
fullDB = fullfile(loc, [dbID ext]);

% Check if the file exists and you can read it
[~, fmsg] = fileattrib(fullDB);
foundFile = ~ischar(fmsg);

% Try again due to connection error
if ~foundFile
    pause(1);
    [~, fmsg] = fileattrib(fullDB);
    foundFile = ~ischar(fmsg);
end 

% Check that the file is found and that you can read it
assert(foundFile, ...
    'haverseries:invaliddbID', ...
    '%s cannot be found', fullDB);
assert(fmsg.UserRead, ...
    'haverseries:invaliddbID', ...
    '%s cannot be read', fullDB);

% Establish a Haver connection
c = haver(fullDB);
assert(isequal(isconnection(c), 1), ...
    'haverseries:invaliddbID', ...
    '%s cannot be established as a Haver conneciton', fullDB);

end % function-connectHaver