classdef xlsfile < handle
    %XLSFILE Class representing an Excel file.
    %
    % To open an Excel file, call the class constructor with the file name.
    % When you are done with the file, call xlFile.close to close the file.
    % The Excel file will also be closed if the handle is deleted or goes
    % out of scope. 
    %
    % The handle object holds the file name and sheet names as properties,
    % as well as the Excel COM object and the workbook object if you are
    % inclined to mess with them directly. 
    %
    % SYNTAX:
    % xlFile = XLSFILE(fileName) opens an Excel file for reading or writing. 
    %
    % xlFile = XLSFILE(fileName, readOnly) opens an Excel file with the
    % boolean option readOnly specifying whether or not the file is readable.
    %
    % Once a file is open, the syntax should mirror that for xlsread and
    % xlswrite with the first argument removed:
    %   xlData = xlFile.read would read the first sheet of the open Excel file. 
    %   xlData = xlFile.read(2, 'A1:B5') would read the specified range of
    %       the second sheet of the open Excel file. 
    %   xlFile.write(matData) would write matData to the first sheet of the file.
    %   xlFile.write(matData, 2) would write matData to the second sheet of the file.
    %
    % xlFile.close will close the open file. 
    %
    % xlFile.isOpen will return a boolean response of whether or not the
    % file is still open.
    
    % David Kelley, 2014 (with credit to TMW for many functions)

    properties
        file;
        sheets;
        xlApp;
        wkBook;
    end
    properties(Hidden = true)
        ext;
    end
    
    methods
        function [obj, status] = xlsfile(file, readOnly)
            if nargin < 1 || isempty(file)
                error(message('MATLAB:xlsread:FileName'));
            end
            if ~ischar(file)
                error(message('MATLAB:xlsread:InvalidFileName'));
            end
            if nargin < 3 || isempty(readOnly)
                readOnly = false;
            end
            
            obj.xlApp = actxserver('Excel.Application');
            obj.open(file, readOnly);
            obj.info;
        end
        
        function open(obj, file, readOnly) 
            % MathWorks openExcelWorkbook mixed with elements from xlswrite
            
            % Opens an Excel Workbook and checks for the correct format.
            %   Copyright 1984-2012 The MathWorks, Inc.
            
            if (nargin < 2 || isempty(file)) && ~isempty(obj.file)
                obj.xlApp = actxserver('Excel.Application');
                newWb = false;
            else
                newWb = obj.procFileName(file);
            end
            
            if  nargin < 3 || isempty(readOnly)
                readOnly = false;
            end
            
            function WorkbookActivateHandler(varargin)
                workbook = varargin{3};
            end
            
            if ~newWb
                obj.xlApp.DisplayAlerts = 0;
                % It is necessary to wait for the workbook to actually be opened, as
                % the call to Open with an output argument is asynchronous. Using a
                % handler ensures that the handler is called before the call to Open
                % returns, thus ensuring that the interface is the right interface.
                registerevent(obj.xlApp,{'WorkbookActivate', @WorkbookActivateHandler});

                obj.xlApp.workbooks.Open(obj.file, 0, readOnly);

                format = obj.waitForValidWorkbook(workbook);
                if strcmpi(format, 'xlCurrentPlatformText')
                    throwAsCaller(MException(message('MATLAB:xlsread:FileFormat', obj.file)));
                end
                obj.wkBook = workbook;
            end
            
            if obj.wkBook.ReadOnly && ~readOnly
                warning('xlsfile:readOnly', 'Excel file opened read only.');
            end
        end
        
        function close(obj) % MathWorks xlsCleanup 
            % xlsCleanup helps clean up after the xlsread COM implementation.
            %
            %   See also XLSREAD, XLSWRITE, XLSFINFO.
            
            %   Copyright 1984-2012 The MathWorks, Inc.
            
            % Suppress all exceptions
            try                                                                        %#ok<TRYNC> No catch block
                %Turn off dialog boxes as we close the file and quit Excel.
                obj.xlApp.DisplayAlerts = 0;
                % Explicitly close the file just in case.  The Excel API expects just the
                % filename and not the path.  This is safe because Excel also does not
                % allow opening two files with the same name in different folders at the
                % same time.
                %[~, name, ext] = fileparts(obj.filePath);
                %fileName = [name ext];
                obj.wkBook.Close(false);
            end
            obj.xlApp.Quit;
            obj.xlApp.delete;
        end
        
        function delete(obj)
            if obj.isOpen
                obj.close
            end
        end
        
        function [numericData, textData, rawData, customOutput] = read(obj, sheet, range)
            Sheet1 = 1;
            if nargin < 2
                sheet = Sheet1;
                range = '';
            elseif nargin < 3
                range = '';
            end
            
            if nargin > 1
                % Verify class of sheet parameter
                if ~ischar(sheet) && ...
                        ~(isnumeric(sheet) && length(sheet)==1 && ...
                        floor(sheet)==sheet && sheet >= -1)
                    error(message('MATLAB:xlsread:InvalidSheet'));
                end
                
                if isequal(sheet,-1)
                    range = ''; % user requests interactive range selection.
                elseif ischar(sheet)
                    if ~isempty(sheet)
                        % Parse sheet and range strings
                        if ~isempty(strfind(sheet,':'))
                            % Range was specified in the 2nd input argument named sheet
                            % Swap them and ignore the third argument.
                            if nargin == 3 || ~isempty(range)
                                warning(message('MATLAB:xlsread:thridArgument'));
                            end
                            range = sheet;
                            sheet = Sheet1;% Use default sheet.
                        end
                    else
                        sheet = Sheet1; % set sheet to default sheet.
                    end
                end
            end
            if nargin > 2
                % verify class of range parameter
                if ~ischar(range)
                    error(message('MATLAB:xlsread:InvalidRange'));
                end
            end

            %try
                [numericData, textData, rawData, customOutput] = obj.xlsreadCOM(sheet, range);
%             catch exception
%                 if isempty(exception.identifier)
%                     exception = MException('MATLAB:xlsreadold:FormatError','%s', exception.message);
%                 end
%                 throw(exception);
%             end            
        end

        function [success,theMessage] = write(obj,data,sheet,range)
            % Set default values.
            Sheet1 = 1;
            if nargin < 3
                sheet = Sheet1;
                range = '';
            elseif nargin < 4
                range = '';
            end
            
            if nargout > 0
                success = true;
                theMessage = struct('message',{''},'identifier',{''}); %#ok<NASGU>
            end
            
            % Check for empty input data
            if isempty(data)
                error(message('MATLAB:xlswrite:EmptyInput'));
            end
            
            % Check for N-D array input data
            if ndims(data)>2 %#ok<ISMAT>
                error(message('MATLAB:xlswrite:InputDimension'));
            end
            
            % Check class of input data
            if ~(iscell(data) || isnumeric(data) || ischar(data)) && ~islogical(data)
                error(message('MATLAB:xlswrite:InputClass'));
            end
            
            % convert input to cell array of data.
            if iscell(data)
                A=data;
            else
                A=num2cell(data);
            end
            
            if nargin > 2
                % Verify class of sheet parameter.
                if ~(ischar(sheet) || (isnumeric(sheet) && sheet > 0))
                    error(message('MATLAB:xlswrite:InputClassSheetArg'));
                end
                if isempty(sheet)
                    sheet = Sheet1;
                end
                % parse REGION into sheet and range.
                % Parse sheet and range strings.
                if ischar(sheet) && ~isempty(strfind(sheet,':'))
                    range = sheet; % only range was specified.
                    sheet = Sheet1;% Use default sheet.
                elseif ~ischar(range)
                    error(message('MATLAB:xlswrite:InputClassRangeArg'));
                end
            end
            Excel = obj.xlApp;
            
            try
                % Construct range string
                if isempty(strfind(range,':'))
                    % Range was partly specified or not at all. Calculate range.
                    [m,n] = size(A);
                    range = obj.calcrange(range,m,n);
                end
            catch exception
                success = false;
                theMessage = obj.exceptionHandler(nargout, exception);
                return;
            end
            
            %[~, wkBook] = openExcelWorkbook(Excel, file, readOnly);
            if obj.wkBook.ReadOnly ~= 0
                %This means the file is probably open in another process.
                error(message('MATLAB:xlswrite:LockedFile', obj.file));
            end
            try % select region.
                % Activate indicated worksheet.
                theMessage = obj.activate_sheet(sheet, true);
                
                % Select range in worksheet.
                Select(Range(obj.xlApp,sprintf('%s',range)));
                
            catch exceptionInner % Throw data range error.
                throw(MException('MATLAB:xlswrite:SelectDataRange','%s', getString(message('MATLAB:xlswrite:SelectDataRangeException', exceptionInner.message))));
            end
            
            % Export data to selected region.
            set(obj.xlApp.selection,'Value',A);
            obj.wkBook.Save
        end
        
        function success = exportPDF(obj, pdfFile, sheet, range)
            validateattributes(pdfFile, {'char'}, {'row'});
            validateattributes(range, {'char'}, {'row'});
            
            try
                sh1 = obj.wkBook.Sheets.Item(sheet);
            catch
                error('xlsfile:exportPDF:sheet', 'Counld not find sheet to export.');
            end
            try
                dboardRng = sh1.get('Range', range);
            catch
                error('xlsfile:exportPDF:range', 'Could not interpret range for export.');
            end
            dboardRng.ExportAsFixedFormat(0, pdfFile);

            success = true;
        end
        
        function info(obj)
            workSheets = obj.wkBook.Worksheets;
            obj.sheets = cell(1,workSheets.Count);
            for idx = 1:workSheets.Count
                sheet = get(workSheets,'item',idx);
                obj.sheets{idx} = sheet.Name;
            end
        end
        
        function flag = isOpen(obj)
            %ISOPEN returns true if the file is still open. Otherwise, it
            %has been closed and is simply a dead handle.
           flag = ~strcmpi(class(obj.xlApp), 'handle'); 
        end
    end
    
    methods(Access = private)
        function [numericData, textData, rawData, customOutput] = xlsreadCOM(obj, sheet, range)
            % xlsreadCOM is the COM implementation of xlsread.
            %   [NUM,TXT,RAW,CUSTOM]=xlsreadCOM(FILE,SHEET,RANGE,EXCELS,CUSTOM) reads
            %   from the specified SHEET and RANGE.
            %
            %   See also XLSREAD, XLSWRITE, XLSFINFO.
            
            %   Copyright 1984-2013 The MathWorks, Inc.
            
            
            % OpenExcelWorkbook may throw an exception if, for example, an invalid
            % file format is specified.
            
            if isequal(sheet,-1)
                % User requests interactive range selection.
                % Set focus to first sheet in Excel workbook.
                activate_sheet(obj.xlApp, 1);
                
                % Make Excel interface the active window.
                set(obj.xlApp,'Visible',true);
                
                % Bring up message box to prompt user.
                uiwait(warndlg({getString(message('MATLAB:xlsread:DlgSelectDataRegion'));...
                    getString(message('MATLAB:xlsread:DlgClickOKToContinueInMATLAB'))},...
                    getString(message('MATLAB:xlsread:DialgoDataSelectionDialogue')),'modal'));
                DataRange = get(obj.xlApp,'Selection');
                if isempty(DataRange)
                    error(message('MATLAB:xlsread:NoRangeSelected'));
                end
                set(obj.xlApp,'Visible',false); % remove Excel interface from desktop
            else
                % Activate indicated worksheet.
                obj.activate_sheet(sheet);
                
                try % importing a data range.
                    if isempty(range)
                        % Select all cells of active sheet.
                        DataRange = obj.wkBook.ActiveSheet.UsedRange;
                    else
                        % The range is specified.
                        obj.xlApp.Goto(Range(obj.xlApp,sprintf('%s',range)));
                        DataRange = get(obj.xlApp,'Selection');
                    end
                catch  %#ok<CTCH> % data range error.
                    error(message('MATLAB:xlsread:RangeSelection', range));
                end
            end
            
            %Call the custom function if it was given.  Provide customOutput if it
            %is possible.
            customOutput = {};
            if nargin == 5 && ~isempty(customFun)
                if nargout(customFun) < 2
                    DataRange = customFun(DataRange);
                else
                    [DataRange, customOutput] = customFun(DataRange);
                end
            end
            
            % get the values in the used regions on the worksheet.
            rawData = DataRange.Value;
            % Ensure that the rawData is always a cell array.  When DataRange.Value
            % returns only a single value it is returned as a primitive type.
            if ~iscell(rawData)
                rawData = {rawData};
            end
            % parse data into numeric and string arrays
            [numericData, textData] = obj.xlsreadSplitNumericAndText(rawData);
        end
        
        function newWb = procFileName(obj, file)
            %PROCFILENAME processes the file name to determine if it is
            %relative or absolute and stores the absolute path.
            % If the file name does not exist, it creates the file and
            % issues a warning.
            
            % David Kelley, 2014
            
            if strfind(file, '*') > 0
                error(message('MATLAB:xlsread:Wildcard', file));
            end
            newWb = true;
            
            [dir, file, obj.ext] = fileparts(file);
            
            if isempty(strfind(dir, ':')) % relative path
                dir = [pwd filesep dir];
            end
            
%             if isempty(dir)
%                 dir = [dir filesep];
%             else
%                 dir = [pwd filesep];
%             end
            
            if ~isempty(obj.ext)
                onPath = exist([dir filesep file obj.ext], 'file');
                obj.file = [dir filesep file obj.ext];
                if onPath
                    newWb = false;
                end
                
            else
                extIn = matlab.io.internal.xlsreadSupportedExtensions;
                obj.file = [dir file '.xlsx']; % Set default to be created if non-existent.
                for iExt = 1:length(extIn)
                    onPath = exist([dir file extIn{iExt}], 'file');
                    if onPath
                        obj.file = fullfile([dir file extIn{iExt}]);
                        newWb = false;
                        break
                    end
                end
                [~,~,obj.ext] = fileparts(obj.file);
            end
                        
            if newWb
                warning('xlsfile:newFile', ['Creating ' strrep(obj.file, '\', '\\') '.']);
                obj.newFile
            end
        end
        
        function [absolutepath] = abspath(obj, partialpath) %#ok<INUSL>
            
            % parse partial path into path parts
            [pathname, filename, ext] = fileparts(partialpath);
            % no path qualification is present in partial path; assume parent is pwd, except
            % when path string starts with '~' or is identical to '~'.
            if isempty(pathname) && partialpath(1) ~= '~'
                Directory = pwd;
            elseif isempty(regexp(partialpath,'^(.:|\\\\|/|~)','once'));
                % path did not start with any of drive name, UNC path or '~'.
                Directory = [pwd,filesep,pathname];
            else
                % path content present in partial path; assume relative to current directory,
                % or absolute.
                Directory = pathname;
            end
            % construct absolute filename
            absolutepath = fullfile(Directory,[filename,ext]);
        end
        
        function theMessage = activate_sheet(obj, Sheet, toAddSheet)
            % Activate specified worksheet in workbook.
            if nargin < 3
                toAddSheet = false;
            end
            
            % Initialize worksheet object
            Workbook = obj.wkBook;
            WorkSheets = Workbook.Worksheets;
            
            % Get name of specified worksheet from workbook
            try
                TargetSheet = get(WorkSheets,'item',Sheet);
                theMessage = struct('message',{''},'identifier',{''});
            catch  %#ok<CTCH>
                if toAddSheet
                    % Worksheet does not exist. Add worksheet.
                    TargetSheet = obj.addsheet(WorkSheets,Sheet);
                    warning(message('MATLAB:xlswrite:AddSheet'));
                    if nargout > 0
                        [theMessage.message,theMessage.identifier] = lastwarn;
                    end
                else
                    error(message('MATLAB:xlsread:WorksheetNotFound', Sheet));
                end
            end
            
            %Activate silently fails if the sheet is hidden
            set(TargetSheet, 'Visible','xlSheetVisible');
            % activate worksheet
            Activate(TargetSheet);
        end
        
        function format = waitForValidWorkbook(obj, ExcelWorkbook) %#ok<INUSL>
            % After the event is complete, it may take time to have the workbook be ready.
            % When it is not ready, errors will occur in getting the values of any properties,
            % such as format.
            format = [];
            for i = 1:500
                try
                    format = ExcelWorkbook.FileFormat;
                    break;
                catch exception %#ok<NASGU>
                    pause(0.01);
                end
            end
            % If we still have no format, try one last time, and let the error
            % propagate.
            if isempty(format)
                format = ExcelWorkbook.FileFormat; 
            end
        end

        function [numericData, textData] = xlsreadSplitNumericAndText(obj, data)
            % xlsreadSplitNumericAndText parses raw data into numeric and text arrays.
            %   [numericData, textData] = xlsreadSplitNumericAndText(DATA) takes cell
            %   array DATA from spreadsheet and returns a double array numericData and
            %   a cell string array textData.
            %
            %   See also XLSREAD, XLSWRITE, XLSFINFO.
            
            %   Copyright 1984-2012 The MathWorks, Inc.
            
            
            % ensure data is in cell array
            if ischar(data)
                data = cellstr(data);
            elseif isnumeric(data) || islogical(data)
                data = num2cell(data);
            end
            
            % Check if raw data is empty
            if isempty(data)
                % Abort when all data cells are empty.
                textData = {};
                numericData = [];
                return
            end
            
            % Initialize textData as an empty cellstr of the right size.
            textData = cell(size(data));
            textData(:) = {''};
            
            % Find non-numeric entries in data cell array
            isTextMask = cellfun('isclass',data,'char');
            
            % Place text cells in text array
            if any(isTextMask(:))
                textData(isTextMask) = data(isTextMask);
            else
                textData = {};
            end
            % Excel returns COM errors when it has a #N/A field.
            textData = strrep(textData,'ActiveX VT_ERROR: ','#N/A');
            
            % Trim the leading and trailing empties from textData
            emptyTextMask = cellfun('isempty', textData);
            textData = obj.filterDataUsingMask(textData, emptyTextMask);
            
            % place NaN in empty numeric cells
            if any(isTextMask(:))
                data(isTextMask)={NaN};
            end
            
            % Find non-numeric entries in data cell array
            isLogicalMask = cellfun('islogical',data);
            
            % Convert cell array to numeric array through concatenating columns then
            % rows.
            cols = size(data,2);
            tempDataColumnCell = cell(1,cols);
            % Concatenate each column first
            for n = 1:cols
                tempDataColumnCell{n} = cat(1, data{:,n});
            end
            % Now concatenate the single column of cells into a numeric array.
            numericData = cat(2, tempDataColumnCell{:});
            
            % Trim all-NaN leading and trailing rows and columns from numeric array
            isNaNMask = isnan(numericData);
            if all(isNaNMask(:))
                numericData = [];
            else
                numericData = obj.filterDataUsingMask(numericData, isNaNMask);
            end
            
            % Restore logical type if all values were logical.
            isLogicalMask = isLogicalMask(:);
            if any(isLogicalMask) &&  all(isLogicalMask(~isNaNMask))
                numericData = logical(numericData);
            end
            
            % Ensure numericArray is 0x0 empty.
            if isempty(numericData)
                numericData = [];
            end
        end
        
        function  [row, col] = getCorner(obj, mask, firstlast)
            isLast = strcmp(firstlast,'last');
            
            % Find first (or last) row that is not all true in the mask.
            row = find(~all(mask,2), 1, firstlast);
            if isempty(row)
                row = obj.emptyCase(isLast, size(mask,1));
            end
            
            % Find first (or last) column that is not all true in the mask.
            col = find(~all(mask,1), 1, firstlast);
            % Find returns empty if there are no rows/columns that contain a false value.
            if isempty(col)
                col = obj.emptyCase(isLast, size(mask,2));
            end
        end
        
        function data = filterDataUsingMask(obj, data, mask)
            [rowStart, colStart] = obj.getCorner(mask, 'first');
            [rowEnd, colEnd] = obj.getCorner(mask, 'last');
            data = data(rowStart:rowEnd, colStart:colEnd);
        end
        
        function dim = emptyCase(obj, isLast, dimSize) %#ok<INUSL>
            if isLast
                dim = dimSize;
            else
                dim = 1;
            end
        end
        
        function newFile(obj)
            % Create new workbook.
            %This is in place because in the presence of a Google Desktop
            %Search installation, calling Add, and then SaveAs after adding data,
            %to create a new Excel file, will leave an Excel process hanging.
            %This workaround prevents it from happening, by creating a blank file,
            %and saving it.  It can then be opened with Open.
            ExcelWorkbook = obj.xlApp.workbooks.Add;
            switch obj.ext
                case '.xls' %xlExcel8 or xlWorkbookNormal
                    xlFormat = -4143;
                case '.xlsb' %xlExcel12
                    xlFormat = 50;
                case '.xlsx' %xlOpenXMLWorkbook
                    xlFormat = 51;
                case '.xlsm' %xlOpenXMLWorkbookMacroEnabled
                    xlFormat = 52;
                otherwise
                    xlFormat = -4143;
            end
            ExcelWorkbook.SaveAs(obj.file, xlFormat);
            ExcelWorkbook.Close(false);
            obj.wkBook = obj.xlApp.workbooks.Open(obj.file);
        end

         
        %% Lots of functions from xlswrite, not sure if fully integrated 
        function newsheet = addsheet(obj, WorkSheets,Sheet) %#ok<INUSL>
            % Add new worksheet, Sheet into worksheet collection, WorkSheets.
            
            if isnumeric(Sheet)
                % iteratively add worksheet by index until number of sheets == Sheet.
                while WorkSheets.Count < Sheet
                    % find last sheet in worksheet collection
                    lastsheet = WorkSheets.Item(WorkSheets.Count);
                    newsheet = WorkSheets.Add([],lastsheet);
                end
            else
                % add worksheet by name.
                % find last sheet in worksheet collection
                lastsheet = WorkSheets.Item(WorkSheets.Count);
                newsheet = WorkSheets.Add([],lastsheet);
            end
            % If Sheet is a string, rename new sheet to this string.
            if ischar(Sheet)
                set(newsheet,'Name',Sheet);
            end
        end
       
        function range = calcrange(obj, range,m,n)
            % Calculate full target range, in Excel A1 notation, to include array of size
            % m x n
            
            range = upper(range);
            cols = isletter(range);
            rows = ~cols;
            % Construct first row.
            if ~any(rows)
                firstrow = 1; % Default row.
            else
                firstrow = str2double(range(rows)); % from range input.
            end
            % Construct first column.
            if ~any(cols)
                firstcol = 'A'; % Default column.
            else
                firstcol = range(cols); % from range input.
            end
            try
                lastrow = num2str(firstrow+m-1);   % Construct last row as a string.
                firstrow = num2str(firstrow);      % Convert first row to string image.
                lastcol = obj.dec2base27(obj.base27dec(firstcol)+n-1); % Construct last column.
                
                range = [firstcol firstrow ':' lastcol lastrow]; % Final range string.
            catch exception
                error(message('MATLAB:xlswrite:CalculateRange', range));
            end
        end
        
        function string = index_to_string(obj, index, first_in_range, digits) %#ok<INUSL>
            
            letters = 'A':'Z';
            working_index = index - first_in_range;
            outputs = cell(1,digits);
            [outputs{1:digits}] = ind2sub(repmat(26,1,digits), working_index);
            string = fliplr(letters([outputs{:}]));
        end
        
        function [digits, first_in_range] = calculate_range(obj, num_to_convert) %#ok<INUSL>
            
            digits = 1;
            first_in_range = 0;
            current_sum = 26;
            while num_to_convert > current_sum
                digits = digits + 1;
                first_in_range = current_sum;
                current_sum = first_in_range + 26.^digits;
            end
        end
        
        function s = dec2base27(obj, d)
            
            %   DEC2BASE27(D) returns the representation of D as a string in base 27,
            %   expressed as 'A'..'Z', 'AA','AB'...'AZ', and so on. Note, there is no zero
            %   digit, so strictly we have hybrid base26, base27 number system.  D must be a
            %   negative integer bigger than 0 and smaller than 2^52.
            %
            %   Examples
            %       dec2base(1) returns 'A'
            %       dec2base(26) returns 'Z'
            %       dec2base(27) returns 'AA'
            %-----------------------------------------------------------------------------
            
            d = d(:);
            if d ~= floor(d) || any(d(:) < 0) || any(d(:) > 1/eps)
                error(message('MATLAB:xlswrite:Dec2BaseInput'));
            end
            [num_digits, begin] = obj.calculate_range(d);
            s = obj.index_to_string(d, begin, num_digits);
        end
        
        function d = base27dec(obj, s) %#ok<INUSL>
            %   BASE27DEC(S) returns the decimal of string S which represents a number in
            %   base 27, expressed as 'A'..'Z', 'AA','AB'...'AZ', and so on. Note, there is
            %   no zero so strictly we have hybrid base26, base27 number system.
            %
            %   Examples
            %       base27dec('A') returns 1
            %       base27dec('Z') returns 26
            %       base27dec('IV') returns 256
            %-----------------------------------------------------------------------------
            
            if length(s) == 1
                d = s(1) -'A' + 1;
            else
                cumulative = 0;
                for i = 1:numel(s)-1
                    cumulative = cumulative + 26.^i;
                end
                indexes_fliped = 1 + s - 'A';
                indexes = fliplr(indexes_fliped);
                indexes_in_cells = mat2cell(indexes, 1, ones(1,numel(indexes))); %#ok<MMTC>
                d = cumulative + sub2ind(repmat(26, 1,numel(s)), indexes_in_cells{:});
            end
        end
        
        function messageStruct = exceptionHandler(obj, nArgs, exception) %#ok<INUSL> %% FIXME?
            if nArgs == 0
                throwAsCaller(exception);
            else
                messageStruct.message = exception.message;
                messageStruct.identifier = exception.identifier;
            end
        end 
        
    end
       
end