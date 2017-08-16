% YQMD retrievs the year, quarter, month, or day of a (vector of) serial dates.
% This is used for versions of Matlab prior to R2013a, before the 'year',
% 'quarter', 'month', and 'day' commands were introduced in Matlab.
%
% Usage: d = yqmd(d,type)
%
% type must be one of the following: 'year', 'semester', 'trimester',
% 'quarter', 'month' or 'm', 'day', 'weekday', 'hour', 'minute', 'second', or
% abbreviations thereof.
%
% NOTE: This file is part of the X-13 toolbox.
%
% Author : Yvan Lengwiler
% Date   : 2015-07-20

function  d = yqmd(d,type)
    d = datevec(d);
    legal = {'year','month','day','hour','minute','second', ...
        'quarter','trimester','semester','weekday'};
    if ~ischar(type)
        if type == 3                % quarter
            type = numel(legal)-3;
        elseif type == 4            % trimester
            type = numel(legal)-2;
        elseif type == 6            % semester
            type = numel(legal)-1;
        elseif type == 12           % month
            type = 2;
        end
    else
        if strcmp(type,'m'); type = 'month'; end
        type = validatestring(type,legal);  % check for valid type
        type = find(ismember(legal,type));  % determine position
    end
    if type == numel(legal)-3;      % 'quarter'
        d = d(:,2);
        d = floor((d-1)/3) + 1;
    elseif type == numel(legal)-2;  % 'trimester'
        d = d(:,2);
        d = floor((d-1)/4) + 1;
    elseif type == numel(legal)-1;  % 'semester'
        d = d(:,2);
        d = floor((d-1)/6) + 1;
    elseif type == numel(legal);    % 'weekday'
        d = weekday(datenum(d));
    else                            % all other types
        d = d(:,type);
    end
end
