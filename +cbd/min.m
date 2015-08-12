function minned = min(data, sDate, eDate)
%MIN Returns the minnimum values of a dataset over the given period
%
% minned = min(data) returns the observations for which the minimum value
% was recorded over the whole sample
%
% minned = min(data, sDate, eDate) returns the min between the start date
% and end date (inclusive)
%
% minned = min(data, sDate) or minned = min(data, [], eDate) returns the 
% min after or before the given date (inclusive)

% David Kelley, 2014

%% Check inputs
validateattributes(data, {'table'}, {'2d'});

rNames = datenum(data.Properties.RowNames);

if nargin < 2 || isempty(sDate)
    sDate = datestr(rNames(1));
end

if nargin < 3 || isempty(eDate)
    eDate = datestr(rNames(end));
end

if ischar(sDate)
    sDate = datenum(sDate);
elseif sDate < datenum(1800,1,1)
    % Treat sDate as code that counts backward
    sDate = datenum(data.Properties.RowNames{end-sDate});
end
if ischar(eDate)
    eDate = datenum(eDate);
end

validdates = rNames >= sDate & rNames <= eDate;
validdata = data(validdates, :);

[~, iMin] = min(validdata{:,:}, [], 1);

minned = validdata(iMin, :);
