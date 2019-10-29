function properties = loadChidataProp(sectionName)
% LOADCHIDATAPROP loads the properties structure for a section
%
% properties = loadChidataProp(sectionName) loads the structure from a
% given section.

% David Kelley, 2015

chidataDir = cbd.private.chidatadir();
propFile = fullfile(chidataDir, [sectionName '_prop.csv']);

if ~exist(propFile, 'file')
    properties = [];
    return
end

propTable = readtable(propFile, 'Delimiter', ',', ...
    'ReadRowNames', true, 'ReadVariableNames', true);

propCell = [propTable.Properties.VariableNames; table2cell(propTable)];

propNums = str2double(propCell);
propCell(~isnan(propNums)) = num2cell(propNums(~isnan(propNums)));

properties = cell2struct(propCell, [{'Name'}; propTable.Properties.RowNames]);

% not sure why this is neccessary, but it comes back the wrong shape
% without it. 
properties = properties'; 