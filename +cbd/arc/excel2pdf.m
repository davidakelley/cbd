function status = excel2pdf(pdfName, fileName, sheet, cellRange)
%EXCEL2PDF Outputs an Excel file to PDF.
% 
%   EXCEL2PDF(pdfName, fileName) outputs the first sheet of the Excel file
%   to a PDF.
%
%   EXCEL2PDF(pdfName, fileName, sheet) outptus the sheet specified by
%   linear index or by name to PDF.
%
%   EXCEL2PDF(pdfName, fileName, sheet, cellRange) outputs the range
%   provided, provided as a string such as 'A1:B5'
%
%   status = EXCEL2PDF(...) returns a status flag. A flag of 0 indicates
%   successful output, while a 1 indicates the file was not created.
%   Including an output also supresses opening the PDF when created.

% Copyright: David Kelley, 2014

if nargin < 4
    cellRange = [];
end
if nargin < 3
    sheet = 1;
end

if isempty(fileparts(pdfName))
    pdfName = [pwd filesep pdfName];
end

xlApp = actxserver('Excel.Application');
wrkbks = xlApp.Workbooks;
xlApp.DisplayAlerts = false;

try
    xlFile = wrkbks.Open(fileName);
catch
    status = 1;
    warning('excel2pdf:excelOpen', 'Excel file could not be opened. PDF not created.');
    xlApp.Quit;
    return
end

sheets = xlFile.Sheets;
sh1 = sheets.Item(sheet);

if ~isempty(cellRange)
    cells = strsplit(cellRange, ':');
    dboardRng = sh1.get('Range', cells{1}, cells{2});
    dboardRng.ExportAsFixedFormat(0, pdfName);
else
    sh1.ExportAsFixedFormat(0, pdfName);
end

xlFile.Save;
xlFile.Close;
xlApp.DisplayAlerts = true;

xlApp.Quit;
xlApp.delete;

status = 0;

if nargout == 0
    open(pdfName);
end