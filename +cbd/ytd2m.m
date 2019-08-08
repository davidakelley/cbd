function month2month = ytd2m(data)
% YTD2M converts year-to-date values to monthly or quarterly changes.
%
% Converts YTD values to monthly or quarterly changes for observations 
% where month~=January, or quarter!=Q1, respectively. 
%
% month2month = ytd2m(data) returns:
%    the first differenced series when month~=January (Q!=1)
%    the level of the series when month==January (Q==1)
%
% Only works for monthly and quarterly series.

% Ross Cole, 2019

%% Check inputs
[data, rNames, vNames] = cbd.private.inputCBDdata(data);
nVar = size(data, 2); 

% Get frequency - must be monthly or quarterly
freq = cbd.private.getFreq(datenum(rNames));
assert(freq=='M' || freq=='Q', 'Data must be monthly or quarterly.');
  
%% Differenced
firstDiff = data - cbd.lag(data, 1);

% Create new output variable with differences for month!=1 or quarter!=1
if freq=='M'
    firstDiff(month(rNames)==1) = data(month(rNames)==1);
else
    firstDiff(quarter(rNames)==1) = data(quarter(rNames)==1);
end

varNames = cellfun(@horzcat, repmat({'ytd2m'}, 1, nVar), vNames, 'UniformOutput', false);
month2month = array2table(firstDiff, 'RowNames', rNames, 'VariableNames', varNames);

end
