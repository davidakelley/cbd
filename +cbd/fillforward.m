function datatab = fillforward(datatab)
%FILLFORWARD Extends a series forward using the last observed value

% outData = FILLFORWARD(series) fills any nan value at the end of datatab
% with the last observed value for each series

% David Kelley, 2016

%% Add back levels off of growth rates

for iSer = 1:size(datatab, 2)
  iData = datatab{:,iSer};
  lastLev = find(~isnan(iData), 1, 'last');
  
  datatab{lastLev+1:end,iSer} = datatab{lastLev,iSer};
end
