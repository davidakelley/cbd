function output = haverpull(strIn, opts)
%HAVERPULL Evaluate a Haver expression
%
% Evaluate an expression of Haver series and functions, returning a table.

% David Kelley, 2015

%% Check for illegal charactars
illegalChar = '"''';
regexOut = regexpi(strIn, illegalChar);
assert(isempty(regexOut), 'haver:haverpull:invalidInput');

%% Treat input as either a Haver series, a scalar, or a function of those two
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
        arguments{iArg} = cbd.private.haverpull(args{iArg}, opts);
    end
    
    fnName = strrep(lower(fnName), '%', 'Pct');
    haver_fn = str2func(['cbd.' fnName]);
    
    try
        output = haver_fn(arguments{:});
    catch
        error('haver:haverpull:function', ['Undefined transformation ' upper(fnName) '.']);
    end

elseif ~isempty(str2double(strIn)) && ~isnan(str2double(strIn))
    output = str2double(strIn);

else   % Haver Series
    output = cbd.private.haverseries(strIn, opts);
end