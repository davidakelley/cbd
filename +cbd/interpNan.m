function y = interpNan(x, interp, extrap)
% INTERPNAN Runs the interp1 function on the NaN values in a given vector. 
% An optional second argument passes the interpolation type to interp1.
% An optional (boolean) thrid argument specifies whether to extrapolate
% beyond the end data points (default false).

% David Kelley, 2014

if nargin == 1
    interp = 'linear';
end
if nargin < 3
    extrap = false;
end

if isa(x, 'table')
    d = table2array(x);
    tableFlag = true;
else
    tableFlag = false;
    d = x;
end

y = nan(size(d));
for iCol = 1:size(d, 2)
    nanLog = isnan(d(:,iCol));
    nanInd = find(nanLog);
    values = d(~nanLog, iCol);
    valueInd = find(~nanLog);

    y(:,iCol) = d(:,iCol);
    if length(valueInd) == 1
      warning('Unable to interpolate series with only 1 non-nan value.');
      continue;
    end
    
    if extrap
        y(nanInd, iCol) = interp1(valueInd, values, nanInd, interp, 'extrap');
    else
        y(nanInd, iCol) = interp1(valueInd, values, nanInd, interp);
    end

end

if tableFlag
    y = array2table(y, 'VariableNames', x.Properties.VariableNames, 'RowNames', x.Properties.RowNames);
end

end