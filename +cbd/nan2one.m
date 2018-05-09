function cbdTable = nan2one(cbdTable)
% NAN2ONE Takes a cbd table and converts the NANs to zeros

% David Kelley, 2017

tempTable = cbdTable{:,:};
tempTable(isnan(tempTable)) = 1;

cbdTable{:,:} = tempTable;