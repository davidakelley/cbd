function series = list
% List CHIDATA series

% David Kelley, 2015

chidataDir = cbd.private.chidatadir;

seriesList = readtable(fullfile(chidataDir, 'index.csv'));

% Opens each file and reads the descriptions
series = {};
files = unique(seriesList{:,2});
for iF = 1:length(files)
  if verLessThan('matlab', '9.1')
    readData = readtable(fullfile(chidataDir, [files{iF} '_prop.csv']), ...
      'ReadRowNames', true);
  else
    readData = readtable(fullfile(chidataDir, [files{iF} '_prop.csv']), ...
      'ReadRowNames', true, 'ReadVariableNames', true);
  end
  
  seriesNames = readData.Properties.VariableNames;
  descripInd = find(strcmpi(readData.Properties.RowNames, 'Description'), 1);
  if ~isempty(descripInd)
    descrips = readData{descripInd,:};
  else
    descrips = repmat({''}, [1 length(seriesNames)]);
  end
  series = [series; [seriesNames' descrips'] ]; %#ok<AGROW>
end
