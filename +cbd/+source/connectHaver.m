function [c, dbFname] = connectHaver(dbID)
%CONNECTHAVER establishes a connection to a Haver database
%
% INPUTS:
%   dbID    ~ char, the name of the database of interest
%
% OUPUTS:
%   c           ~ haver connection object for dbID
%   dataFname   ~ char, the path to the connection object c
%
% Santiago I. Sordo-Palacios

% Store the full path to the database
haverPath = 'R:\_appl\Haver\DATA\';
haverExt = '.DAT';
dbFname = fullfile(haverPath, [dbID haverExt]);

% Check if the file exists
foundFile = false;
maxWait = 30;
tic;
while ~foundFile && toc < maxWait
    [~, fmsg] = fileattrib(dbFname);
    foundFile = ~ischar(fmsg);
end 

% Check that the file is found and that you can read it
assert(foundFile, ...
    'haverseries:invaliddbID', ...
    'Haver database "%s" cannot be found', dbFname);

% Establish a Haver connection
c = haver(dbFname);

end % function-connectHaver