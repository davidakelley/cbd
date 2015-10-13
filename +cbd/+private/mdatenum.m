function D = mdatenum(S)
% usage
%  mdatenum('2010-10-30') % ans = 734421
%
% Copyright: zhang@zhiqiang.org, 2010
% Edited: David Kelley, 2015

if isnumeric(S)
  D = S;
elseif iscell(S)
  D = cellfun(@cbd.private.mdatenum, S);
else
  %{
    % monInx generated as follows:
    monList = {'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', ...
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'};
    monNums = cellfun(@sum, monList) - min(monSum) + 1
    monInx(monNums) = 1:12;
  %}
  monInx = [12, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 8, 0, 0, 3, 0, 0, 4, 0, 0, 10, 5, 9, 0, 0, 7, 0, 6, 0, 0, 0, 0, 0, 11]; 
  tmp = sscanf(S, '%02d-%03c-%04d');
  D = datenummx(tmp(5), monInx(sum(tmp(2:4))-267), tmp(1));
end