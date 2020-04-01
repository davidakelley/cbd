function D = mdatenum(S)
%MDATENUM converts a character array of dates in a datenum
%
% USAGE
%   mydate = mdatenum('2010-10-30') % 734421
%
% zhang@zhiqiang.org, 2010
% David Kelley, 2015

if iscell(S)
    D = datenum(S);
elseif ischar(S)
    monInx = [12, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 8, 0, 0, 3, 0, 0, 4, 0, 0, 10, 5, 9, 0, 0, 7, 0, 6, 0, 0, 0, 0, 0, 11];
    tmp = sscanf(S, '%02d-%03c-%04d');
    D = datenummx(tmp(5), monInx(sum(tmp(2:4))-267), tmp(1));
elseif isnumeric(S)
    D = S;
end % if-iscell

end % function
