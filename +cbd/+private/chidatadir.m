function loc = chidatadir(newloc)
% Edit or retreive the folder location of the CHIDATA database. 
%
% With no argument passed, chidatadir returns the current location: 
%   loc = chidatadir()
%
% With an argument passed, it updates the location and returns the input argument: 
%   loc = chidatadir(loc)

% David Kelley, 2019

defaultDir = 'O:\PROJ_LIB\Presentations\Chartbook\Data\CHIDATA\';

persistent chidataDir

if isempty(chidataDir)
  chidataDir = defaultDir;
end

if nargin > 0 && ~isempty(newloc)
  assert(exist(newloc, 'dir') == 7, 'Directory does not exist.');
  
  if exist(fullfile(newloc, 'index.csv'), 'file') ~= 2
    promptContinue(...
      sprintf('No index file found. Create new CHIDATA directory at %s?', newloc));
    
    fid = fopen(fullfile(newloc, 'index.csv'), 'w');
    fprintf(fid, 'Series, Section\n');
    fclose(fid);
  end
  
  chidataDir = newloc;
end

loc = chidataDir;

end


function promptContinue(msg)
% Asks for user to confirm writing data in potential dangerous situations.

disp(msg);
confirm = input('Continue? (y/n)>> ', 's');

if ischar(confirm) && strcmpi(confirm(1),'y')
  disp('Continuing...');
else
  error('chidata_save:user', 'User halted execution.');
end

end