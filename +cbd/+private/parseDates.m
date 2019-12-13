function dateOut = parseDates(dateIn, varargin)
%PARSEDATES transforms an input date from formatIn to formatOut
%
% PARSEDATES takes a dateIn with a formatIn (can be specified or can
% allow the function to classify it), transforms it to a datenum, and then
% transforms it to dateOut with formatOut (or defaults to cbd-style
% date of 'dd-mmm-yyyy'). If dateIn is empty, then a datenum
% defaultDate will be formated as formatOut. If dateIn is empty and no
% defaultDate is specified, then dateOut will be an empty variable
% of the same class as dateIn.
%
% INPUTS:
%   dateIn      ~ char/double/datetime, the date being converted
%   defaultDate ~ double, the default date to use if myDate is empty
%   formatIn    ~ char, the format of the date coming in
%   formatOut   ~ char, the format of the date going out
%
% OUPTUTS:
%   dateOut     ~ char/double/datetime, the outgoing date
%
% USAGE
%   >> x = cbd.private.parseDates(737426); % return dd-mmm-yyyy
%
%   >> x = cbd.private.parseDates('01-Jan-2019', ...
%       'formatOut', 'datetime'); % return datetime
%
%   >> x = cbd.private.parseDates('01/01/2019', ...
%       'formatIn', 'mm/dd/yyyy', ...
%       'formatOut', 'yyyy/mm-dd'); % return yyyy/mm-dd
%
%   >> x = cbd.private.parseDates([], ...
%       'defaultDate', 737426, ...
%       'formatOut', 'datestr'); % return datestr of defaultDate
%
% Santiago I. Sordo-Palacios, 2019

% Check that the class of dateIn is valid
classDateIn = class(dateIn);
supportedClasses = {'char', 'double', 'datetime'};
assert(ismember(classDateIn, supportedClasses), ...
    'parseDates:badClass', ...
    'Class "%s" not supported in parseDates', classDateIn);

% Parse the inputs
inP = inputParser;
inP.addParameter('defaultDate', [], @isnumeric);
inP.addParameter('formatIn', classDateIn, @ischar);
defaultFormatOut = 'dd-mmm-yyyy';
inP.addParameter('formatOut', defaultFormatOut, @ischar);
inP.parse(varargin{:})

% Set the variables
defaultDate = inP.Results.defaultDate;
formatIn = inP.Results.formatIn;
formatOut = inP.Results.formatOut;

% Handle empty dates
if isempty(dateIn) && isempty(defaultDate)
    % Return an empty variable of the same type
    dateOut = eval(strcat(classDateIn, '.empty'));
    return
elseif isempty(dateIn) && ~isempty(defaultDate)
    % Set the dateIn to be the default if it's empty
    dateIn = defaultDate;
    formatIn = class(defaultDate);
end % if-isempty

% Convert incoming date to datenum
switch formatIn
    case {'double', 'datenum'}
        % Handle the numeric case
        assert(isequal('double', class(dateIn)), ...
            'parseDates:notDouble', ...
            '"%s" is not a double but specified as such', dateIn)
        dateAsNum = dateIn;
    case 'datetime'
        % Handle the datetime case
        assert(isequal('datetime', class(dateIn)), ...
            'parseDates:notDatetime', ...
            '"%s" is not a datetime but specified as such', dateIn);
        dateAsNum = datenum(dateIn);
    case {'char', 'datestr'}
        % Handle the character case
        assert(isequal('char', class(dateIn)), ...
            'parseDates:notChar', ...
            '"%s" is not a char but specified as such', dateIn);
        try
            dateAsNum = datenum(dateIn);
        catch ME
            datenumError(ME, dateIn);
        end % try-catch
    otherwise
        % Handle the specified format case
        try
            dateAsNum = datenum(dateIn, formatIn);
        catch ME
            datenumError(ME, dateIn, formatIn);
        end % tr-catch
end % switch-case

% Check the datenum
assert(isnumeric(dateAsNum), ...
    'parseDates:badParse', ...
    'Temporary dateAsNum is not numeric');

% Convert datenum to outgoing date
switch formatOut
    case {'double', 'datenum'}
        dateOut = dateAsNum;
    case 'datetime'
        dateOut = datetime(dateAsNum, 'ConvertFrom', 'datenum');
    case {'char', 'datestr'}
        dateOut = datestr(dateAsNum);
    otherwise
        dateOut = datestr(dateAsNum, formatOut);
end % switch-case

end % function-parseDate

function datenumError(ME, dateIn, formatIn)
%DATENUMERROR edits the datenum conversion error to match tested errors
%
% INPUTS
%   ME          ~ MException, Matlab exception from datenum() call
%   dateIn      ~ char, the date that datenum() attempted to convert
%   formatIn    ~ char, the format used in formatIn() of datenum() call

if nargin < 3
    formatIn = 'MATALB default';
end

if strcmp(ME.identifier, 'MATLAB:datenum:ConvertDateString')
    id = 'parseDates:invalidDate';
    msg = sprintf( ...
        'Invalid date "%s" or formatIn "%s" misspecified', ...
        dateIn, formatIn);
    invME = MException(id, msg);
    invME = addCause(invME, ME);
    throwAsCaller(invME);
else
    throwAsCaller(ME);
end % if-else

end % function-datenumError
