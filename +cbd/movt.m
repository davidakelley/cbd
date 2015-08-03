function sum = movt(data, wind)
%MOVT Calculates the moving sum over a given window
%
% avg = MOVT(data, wind) calculates the moving sum of data over the
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

%% Handle output
if tabOut
    varNames = cellfun(@horzcat, repmat({['ma' num2str(wind)]}, 1, nVar), vName, 'UniformOutput', false);
    sum = array2table(sum, 'RowNames', rnames, 'VariableNames', varNames);
end

end

