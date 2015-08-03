function avg = movv(data, wind)
%MOVV Calculates the moving average over a given window
%
% avg = MOVV(data, wind) calculates the moving average of data over the
% past wind periods.

% David Kelley, 2014

%% Check inputs
assert(nargin == 2);

if istable(data)
    %validateattributes(data, {'table'}, {'column'});
    tabOut = true;
    rnames = data.Properties.RowNames;
    vName = data.Properties.VariableNames;
    data = data{:,:};
else
    tabOut = false;
    %validateattributes(data, {'numeric'}, {'column'});
end
%validateattributes(window, {'numeric'}, {'scalar', 'integer', '>=', 0}); 
nVar = size(data, 2);

if wind > length(data)
    warning('movv:window', 'Window is larger than the length of the vector.');
end

%% Offset
sum = data;
for iLag = 1:wind-1
    sum = sum + cbd.lag(data, iLag);
end
avg = sum ./ (wind);

%% Handle output
if tabOut
    varNames = cellfun(@horzcat, repmat({['ma' num2str(wind)]}, 1, nVar), vName, 'UniformOutput', false);
    avg = array2table(avg, 'RowNames', rnames, 'VariableNames', varNames);
end

end

