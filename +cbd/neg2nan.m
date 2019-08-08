function cbdTable = neg2nan(cbdTable)
% NEG2NAN takes a cbd table and converts negative values to NANs.
%
% cbdTable = neg2nan(cbdTable)

% Ross Cole, 2019

tempTable = cbdTable{:,:};
tempTable(tempTable<0) = nan;

cbdTable{:,:} = tempTable;