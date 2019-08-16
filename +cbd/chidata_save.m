function chidata_save(sectionName, data, properties, varargin)
%CHIDATA_SAVE Saves a data series to the CHIDATA folder
%
% The CHIDATA folder contains data formatted so that it can be treated as if 
% it were its own database and pulled via cbd.data or cbd.expression. Series 
% in CHIDATA are denoted "series@CHIDATA". 
%
% Each series added to CHIDATA must be put in a 'section'. A section is a 
% collection of data that are all updated together. All series in a section 
% must have the same frequency and are treated as having the same start and 
% end dates (though missing values can be inputted). 
%
% It is recommended that the underlying section files not be modified by hand.
% If errors occur with a CHIDATA series, delete the section files and resave 
% them from the source data. 
%
% chidata_save(sectionName, data) updates the section file with the data
% contained in data.
%
% chidata_save(sectionName, data, properties) saves the data to a new
% section of CHIDATA and updates (or creates) a properties file with the
% properties given.
%
% The properties structure has a length equal to the number of series in
% the data being saved and includes the following fields, which can also
% be generated using the chidata_prop function instead:
%   Source      ~ char, the source of the data
%   Frequency   ~ char, the frequency of the data
%   Magnitude   ~ double, the power to raise the series to in order to 
%               return the natural number
%   AggType     ~ char, the method used when aggregating the series
%   DataType    ~ char, the type of data being stored

% David Kelley, 2014-2019

chidataDir = cbd.private.chidatadir();
indexFileName = fullfile(chidataDir, 'index.csv');
dataFileName = fullfile(chidataDir, [sectionName  '_data.csv']);
propertiesFileName = fullfile(chidataDir, [sectionName '_prop.csv']);

assert(istable(data));

inP = inputParser;
inP.addParameter('revisionTolerance', 1e-12, @isnumeric);
inP.parse(varargin{:});
opts = inP.Results;

%% Make sure index.csv has the series in it.
indexTab = readtable(indexFileName);
writeFile = false;
seriesNames = data.Properties.VariableNames;

indexSeries = indexTab.Series;

inIndex = @(str) any(strcmpi(str, indexSeries));
seriesInDict = cellfun(inIndex, seriesNames);

if any(~seriesInDict) && ~all(~seriesInDict)
  warning('chidata_save:addSeries', ['Adding series to section ' sectionName]);
end

if any(~seriesInDict)
  indexTab = [indexTab; ...
    table(seriesNames(~seriesInDict)', repmat({sectionName}, [sum(~seriesInDict) 1]), ...
    'VariableNames', {'Series', 'Section'})];
  writeFile = true;
end

% Does it have the right section? If not, change it!
sectionNames = indexTab.Section;
getSection = @(seriesID) sectionNames{strcmpi(seriesID, indexTab.Series)};
for iSer = 1:length(seriesNames)
  if ~strcmpi(getSection(seriesNames{iSer}), sectionName)
    promptOverwrite(true, ['Change section of ' seriesNames{iSer} '?']);
    indexTab{strcmpi(seriesNames{iSer}, indexSeries), 2} = {sectionName};
    writeFile = true;
  end
end

if writeFile
  writetable(indexTab, indexFileName);
end


%% Check consistency with current data
% Will prompt for overwrite if new data is shorter, revises any
% previous data, or adds or removes series to the section.

try
  if ~verLessThan('matlab', '9.1')
    oldData = readtable(dataFileName, 'ReadRowNames', true, 'DatetimeType', 'text');
  else
    oldData = readtable(dataFileName, 'ReadRowNames', true);
  end
catch exception
  assert(exist('properties', 'var')>0, ...
    'Attempted to save series without properties file without supplying neccessary properties.');
  warning('chidata_save:newFile', ['New file created for ' sectionName]);
end

if ~exist('exception', 'var') || isempty(exception)
  promptOverwrite(datenum(data.Properties.RowNames{end}) < datenum(oldData.Properties.RowNames{end}), ...
    'New data ends prior to old data.');
  promptOverwrite(datenum(data.Properties.RowNames{1}) ~= datenum(oldData.Properties.RowNames{1}), ...
    'New data does not begin on same date as old data.');
  promptOverwrite(size(oldData,1) > size(data,1), 'New data history is shorter than old.');
  promptOverwrite(size(oldData,2) > size(data,2), 'New data has fewer series.'); % -1 for row column
  promptOverwrite(size(oldData,2) < size(data,2), 'New data has additional series.');
  
  minLen = min(size(oldData, 1), size(data,1));
  minWid = min(size(oldData, 2), size(data,2));
  equalArray = abs(oldData{1:minLen, 1:minWid} - data{1:minLen, 1:minWid}) < opts.revisionTolerance;
  nanArray = arrayfun(@isnan, oldData{1:minLen, 1:minWid}) | arrayfun(@isnan, data{1:minLen, 1:minWid});
  promptOverwrite(~all(equalArray | nanArray), ['New data revises old data. (' sectionName ')']);
end

%% Write data
writetable(data, dataFileName, 'WriteRowNames', true);

%% Properties File
if nargin > 2 && ~isempty(properties)
  % Check for consistency with old properties file
  oldProp = cbd.private.loadChidataProp(sectionName);
  if ~isempty(oldProp)
    oldProp = rmfield(oldProp, {'Name','DateTimeMod'});
    promptOverwrite(~isequal(oldProp, properties), 'Properties changed from existing file.');
  end
  
  % Create table version of properties
  for iProp = 1:length(properties)
    properties(iProp).DateTimeMod = datestr(now);
  end
  propCell = squeeze(struct2cell(properties));
  assert(all(~any(cellfun(@strcmp, propCell, repmat({','}, size(propCell))))), ...
    'Property names cannot contain commas.');
  cellNames = fieldnames(properties);
  propTable = cell2table(propCell, 'RowNames', cellNames, 'VariableNames', data.Properties.VariableNames);
  
  % Write data
  writetable(propTable, propertiesFileName, 'WriteRowNames', true);
end

end


function promptOverwrite(condition, msg)
% Asks for user to confirm writing data in potential dangerous situations.

if condition
  disp(msg);
  confirm = input('Overwrite? (y/n)>> ', 's');
  
  if ischar(confirm) && strcmpi(confirm(1),'y')
    disp('Continuing...');
  else
    error('chidata_save:user', 'User halted execution.');
  end
end


end