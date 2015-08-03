function output = fredpull(strIn, opts)
%FREDPULL Evaluate a FRED expression
%
% Evaluate an expression of FRED series and functions, returning a table.

% David Kelley, 2015

%% Check for illegal charactars
illegalChar = '"''';
regexOut = regexpi(strIn, illegalChar);
assert(isempty(regexOut), 'fred:fredpull:invalidInput');

%% Treat input as either a FRED series, a scalar, or a function of those two
fnRegex = regexpi(strIn, '(\(|\))');

if ~isempty(fnRegex) % Function
    if strcmp(strIn(end),')')
        strIn = strIn(1:end-1);
    else
        error('Last char not '')''');
    end
    openParens = strfind(strIn, '(');
    fnName = strIn(1:openParens(1)-1);
    argStr = strIn(openParens(1)+1:end); % re-combine if multiple functions
    
    openParens = argStr == '(';
    closParens = argStr == ')';
    parenDepth = cumsum(openParens) - cumsum(closParens);
    commas = argStr == ',';
    breaks = parenDepth == 0 & commas == 1;
    breakInds = [find(breaks)-1 length(breaks)];    
    breakIndsDiff = [breakInds(1) (breakInds(2:end) - breakInds(1:end-1))];
    
    args = mat2cell(argStr, 1, breakIndsDiff);
    
    arguments = cell(length(args),1);
    for iArg = 1:length(args)
        if args{iArg}(1) == ','; args{iArg} = args{iArg}(2:end); end
        arguments{iArg} = cbd.private.fredpull(args{iArg}, opts);
    end
    
    fnName = strrep(lower(fnName), '%', 'Pct');
    transform_fn = str2func(['cbd.' fnName]);
    
    try
        output = transform_fn(arguments{:});
    catch
        error('fred:fredpull:function', ['Undefined transformation ' upper(fnName) '.']);
    end

elseif ~isempty(str2double(strIn)) && ~isnan(str2double(strIn))
    output = str2double(strIn);

else   % FRED Series
    output = cbd.private.fredseries(strIn, opts);
end