function avg = mova(data, wind)
% MOVA Calculates the annualized moving average over a given window
%
% avg = MOVA(data, wind) calculates the moving average of data over the
% past wind periods.

% David Kelley, 2014

%% Check inputs
assert(nargin == 2);

if istable(data)
    %validateattributes(data, {'table'}, {'column'});
    tabOut = true;
    rNames = data.Properties.RowNames;
    dates = datenum(rNames);
    vName = data.Properties.VariableNames;
    data = data{:,:};
else
    tabOut = false;
    %validateattributes(data, {'numeric'}, {'column'});
end
%validateattributes(window, {'numeric'}, {'scalar', 'integer', '>=', 0}); 
nVar = size(data, 2);

if wind > length(data)
    warning('mova:window', 'Window is larger than the length of the vector.');
end

%% Offset
sum = data;
for iLag = 1:wind-1
    sum = sum + cbd.lag(data, iLag);
end
[~, pers] = cbd.private.getFreq(dates);

avg = sum .* (pers / wind);

%% Handle output
if tabOut
    varNames = cellfun(@horzcat, repmat({['ma' num2str(wind)]}, 1, nVar), vName, 'UniformOutput', false);
    avg = array2table(avg, 'RowNames', rNames, 'VariableNames', varNames);
end

end

