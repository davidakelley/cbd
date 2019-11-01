function [data, fname] = loadData(section, seriesID)
%LOADATA opens the data file for a given section in the chidataDir
%
% If no seriesID is passed to LOADDATA, then the function will return 
% a table with the data of all of the series in the section.
% Otherwise, only the specified series's data are returned.
%
% INPUTS:
%   section     ~ char, the name of the section
%   seriesID    ~ char, the name of the series to load in the section
%
% OUPTUS:
%   data        ~ table, the data from the section/seriesID
%   fname       ~ char, the name of the file where data is stored
%
% David Kelley, 2015
% Santiago I. Sordo-Palacios, 2019

% Get the chidata directory
chidataDir = cbd.chidata.dir();

% Get the filename
fname = fullfile(chidataDir, [section '_data.csv']);

% Check if it exists
found = isequal(exist(fname, 'file'), 2);
assert(found, ...
    'chidata:loadData:notFound', ...
    'Data file "%s" could not be found', fname);

% Open the data file
if verLessThan('matlab', '9.1')
    data = readtable(fname, ...
        'ReadRowNames', true);
else
    data = readtable(fname, ...
        'Delimiter', ',', ...
        'HeaderLines', 0, ...
        'ReadVariableNames', true, ...
        'ReadRowNames', true, ...
        'EndOfLine', '\n', ...
        'DatetimeType', 'text');
end % if-else

% Return only one series if requested
if nargin == 2
    seriesInd = strcmpi(seriesID, data.Properties.VariableNames);
    if sum(seriesInd) == 1
        data = data(:, seriesInd);
    elseif sum(seriesInd) > 1
        error('chidata:loadData:duplicate', ...
            'Multiple series found using "%s" in section "%s"', ...
            seriesID, section);
    else
        error('chidata:loadData:missing', ...
            'Series "%s" not found in section "%s"', ...
            seriesID, section);
    end % if-elseif
end % if-nargin

end % function-loadData