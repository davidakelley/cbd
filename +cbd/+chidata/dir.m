function returnLoc = dir(inputLoc)
%CHIDATADIR Initializes a chidata directory and returns its location
%
% During the first call of the function, the location of the CHIDATA
% directory is stored as a persistent varaible, chidataDir. During this
% first call, the function will check for the validity of that directory
% and whether an index file exists. If the index does not exist, the 
% user will be prompted as to whether one should be created. In subsequent
% calls to the function, the error checking is omitted and the value of
% chidataDir is returned as returnLoc.
%
% INPUTS:
%   inputLoc    ~ char, the input location of the CHIDATA directory
%
% OUTPUTS:
%   outputLoc   ~ char, the output location of the CHIDATA directory
%
% USAGE:
%   >> cbd.chidata.dir('MYPATH') % initialize directory at 'MYPATH'
%   >> cbd.chidata.dir() % Get the path to initialized CHIDATA directory
%
% David Kelley, 2015
% Santiago I. Sordo Palacios, 2019

% Initialize persistent variable
persistent chidataDir
prompt = @(id, msg) cbd.chidata.prompt(id, msg);

%% Handle the inputLoc
if isempty(chidataDir) && nargin == 0
    % If no persistent and no input, throw error
    id = 'chidata:dir:notInitialized';
    msg = 'You must first initialize a CHIDATA directory';
    ME = MException(id, msg);
    throw(ME);
elseif ~isempty(chidataDir) && nargin == 0
    % If persistent and no input, return persistent and exit
    returnLoc = chidataDir;
    return;
elseif isempty(chidataDir) && nargin == 1
    % If no persistent and an input, set input as persistent
    chidataDir = inputLoc;
elseif ~isempty(chidataDir) && nargin == 1
    % If persistent and an input, prompt change of persistent to input
    id = 'chidata:dir:changeLoc';
    msg = sprintf( ...
        'Changing CHIDATA directory from "%s" to "%s"', ...
        chidataDir, inputLoc);
    prompt(id, msg);
    chidataDir = inputLoc;
end

%% Checking CHIDATA directory
% Check that the directory is a full path
isPath = contains(chidataDir, ':');
assert(isPath, ...
    'chidata:dir:notPath', ...
    'Directory "%s" is not a full path', chidataDir);

% Check the validity of the directory
dirExists = isequal(exist(chidataDir, 'dir'), 7);
assert(dirExists, ...
    'chidata:dir:notFound', ...
    'Directory "%s" is not found', chidataDir);

% Check that the index file exists
indexFname = fullfile(chidataDir, 'index.csv');
indexExists = isequal(exist(indexFname, 'file'), 2);

%  If an idnex file does not exist, prompt user to create a new one
if ~indexExists
    id = 'chidata:dir:makeNew';
    msg = sprintf( ...
        'No index file found \nCreating new CHIDATA directory at %s',  ...
        chidataDir);
    prompt(id, msg)
    fid = fopen(indexFname, 'w');
    fprintf(fid, 'Series, Section\n');
    fclose(fid);
end

% Return the location of the new chidataDir
returnLoc = chidataDir;

end
