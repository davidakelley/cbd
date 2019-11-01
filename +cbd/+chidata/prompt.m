function prompt(id, message)
%PROMPT Asks for user input to allow process to proceed in CHIDATA
%
% INPUTS
%   id          ~ the id to display in the warning() call
%   messsage    ~ char, the message printed to the user
%
% David Kelley, 2019
% Santiago Sordo-Palacios, 2019

% Display message to user
userInput = inputdlg(message, id, 1, {'yes'});
userInput = userInput{:};

% Respond to user input
if ischar(userInput) && strcmpi(userInput(1), 'y')
    disp('Continuing...');
else
    id = 'chidata:prompt:userBreak';
    message = 'User halted execution during prompt';
    ME = MException(id, message);
    throwAsCaller(ME);
end % if-else

end
