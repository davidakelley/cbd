function [props, fname] = loadProps(section, seriesID)
%LOADPROPS loads the properties structure for a section
%
% If no seriesID is passed to LOADPROPS, then the function will return 
% a structure with the properties of all of the series in the section.
% Otherwise, only the specified series's properties are returned.
%
% INPUTS
%   section     ~ char, the name of the section
%   seriesID    ~ char, the name of the series to load in the section
%
% OUTPUTS
%   props       ~ structure, the properties from the section/seriesID
%   fname       ~ char, the name of the file where the props are stored
%
% WARNING: This function should NOT be called directly by the user
%
% David Kelley, 2015
% Santiago Sordo-Palacios, 2019

% Get the chidata directory
chidataDir = cbd.chidata.dir();

% Get the filename
fname = fullfile(chidataDir, [section '_prop.csv']);

% Check if it exists
found = isequal(exist(fname, 'file'), 2);
assert(found, ...
    'chidata:loadProps:notFound', ...
    'Properties file "%s" could not be found', fname);

% Read the table
propTable = readtable(fname, ...
    'ReadRowNames', true, ...
    'ReadVariableNames', true, ...
    'Delimiter', ',');
props = prop_table2struct(propTable);

% Return only one series if requested
if nargin == 2
    [hasSeries, loc] = ismember(seriesID, {props.Name});
    assert(hasSeries, ...
        'chidata:loadProps:missingSeries', ...
        'Series "%s" not found in section "%s"');
    props = props(:, loc);
end % if-nargin
    
end % function-loadProps

function props = prop_table2struct(propTable)
%PROP_TABLE2STRUCT transforms a properties table into a structure
%
% Santiago Sordo-Palacios, 2019

% Convert to structure
propCell = [propTable.Properties.VariableNames; table2cell(propTable)];
propNums = str2double(propCell);
propCell(~isnan(propNums)) = num2cell(propNums(~isnan(propNums)));
props = cell2struct( ...
    propCell, [{'Name'}; propTable.Properties.RowNames]);
props = props';

end % function