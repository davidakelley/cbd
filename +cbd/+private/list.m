function series = list
% List CHIDATA series

% David Kelley, 2015

chidataDir = 'O:\PROJ_LIB\Presentations\Chartbook\Data\CHIDATA\';

seriesList = readtable([chidataDir 'index.csv']);

% Opens each file and reads the descriptions
series = {};
files = unique(seriesList{:,2});
for iF = 1:length(files)
    readData = readtable([chidataDir files{iF} '_prop.csv'], 'ReadRowNames', true);
    seriesNames = readData.Properties.VariableNames;
    descripInd = find(strcmpi(readData.Properties.RowNames, 'Description'), 1);
    descrips = readData{descripInd,:};
    series = [series; [seriesNames' descrips'] ]; %#ok<AGROW>
end
