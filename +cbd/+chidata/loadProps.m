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

% Convert to structure
propCell = [propTable.Properties.VariableNames; table2cell(propTable)];
propNums = str2double(propCell);
propCell(~isnan(propNums)) = num2cell(propNums(~isnan(propNums)));
props = cell2struct( ...
    propCell, [{'Name'}; propTable.Properties.RowNames]);
props = props';

% Return only one series if requested
if nargin == 2
    seriesInd = strcmpi(seriesID, {props.Name});
    if sum(seriesInd) == 1
        props = props(:, seriesInd);
    elseif sum(seriesInd) > 1
        % NOTE: This outcome should not occur since MATLAB does not allow
        % for multiple identical variable names
        error('chidata:loadProps:duplicateSeries', ...
            'Multiple series found using "%s" in section "%s"', ...
            seriesID, section);
    else
        error('chidata:loadProps:missingSeries', ...
            'Series "%s" not found in section "%s"', ...
            seriesID, section);
    end % if-elseif
end % if-nargin
    
end % function-loadProps