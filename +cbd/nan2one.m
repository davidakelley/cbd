function cbdTable = nan2one(cbdTable)
%NAN2ONE Takes a cbd table and converts the NaNs to zeros

tempTable = cbdTable{:,:};
tempTable(isnan(tempTable)) = 1;

cbdTable{:,:} = tempTable;