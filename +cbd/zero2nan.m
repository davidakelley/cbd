function cbdTable = zero2nan(cbdTable)
% ZERO2NAN Takes a cbd table and converts the zeros to NANs

% David Kelley, 2017

tempTable = cbdTable{:,:};
tempTable(tempTable==0) = nan;

cbdTable{:,:} = tempTable;