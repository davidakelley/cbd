function absData = abs(data)
% ABS Takes the absolute value of a series
%
% absData = ABS(data) returns theabsolute value of data.

% David Kelley, 2014

%% Check inputs
if istable(data)
    rnames = data.Properties.RowNames;
    vnames = data.Properties.VariableNames;
    tabOut = true;
    data = data{:,:};
else
    tabOut = false;
    validateattributes(data, {'numeric'}, {'2d'});
end

absData = abs(data);

if tabOut
   absData = array2table(absData, 'RowNames',  rnames, 'VariableNames', vnames);
end