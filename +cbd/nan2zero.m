function cbdTable = nan2zero(cbdTable)
% NAN2ZERO Takes a cbd table and converts the NANs to zeros

% David Kelley, 2017

tempTable = cbdTable{:,:};
tempTable(isnan(tempTable)) = 0;

cbdTable{:,:} = tempTable;