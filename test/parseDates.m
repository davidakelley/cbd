classdef parseDates < matlab.unittest.TestCase
    %PARSEDATES is the test suite for CBD.PRIVATE.PARSEDATES
    %
    % USAGE:
    %   >> runtests('parseDates')
    %
    % Santiago I. Sordo Palacios, 2016
    
    properties
        datenumDate = 737426; % 01-Jan-2019
        expectedDate
        datestrDate
        datetimeDate
        expectedFmt = 'dd-mmm-yyyy';
        datestrFmt = 'mm/dd/yyyy';
        datestrInvalid = 'INVALID';
        datenumDefault = 600000;
    end % properties
    
    methods (TestClassSetup)
        function setupOnce(tc)
            tc.datetimeDate = datetime(tc.datenumDate, 'ConvertFrom', 'datenum');
            tc.expectedDate = datestr(tc.datenumDate, tc.expectedFmt);
            tc.datestrDate = datestr(tc.datenumDate, tc.datestrFmt);
        end % function
    end % methods
    
    methods (Test)
        
        %------------------------------------------------------------------
        function emptyDateIn(tc)
            expectedEmpty = char.empty;
            actualDate = cbd.source.parseDates(char.empty);
            tc.verifyEqual(actualDate, expectedEmpty);
            
            expectedEmpty = double.empty;
            actualDate = cbd.source.parseDates(double.empty);
            tc.verifyEqual(actualDate, expectedEmpty);
            
            expectedEmpty = datetime.empty;
            actualDate = cbd.source.parseDates(datetime.empty);
            tc.verifyEqual(actualDate, expectedEmpty);
        end % function
        
        function badClassIn(tc)
            expectedErr = 'parseDates:badClass';
            actualErr = @() cbd.source.parseDates({});
            tc.verifyError(actualErr, expectedErr);
        end % function
        
        %------------------------------------------------------------------
        function doubleImplicitIn(tc)
            actualDate = cbd.source.parseDates(tc.datenumDate);
            tc.verifyEqual(actualDate, tc.expectedDate);
        end % function
        
        function datetimeImplicitIn(tc)
            actualDate = cbd.source.parseDates(tc.datetimeDate);
            tc.verifyEqual(actualDate, tc.expectedDate);
        end % function
        
        function charImplicitIn(tc)
            actualDate = cbd.source.parseDates(tc.datestrDate);
            tc.verifyEqual(actualDate, tc.expectedDate);
        end % function
        
        %------------------------------------------------------------------
        function doubleExplicitIn(tc)
            actualDate = cbd.source.parseDates(tc.datenumDate, ...
                'formatIn', 'double');
            tc.verifyEqual(actualDate, tc.expectedDate);
        end % function
        
        function datenumExplicitIn(tc)
            actualDate = cbd.source.parseDates(tc.datenumDate, ...
                'formatIn', 'datenum');
            tc.verifyEqual(actualDate, tc.expectedDate);
        end % function
        
        function datetimeExplicitIn(tc)
            actualDate = cbd.source.parseDates(tc.datetimeDate, ...
                'formatIn', 'datetime');
            tc.verifyEqual(actualDate, tc.expectedDate);
        end % function
        
        function charExplicitIn(tc)
            actualDate = cbd.source.parseDates(tc.datestrDate, ...
                'formatIn', 'char');
            tc.verifyEqual(actualDate, tc.expectedDate);
        end % function
        
        function datestrExplicitIn(tc)
            actualDate = cbd.source.parseDates(tc.datestrDate, ...
                'formatIn', 'datestr');
            tc.verifyEqual(actualDate, tc.expectedDate);
        end % function
        
        function datestrFmtIn(tc)
            actualDate = cbd.source.parseDates(tc.datestrDate, ...
                'formatIn', tc.datestrFmt);
            tc.verifyEqual(actualDate, tc.expectedDate);
        end % function
        
        %------------------------------------------------------------------
        function notDouble(tc)
            expectedErr = 'parseDates:notDouble';
            actualErr = @() cbd.source.parseDates(tc.expectedDate, ...
                'formatIn', 'double');
            tc.verifyError(actualErr, expectedErr);
        end % function
        
        function notDatenum(tc)
            expectedErr = 'parseDates:notDouble';
            actualErr = @() cbd.source.parseDates(tc.expectedDate, ...
                'formatIn', 'double');
            tc.verifyError(actualErr, expectedErr);
        end % function
        
        function notDatetime(tc)
            expectedErr = 'parseDates:notDatetime';
            actualErr = @() cbd.source.parseDates(tc.datenumDate, ...
                'formatIn', 'datetime');
            tc.verifyError(actualErr, expectedErr);
        end % function
        
        function notChar(tc)
            expectedErr = 'parseDates:notChar';
            actualErr = @() cbd.source.parseDates(tc.datenumDate, ...
                'formatIn', 'char');
            tc.verifyError(actualErr, expectedErr);
        end % function
        
        function notDatestr(tc)
            expectedErr = 'parseDates:notChar';
            actualErr = @() cbd.source.parseDates(tc.datenumDate, ...
                'formatIn', 'datestr');
            tc.verifyError(actualErr, expectedErr);
        end % function
        
        function invalidDatestrImplicitIn(tc)
            expectedErr = 'parseDates:invalidDate';
            actualErr = @() cbd.source.parseDates(tc.datestrInvalid);
            tc.verifyError(actualErr, expectedErr);
        end % function
        
        function invalidDatestrExplicitIn(tc)
            expectedErr = 'parseDates:invalidDate';
            actualErr = @() cbd.source.parseDates(tc.datestrInvalid, ...
                'formatIn', tc.expectedFmt);
            tc.verifyError(actualErr, expectedErr);
        end % function
        
        %------------------------------------------------------------------
        function doubleOut(tc)
            actualDate = cbd.source.parseDates(tc.datenumDate, ...
                'formatOut', 'double');
            tc.verifyEqual(actualDate, tc.datenumDate);
        end % function
        
        function datenumOut(tc)
            actualDate = cbd.source.parseDates(tc.datenumDate, ...
                'formatOut', 'datenum');
            tc.verifyEqual(actualDate, tc.datenumDate);
        end % function
        
        function datetimeOut(tc)
            actualDate = cbd.source.parseDates(tc.datenumDate, ...
                'formatOut', 'datetime');
            tc.verifyEqual(actualDate, tc.datetimeDate);
        end % function
        
        function charOut(tc)
            actualDate = cbd.source.parseDates(tc.datenumDate, ...
                'formatOut', 'char');
            tc.verifyEqual(actualDate, tc.expectedDate);
        end % function
        
        function datestrOut(tc)
            actualDate = cbd.source.parseDates(tc.datenumDate, ...
                'formatOut', 'datestr');
            tc.verifyEqual(actualDate, tc.expectedDate);
        end % function
        
        function datestrFmtOut(tc)
            actualDate = cbd.source.parseDates(tc.datenumDate, ...
                'formatOut', tc.datestrFmt);
            tc.verifyEqual(actualDate, tc.datestrDate);
        end % function
        
        %------------------------------------------------------------------
        function defaultDateNotUsed(tc)
            actualDate = cbd.source.parseDates(tc.datenumDate, ...
                'defaultDate', tc.datenumDefault);
            tc.verifyEqual(actualDate, tc.expectedDate);
        end % function
        
        function defaultDateUsed(tc)
            actualDate = cbd.source.parseDates('', ...
                'defaultDate', tc.datenumDefault);
            expected = datestr(tc.datenumDefault, tc.expectedFmt);
            tc.verifyEqual(actualDate, expected);
        end % function
        
        function notDefaultDate(tc)
            expectedErr = 'MATLAB:InputParser:ArgumentFailedValidation';
            actualErr = @() cbd.source.parseDates(tc.datenumDate, ...
                'defaultDate', '');
            tc.verifyError(actualErr, expectedErr);
        end % function
        
    end % methods-test
end % classdef