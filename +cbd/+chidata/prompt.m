function prompt(id, msg, userInput)
%PROMPT Asks for user input to allow process to proceed in CHIDATA
%
% INPUTS
%   id          ~ char, the id to display in the warning
%   msg         ~ char, the message displayed in the warning
%   userInput   ~ char, the optional override userInput
%
% David Kelley, 2019
% Santiago Sordo-Palacios, 2019

% Escape filesep if it appears in the message
if ismember(filesep, msg)
    msg = strrep(msg, filesep, [filesep filesep]);
end % if-ismember

% Issue the warning
fprintf('\n');
warning(id, msg);

% Request user input if none provided
if nargin < 3
    userInput = 'X'; % store so that while logic works
    while ~any(strcmpi(userInput(1), {'y', 'n'}))
        % request until an answer starts with y or n
        userInput = input('Continue? (y/n) >> ', 's');
    end % while-notcontains
end % if-nargin

% Respond to user input
if strcmpi(userInput(1), 'y')
    fprintf('Continuing... \n');
else
    id = 'chidata:prompt:userBreak';
    msg = sprintf('User halted execution with "%s"', userInput);
    ME = MException(id, msg);
    throwAsCaller(ME);
end % if-else

end