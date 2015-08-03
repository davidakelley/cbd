function disagg = disagg(data, newFreq, disaggType, extrap)
%DISAGG Disaggregates a data series to a higher frequency
% 
% agg = DISAGG(data, newFreq) disaggregates the data series to a 
% lower frequency specified by newFreq.
% 
% agg = DISAGG(data, newFreq, disaggType) allows the specification of how
% to fill the values in the disaggregation. The following options are
% supported: 
%       NAN - leave as NaN.
%       FILL - fill all new periods within the lower frequency period.
%       INTERP - interpolate the values using cbd.interpNan
% 
% agg = DISAGG(data, newFreq, disaggType, extrap) passes the extrap
% argument to cbd.interpNan. The last argument is ignored if a different
% disaggType is specified. 
% 
% See also AGG, GETFREQ, GENDATES

% David Kelley, 2014-2015

%% Check inputs
validateattributes(data, {'table'}, {'2d'});
[oldFreq, lowFper] = cbd.private.getFreq(data);
if strcmpi(oldFreq, newFreq)
    disagg = data;
    return
end

assert(strcmp(newFreq, 'Q') || strcmp(newFreq, 'M') || strcmp(newFreq, 'W') ...
    || strcmp(newFreq, 'D') || strcmp(newFreq, 'IRREGULAR'),...
    'disagg:freq', 'Frequency type not supported.');

if nargin < 4
    extrap = false;
end
if nargin < 3
    disaggType = 'nan';
else
    assert(strcmp(disaggType, 'FILL') || strcmp(disaggType, 'INTERP') || strcmp(disaggType, 'GROWTH') || strcmp(disaggType, 'NAN'), ...
    'disagg:aggType', 'Aggregation type not supported.');
end

if strcmpi(newFreq, 'IRREGULAR')
    disagg = data;
    return;
end

%% Compute 
if ~strcmpi(oldFreq, 'IRREGULAR');
    % Make sure to fill out all of old first period (ie, get Jan-Mar and not
    % just Mar if start with Q1)
    newStartDate = cbd.private.startOfPer(data.Properties.RowNames{1}, oldFreq);
else
    % Hopeless if you can't get the 
    newStartDate = datestr(datenum(data.Properties.RowNames{1}) - max(lowFper));
end

disagg_dates = cbd.private.genDates(...
    newStartDate, ...
    cbd.private.endOfPer(data.Properties.RowNames{end}, newFreq), ...
    newFreq);

% Find end of low frequency period in high frequency
lowFdates = cellfun(@datenum, data.Properties.RowNames);
hiFInd = nan(size(lowFdates));
for iloF = 1:length(lowFdates)
    matchInd = find(disagg_dates <= lowFdates(iloF), 1, 'last');
    if ~isempty(matchInd) 
        hiFInd(iloF) = matchInd;
    else 
        hiFInd(iloF) = length(disagg_dates);
    end
end

disagg_data = nan(size(disagg_dates, 1), size(data, 2));
disagg_data(hiFInd, :) = data{:,:};
disagg = array2table(disagg_data, 'RowNames', cellstr(datestr(disagg_dates)), ...
    'VariableNames', data.Properties.VariableNames);

switch upper(disaggType)
    case 'FILL'
        % Fill each period with the same value
        for iInd = size(hiFInd,1):-1:1
            if iInd == 1
                startInd = 1;
            else
                startInd = hiFInd(iInd-1)+1;
            end
            disagg{startInd:hiFInd(iInd),:} = disagg{hiFInd(iInd),:};
        end
        
    case 'INTERP'
        disagg = cbd.interpNan(disagg, 'linear', extrap);
        
    case 'GROWTH'
        % Create same level at end of each period, smooth by using fixed
        % growth rate within a lower frequency period. 
        % % If extrapolating, continue last period's growth rate (%TODO)
        [~, hiFper] = cbd.private.getFreq(newFreq);
        perGap = hiFper / lowFper;      % Number of new periods per old period
        
        grData = cbd.addition(cbd.division(cbd.diffPct(data),100),1);
        grData{1,:} = 1;
        grDisagg = nan(size(disagg));
        for iLag = 0:perGap-1
            grDisagg(hiFInd - iLag, :) = grData{:,:} .^ (1/perGap);
        end
        cumGr = cumprod(grDisagg);
        cumGr(1:hiFInd(1)-1) = nan;
        disagg{hiFInd(1)+1:end,:} = cumGr(hiFInd(1)+1:end) * disagg{hiFInd(1),:};
        
    case 'NAN'
end

end
