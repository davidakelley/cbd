function avg = movv(data, wind, nanFlag)
% movv Calculates the moving average over a given window
%
%   avg = movv(data, wind) calculates the moving average of data over the
%   past wind periods.
%
%   avg = movv(...,nanFlag) specifies how NaN (Not-A-Number) values are 
%   treated. The default is 'includenan':
%
%   'includenan' - the moving mean of a wind length vector containing NaN values is also NaN.
%   'omitnan'    - the moving mean of a wind length vector containing NaN values is the mean 
%                  of all its non-NaN elements. If all elements are NaN,
%                  the result is NaN.

% David Kelley, 2014
% Vamsi Kurakula, 2019

%% Check inputs
assert(nargin >= 2);

if nargin == 3      
   assert(any(ismember(nanFlag, {'includenan' 'omitnan'})),...
        'movv:inputs','Invalid nanflag. Option must be ''includenan'' or ''omitnan''');
else
    nanFlag = 'includenan';
end % Evaluate Flag

if istable(data)
    tabOut = true;
    rnames = data.Properties.RowNames;
    vName = data.Properties.VariableNames;
    data = data{:,:};
else
    tabOut = false;    
end


if wind > length(data)
    warning('movv:window', 'Window is larger than the length of the vector.');
end

%% Offset
[nRow, nVar] = size(data);
avg = zeros(nRow, nVar);

for iData = 1:nVar
    
    sum = zeros(nRow,wind);
    sum(:,1) = data(:,iData);

    for iLag = 1:wind-1
        sum(:,iLag + 1) = cbd.lag(sum(:,1), iLag);
    end

    avg(:,iData) = mean(sum, 2, nanFlag);

end
 
%% Handle output
if tabOut
    varNames = cellfun(@horzcat, repmat({['ma' num2str(wind)]}, 1, nVar), vName, 'UniformOutput', false);
    avg = array2table(avg, 'RowNames', rnames, 'VariableNames', varNames);
end

end

