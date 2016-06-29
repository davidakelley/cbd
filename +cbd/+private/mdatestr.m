function S = mdatestr(D)
% convert a date number to a string with format 'dd-mmm-yyyy'
%   mdatestr(73421)  % ans = '30-Oct-2014'
%
% David Kelley, 2015

if isempty(D)
    S = '';
    return;
end

if iscell(D)
    S = cell(size(D));
    for i = 1:numel(D)
        S{i} = cbd.private.mdatestr(D{i});
    end
    return;
end

if ~ischar(D)
    if min(D) > 1000 && max(D) < 693960
        D = D + 693960;
    end
    
    D = datevecmx(D);
%     S = sprintf('%04d-%02d-%02d', D(1), D(2), D(3));
    S = [reshape(sprintf('%02d', D(:,3)), 2, size(D,1))' ...
        repmat('-', size(D,1), 1) ...
        monthNames(D(:,2)) ...
        repmat('-', size(D,1), 1) ...
        reshape(sprintf('%04d', D(:,1)), 4, size(D,1))'];
elseif numel(D) == 11 && D(3) == '-' && D(7) == '-'
    S = D;
else
    S = formatdate(D);
end

end


function mnames = monthNames(monthnums)

months = ['Jan';'Feb';'Mar';'Apr';'May';'Jun';'Jul';'Aug';'Sep';'Oct';'Nov';'Dec'];
mnames = reshape(blanks(length(monthnums)*3),length(monthnums),3);
for iMonth = 1:size(months, 1)
   mnames(monthnums==iMonth, :) = repmat(months(iMonth, :), sum(monthnums==iMonth), 1); 
end

end