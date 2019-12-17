function [data, props] = expression_eval(strIn, opts, varargin)
%EXPRESSION_EVAL evaluates a cbd expression with printf-style input
%
% This is a private function that handles the evaluation of the cbd
% expressions which comprise series, functions, operators, options, and
% other parameters. The cbd expression is parsed by CBD.EXPRESSION and
% then executed component-by-component by this function.
%
% INPUTS:
%   strIn       ~ char, the string to be evaluated.
%   opts        ~ struct, the options to be passed to database functions
%   varargin    ~ cell, additional cbd tables that are already specified
%
% OUTPUTS:
%   data        ~ table, the data of the expression requested
%   props       ~ struct, the properties of the data series requested
%               as well as the underlying components of mnemonics and
%               function names
%
% David Kelley, 2015
% Santiago Sordo-Palacios, 2019

% Check that number of input arguments match '%d's in string
specCheck = isequal(size(strfind(strIn, '%d'), 2), size(varargin, 2));
specID = 'expression_eval:spec';
specMsg = 'The strIn must include as many tables as "%%d" inputs';
assert(specCheck, specID, specMsg);

% Treat input as either a series, a scalar, or a function of the two
% These regex's check which operations are executed below
argumentRegex = regexpi(strIn, '#');
operatorRegex = regexpi(strIn, '[/*\-+]');
noParen = find(~getParenDepth(strIn));
noQuote = find(~getQuoteDepth(strIn));
argumentDiv = intersect(intersect(noParen, noQuote), argumentRegex);
operatorDiv = intersect(intersect(noParen, noQuote), operatorRegex);
tableInRegex = regexpi(strIn, '%d');
fnRegex = regexpi(strIn, '(\(|\))');

% Start the statement parsing
if ~isempty(operatorDiv)
    % Parse the operator inputs

    % Literal operator evaluation
    operators = '+-*/';
    operations = {'addition', 'subtraction', 'multiplication', 'division'};

    % Iterate over operator and split statement based on lower-precedence
    % operators first.
    for iOp = 1:length(operators)

        % Special case: negative operator at the beginning of string
        if iOp == 2 && operatorDiv(1) == 1
            % Strip out the negative sign and multiply by -1.
            [posData, posProps] = ...
                cbd.private.expression_eval( ...
                strIn(2:end), opts, varargin{:});
            data = cbd.multiplication(-1, posData);
            negMultProp = struct;
            negMultProp.ID = [];
            negMultProp.dbInfo = [];
            negMultProp.value = -1;
            props = ...
                cbd.private.combineProp('multiplication', ...
                negMultProp, posProps);
            return
        end % if-iOp

        % Other cases: break into two operands, call function
        [args, opBreakInds] = breakOnChar(strIn, operators(iOp));
        if length(opBreakInds) > 1
            opBreak = opBreakInds(end-1);
        else
            opBreak = opBreakInds;
        end % if-length

        % Store the tables coming in
        tabIns = ...
            {varargin(tableInRegex < opBreak), ...
            varargin(tableInRegex > opBreak)};

        % Order of operations says when we have the same precedence,
        % earlier things in the expression are evaluated first.
        if length(args) > 2
            args = {strjoin(args(1:end-1), operators(iOp)), args{end}};
        end % if-length

        % Gather all of the data series and execute operations
        if length(args) == 2

            % Preallocate the array for the results
            arguments = cell(size(args));
            seriesProps = cell(length(args), 1);

            % Download each of the series involved
            for iArg = 1:2
                [arguments{iArg}, seriesProps{iArg}] = ...
                    cbd.private.expression_eval( ...
                    args{iArg}, opts, tabIns{iArg}{:});
            end % for-iArg

            % Execute the operation function
            op_fn = findCbdFunction(operations{iOp});
            data = op_fn(arguments{:}, 'ignoreNan', opts.ignoreNan);
            props = ...
                cbd.private.combineProp(operations{iOp}, seriesProps{:});
            return

        end % if-length
    end % for-iOp

elseif ~isempty(argumentDiv)
    % Apply the hash(#)-argumentto preceeding string (up to a function)

    % Break apart the main string from the has sstring
    mainStr = strIn(1:argumentDiv(1)-1);
    argumentStr = strIn(argumentDiv(1)+1:end);

    % Extract arguments from the hash
    if length(argumentDiv) > 1
        extractArg = @(sInd, eInd) strIn(sInd:eInd);
        argIdx = [argumentDiv(2:end) - 1, length(strIn)];
        arguments = arrayfun( ...
            extractArg, argumentDiv+1, argIdx, 'UniformOutput', false);
    else
        arguments = {argumentStr};
    end % if-length

    % Store arguments from the hash
    for iArg = 1:length(arguments)
        if ~isempty(strfind(arguments{iArg}, ':'))
            iOpt = strsplit(arguments{iArg}, ':');
            opts.(iOpt{1}) = quoteStrip(iOpt{2});
        else
            opts.(arguments{iArg}) = true;
        end
    end

    % Evaluate the string with its has arguments in opts
    [data, props] = ...
        cbd.private.expression_eval(mainStr, opts, varargin{:});

elseif ~isempty(fnRegex)
    % Cbd function evaluation

    % Check for opening and closing parentheses where grouping parentheses
    % are taken as a null function
    openParens = strfind(strIn, '(');

    % Check that parentheses are well-defined
    parensCheck = ~isempty(openParens) & strcmp(strIn(end), ')');
    parensID = 'expression_eval:parens';
    parensMsg = 'Mismatched parentheses in "%s"';
    assert(parensCheck, parensID, parensMsg, strIn);
    strIn = strIn(1:end-1);

    % Strip out function and arguments
    fnNameIn = strIn(1:openParens(1)-1);
    argStr = strIn(openParens(1)+1:end);
    [args, argBreakPostParen] = breakOnChar(argStr, ',');
    argBreaks = argBreakPostParen + openParens(1) + 1;

    % Get the tables being passed to the function
    breakFun = @(breakStart, breakStop) ...
        varargin(tableInRegex >= breakStart & tableInRegex < breakStop);
    breakIdx = [1, argBreaks(1:end-1)];
    tabIns = arrayfun(breakFun, breakIdx, argBreaks, 'Uniform', false);

    % Preallcoate before the loop
    arguments = cell(length(args), 1);
    seriesProps = cell(length(args), 1);

    % For each argument, evaluate the data
    for iArg = 1:length(args)
        if iArg <= length(tabIns)
            iArguments = tabIns{iArg};
        else
            iArguments = {};
        end
        [arguments{iArg}, seriesProps{iArg}] = ...
            cbd.private.expression_eval(args{iArg}, opts, iArguments{:});
    end

    % Find and execute the transformation specified by the funciton
    if ~isempty(fnNameIn)
        fnName = findCbdFunction(fnNameIn);
        data = fnName(arguments{:});
    else
        % Check that there weren't insufficient arguments
        lengthArgCheck = length(arguments) <= 1;
        lengthArgID = 'expression_eval:insufficientArgs';
        lengthArgMsg = 'Insufficient number of arguments provided';
        assert(lengthArgCheck, lengthArgID, lengthArgMsg);

        % Store the arguments for combining properties
        data = arguments{1};
        fnName = '';
    end

    % Combine and store the properties
    props = cbd.private.combineProp(fnName, seriesProps{:});

elseif ~isempty(tableInRegex)
    % Case with provided table argument

    data = varargin{1};
    props = struct;
    props.ID = [];
    props.dbInfo = [];
    props.value = data;

elseif ~isempty(str2double(strIn)) && ~isnan(str2double(strIn))
    % Case with numeric input argument

    data = str2double(strIn);
    props = struct;
    props.ID = [];
    props.dbInfo = [];
    props.value = data;

elseif contains(strIn, char(34))
    % Case with a string input argument

    % Trim the incoming string
    cleanStr = strtrim(strIn);

    % Check that quotes are not misspecified
    stringInputCheck = ...
        strcmp(cleanStr(1), char(34)) & strcmp(cleanStr(end), char(34));
    stringInputID = 'expression_eval:stringInput';
    stringInputMsg = 'Mismatched quote characters in "%s"';
    assert(stringInputCheck, stringInputID, stringInputMsg, cleanStr);

    % Store the data and properties
    data = cleanStr(2:end-1);
    props = struct;

else
    % Evaluate an untransformed series by calling source functions

    % Split up the series from the dbID
    split = strsplit(strIn, '@');

    % Check that the seriesID is well-specified
    invalidInputCheck = length(split) <= 2 & ~isempty(split{1});
    invalidInputID = 'expression_eval:invalidInput';
    invalidInputMsg = 'Invalid series input for "%s"';
    assert(invalidInputCheck, invalidInputID, invalidInputMsg, strIn);

    % Replace the dbID in opts structure with second split if necessary
    seriesName = split{1};
    if length(split) == 2
        opts.dbID = split{2};
    end

    % Call the correct source function to pull the data and props
    if strcmpi(opts.dbID, 'BLOOMBERG')
        [data, props] = ...
            cbd.source.bloombergseries(seriesName, opts);
    elseif strcmpi(opts.dbID, 'CHIDATA')
        [data, props] = ...
            cbd.source.chidataseries(seriesName, opts);
    elseif strcmpi(opts.dbID, 'FRED')
        [data, props] = ...
            cbd.source.fredseries(seriesName, opts);
    else
        [data, props] = ...
            cbd.source.haverseries(seriesName, opts);
    end % if-strcmpi
end

end % function-expression_eval

function [args, breakInds] = breakOnChar(argStr, breakChar)
%BREAKONECHAR splits arguments by any commas not in quotes or parentheses

parenDepth = getParenDepth(argStr);
commasCharInds = argStr == breakChar;

breaks = parenDepth == 0 & commasCharInds == 1;
breakInds = [find(breaks) - 1, length(breaks)];
breakIndsDiff = [breakInds(1), (breakInds(2:end) - breakInds(1:end-1))];

args = mat2cell(argStr, 1, breakIndsDiff);

for iArg = 1:length(args)
    if args{iArg}(1) == breakChar
        args{iArg} = args{iArg}(2:end);
    end
end % for-iArg

end % function-breakOnChar

function fnHandle = findCbdFunction(fnNameIn)
%FINDCBDFUNCTION returns the function handle of a requested cbd function

% Get the names of all the functions in the +cbd folder
cbdLoc = findCbdLoc();
plusCbd = dir(fullfile(cbdLoc, '+cbd'));
plusCbdNames = {plusCbd.name};
allFunIdx = contains(plusCbdNames, '.m');
cbdFunctions = strrep(plusCbdNames(allFunIdx), '.m', '');

% Clean the name of the function coming in
fnName = strrep(fnNameIn, '%', 'Pct');

% Look for the function coming in the list of functions
thisFunIdx = strcmpi(cbdFunctions, fnName);

% Store the function or catch errors
if sum(thisFunIdx) == 1
    fnHandle = str2func(['cbd.', cbdFunctions{thisFunIdx}]);
elseif sum(thisFunIdx) < 1
    id = 'expression_eval:missFunction';
    msg = 'Undefined transformation "cbd.%s"';
    error(id, msg, fnNameIn);
elseif sum(thisFunIdx) > 1
    id = 'expression_eval:manyFunction';
    msg = 'Case insensitive match for "cbd.%s" produced multiple results';
    error(id, msg, fnNameIn);
end % if-elseif

end % function-findCbdFunction

function cbdLoc = findCbdLoc()
%FINDCBDLOC gets the location of the cbd package folder

% Find where cbd is with respect to this function
thisFile = mfilename('fullpath');
A = strfind(thisFile, 'cbd');

% Extract the ending position
S = struct('type', '()', 'subs', {{2}});
B = subsref(A, S);
extraChars = 3;
mainDirEnd = B - extraChars;

% Store the location
cbdLoc = thisFile(1:mainDirEnd);

end % function-findCbdLoc

function parenC = getParenDepth(strIn)
%GETPARENDEPTH checks the depth of the parentheses

openParens = strIn == '(';
closParens = strIn == ')';
parenC = cumsum(openParens) - cumsum(closParens);

end % function-getParenDepth

function quoteD = getQuoteDepth(strIn)
%GETQUOTEDEPTH finds the depth of the double quotes

quoteChars = find(strIn == char(34));

check = mod(length(quoteChars), 2) == 0;
id = 'expression_eval:mismatchedString';
msg = 'Mismatched string delimiters in <%s>'; % using <> since "" is error
assert(check, id, msg, strIn);

openQuote = quoteChars(1:2:end-1);
closeQuote = quoteChars(2:2:end);
quoteD = zeros(size(strIn));

for iStr = 1:length(openQuote)
    quoteD(openQuote(iStr):closeQuote(iStr)) = 1;
end % for-iStr

end % function-getQuoteDepth

function cleanStr = quoteStrip(strIn)
%QUOTESTRIP strips out double qutoes from an input string

cleanStr = strtrim(strIn);
if strcmpi(cleanStr(1), char(34)) && strcmpi(cleanStr(end), char(34))
    cleanStr = cleanStr(2:end-1);
end

end % function-quoteStrip