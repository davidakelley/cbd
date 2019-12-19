function returnLoc = dir(inputLoc, varargin)
%DIR Initializes a chidata directory and returns its location
%
% During the first call of the function, the location of the CHIDATA
% directory is stored as a persistent varaible, chidataDir. During this
% first call, the function will check for the validity of that directory
% and whether an index file exists. If the index file does not exist, the
% user will be prompted as to whether one should be created. In subsequent
% calls to the function, the error checking is omitted and the value of
% chidataDir is returned as the output argument.
%
% INPUTS:
%   inputLoc    ~ char, the desired location of the CHIDATA directory
%   userInput   ~ char, the override userInput for the prompt calls
%
% OUTPUTS:
%   returnLoc   ~ char, the output location of the CHIDATA directory
%
% USAGE:
%   >> cbd.chidata.dir('MYPATH') % initialize directory at 'MYPATH'
%   >> cbd.chidata.dir() % Get the path to an initialized directory
%
% David Kelley, 2015
% Santiago Sordo-Palacios, 2019

% Initialize persistent variable
persistent chidataDir
persistentExists = ~isempty(chidataDir);

% Check whethere inputLoc is provided
if nargin < 1 || isempty(inputLoc)
    inputExists = false;
else
    inputExists = true;
end % if-nargin

% Parse the input arguments
inP = inputParser;
inP.addParameter('userInput', '', @ischar);
inP.parse(varargin{:});
userInput = inP.Results.userInput;

% Anonymous function to call prompt
if isempty(userInput)
    prompt = @(id, msg) cbd.chidata.prompt(id, msg);
else
    prompt = @(id, msg) cbd.chidata.prompt(id, msg, userInput);
end % if-nargin

%% Handle the cases of inputs
if ~persistentExists && ~inputExists
    % If no persistent and no input, throw error
    id = 'chidata:dir:notInitialized';
    msg = 'The CHIDATA directory has not been initialized';
    ME = MException(id, msg);
    throw(ME);
elseif persistentExists && ~inputExists
    % If persistent and no input, return persistent and exit
    returnLoc = chidataDir;
    return;
elseif ~persistentExists && inputExists
    % If no persistent and an input, set persistent as the input
    chidataDir = inputLoc;
elseif persistentExists && inputExists
    % If persistent and an input, prompt to change from persistent to input
    noChange = strcmpi(chidataDir, inputLoc);
    if noChange
        % Except when the directories are the same
        returnLoc = chidataDir;
        return;
    else
        % If they are not the same, prompt the change
        id = 'chidata:dir:changeLoc';
        msg = sprintf( ...
            'Changing CHIDATA directory from "%s" to "%s"', ...
            chidataDir, inputLoc);
        prompt(id, msg);
        chidataDir = inputLoc;
    end % if-strcmpi
end

%% Checking CHIDATA directory
% Check the validity of the directory
dirExists = isequal(exist(chidataDir, 'dir'), 7);
assert(dirExists, ...
    'chidata:dir:notFound', ...
    'Directory "%s" does not exist', chidataDir);

% Check that the index file exists
indexFname = fullfile(chidataDir, 'index.csv');
indexExists = isequal(exist(indexFname, 'file'), 2);

%  If an idnex file does not exist, prompt user to create a new one
if ~indexExists
    id = 'chidata:dir:makeNew';
    msg = sprintf( ...
        'No index file found \nCreating new CHIDATA directory at "%s"', ...
        chidataDir);
    prompt(id, msg)
    cbd.chidata.writeIndex(indexFname);
end

% Return the location of the new chidataDir
returnLoc = chidataDir;

end
