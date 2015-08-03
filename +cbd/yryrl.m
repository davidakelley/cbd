function yChange = yryrl(data, dates)
%YRYRL Computes the year-over-year log change in a series
% 
% yChange = YRYRL(data) computes the year-over-year log change in a data series
%
% yChange = YRYRL(data, dates) uses serial dates to compute the change
%
% yChange = YRYRL(data, freq)  uses a character string freq to compute
% the change (either Y, Q, or M).

% David Kelley, 2015

%% Validate inputs
if istable(data)
    %validateattributes(data, {'table'}, {'column'});
    rNames = data.Properties.RowNames;
    dates = datenum(rNames);
    vName = data.Properties.VariableNames;
    returnTab = true;
    data = data{:,:};
else
    %validateattributes(data, {'numeric'}, {'column'});
    validateattributes(dates, {'numeric', 'char'}, {'column'});
    returnTab = false;
end
nVar = size(data, 2);

if ischar(dates)
    assert(length(dates) == 1, 'Character string must be only one character.');
else
    assert(size(data, 1) == size(dates, 1), 'Data timing does not match dates.');
end

%% Compute

[~, freq] = cbd.private.getFreq(dates);

yChange = 100 * (log(data) - cbd.lag(log(data), freq));

if returnTab
    varNames = cellfun(@horzcat, repmat({'yryrPct'}, 1, nVar), vName, 'UniformOutput', false);
    yChange = array2table(yChange, 'RowNames', rNames, 'VariableNames', varNames);
end
