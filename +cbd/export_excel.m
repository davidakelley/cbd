function export_excel(cbdData, filename, sheetname)
%EXPORT_EXCEL Exports a cbd table to an Excel file
% 
% export_excel(cbdData, filename) writes cbdData to filename
%
% export_excel(cbdData, filename, sheetname) writes to the sheet sheetname

% David Kelley, 2015

%% Export
cbdData.Properties.DimensionNames{1} = 'Date';
if nargin < 3
    writetable(cbdData, filename, 'WriteRowNames', true);
else
    writetable(cbdData, filename, 'WriteRowNames', true, 'Sheet', sheetname);
end
