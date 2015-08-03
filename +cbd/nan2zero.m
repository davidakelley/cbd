function cbdTable = nan2zero(cbdTable)
%NAN2ZERO Takes a cbd table and converts the NaNs to zeros

tempTable = cbdTable{:,:};
tempTable(isnan(tempTable)) = 0;

cbdTable{:,:} = tempTable;