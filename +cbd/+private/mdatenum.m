function D = mdatenum(S)
% usage 
%  mdatenum('2010-10-30') % ans = 734421
%
% Copyright: zhang@zhiqiang.org, 2010

if isnumeric(S)
    if S > 693960  
        D = S - 693960;
    else
        D = S;
    end
else
    tmp = sscanf(S, '%02d-%03c-%04d');
    D = datenummx(tmp(1), tmp(2), tmp(3)) - 693960;
end