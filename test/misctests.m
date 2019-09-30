%% Test suite for the misc functions in cbd.
%
% Each test here works by comparing a computed result against a value
% taken from the Haver DLXVG3. This is all done against data from the
% ASREPGDP database because those data series will not be updated again.
% Note that the integration with cbd.data is tested in each function here
% as well.
%
% See also: execTests.m

% David Kelley, 2015

classdef misctests < matlab.unittest.TestCase
    properties
        gdph
        gdph2
        gdph3
        fedfunds
        set1
        set2
        dateBeforeFirst
        dateFirst
        dateRandStart
        dateBeforeRandStart
        dateAfterRandStart
        dateRandEnd
        dateBeforeRandEnd
        dateAfterRandEnd
        dateLast
        dateAfterLast
    end
    
    methods(TestMethodSetup)
        function setupOnce(testCase)
            testCase.gdph = cbd.data('GDPH0001@ASREPGDP');
            testCase.gdph2 = cbd.data('GDPH0002@ASREPGDP');
            testCase.gdph3 = cbd.data('GDPH0003@ASREPGDP');
            testCase.fedfunds = cbd.data({'FFEDTAL@DAILY', 'FFEDTAH@DAILY'});
            
            testCase.set1 = cbd.data({'GDPH0001@ASREPGDP', 'GDPH0001@ASREPGDP'});
            testCase.set2 = cbd.data({'GDPH0002@ASREPGDP', 'GDPH0002@ASREPGDP'});
            
            % useful testing dates
            
            testCase.dateBeforeFirst = datenum('12/12/1940');
            testCase.dateFirst = datenum(testCase.gdph.Properties.RowNames{1});
            
            % random starting dates
            testCase.dateRandStart = datenum('1/1/1990');
            testCase.dateBeforeRandStart = datenum('12/31/1989');
            testCase.dateAfterRandStart = datenum('3/31/1990');
            
            % random ending dates
            testCase.dateRandEnd = datenum('1/1/1991');
            testCase.dateBeforeRandEnd = datenum('12/31/1990');
            testCase.dateAfterRandEnd = datenum('3/31/1991');
            
            testCase.dateLast = datenum(testCase.gdph.Properties.RowNames{end});
            testCase.dateAfterLast = datenum('1/1/2040');
        end
    end
    
    methods (Test)
        %% Merge function
        function testMerge2(testCase)
            testVal = cbd.merge(testCase.gdph, testCase.gdph2);
            testCase.verifyEqual(size(testVal, 2), 2);
        end
        
        function testMergeMulti(testCase)
            testVal = cbd.merge(testCase.gdph, testCase.gdph2, testCase.gdph3);
            testCase.verifyEqual(size(testVal, 2), 3);
        end
        
        function testMergeSameName(testCase)
            testVal = cbd.merge(testCase.gdph, testCase.gdph);
            testCase.verifyEqual(size(testVal, 2), 2);
        end
        
        function testMergeSameNameMulti(testCase)
            testVal = cbd.merge(testCase.gdph, testCase.gdph, testCase.gdph);
            testCase.verifyEqual(size(testVal, 2), 3);
        end
        
        function testMergeSameNameMultiSet(testCase)
            testVal = cbd.merge(testCase.set1, testCase.set2);
            testCase.verifyEqual(size(testVal, 2), 4);
        end
        
        function testMergeSameNameMultiSetSame(testCase)
            testVal = cbd.merge(testCase.set1, testCase.set1);
            testCase.verifyEqual(size(testVal, 2), 4);
        end
        
        %% Trim function
        function testTrimStart(testCase)
            testVal = cbd.trim(testCase.gdph, 'startDate', testCase.dateRandStart);
            firstDate = datenum(testVal.Properties.RowNames{1});
            testCase.verifyEqual(firstDate, testCase.dateAfterRandStart);
        end
        
        function testTrimStartAfterLastDate(testCase)
            testVal = cbd.trim(testCase.gdph, 'startDate', testCase.dateAfterLast);
            testCase.verifyEqual(isempty(testVal), true);
        end
        
        function testTrimEnd(testCase)
            testVal = cbd.trim(testCase.gdph, 'endDate', testCase.dateRandEnd);
            lastDate = datenum(testVal.Properties.RowNames{end});
            testCase.verifyEqual(lastDate, testCase.dateBeforeRandEnd);
        end
        
        function testTrimEndBeforeFirstDate(testCase)
            testVal = cbd.trim(testCase.gdph, 'endDate', testCase.dateBeforeFirst);
            testCase.verifyEqual(true, isempty(testVal));
        end
        
        function testTrimBoth(testCase)
            % dates not in series
            testVal = cbd.trim(testCase.gdph, 'startDate', testCase.dateRandStart, ...
                'endDate', testCase.dateRandEnd);
            firstDate = datenum(testVal.Properties.RowNames{1});
            testCase.verifyEqual(firstDate, testCase.dateAfterRandStart);
            
            lastDate = datenum(testVal.Properties.RowNames{end});
            testCase.verifyEqual(lastDate, testCase.dateBeforeRandEnd);
            
            % dates in series
            testVal = cbd.trim(testCase.gdph, 'startDate', testCase.dateFirst, ...
                'endDate', testCase.dateLast);
            firstDate = datenum(testVal.Properties.RowNames{1});
            testCase.verifyEqual(firstDate, testCase.dateFirst);
            
            lastDate = datenum(testVal.Properties.RowNames{end});
            testCase.verifyEqual(lastDate, testCase.dateLast);
        end
        
        function testTrimStartInc(testCase)
            testVal = cbd.trim(testCase.gdph, 'startDate', testCase.dateRandStart, ...
                'Inclusive', true);
            firstDate = datenum(testVal.Properties.RowNames{1});
            testCase.verifyEqual(firstDate, testCase.dateBeforeRandStart);
            
            % legacy
            testVal = cbd.trim(testCase.fedfunds, 'startDate', '12/16/2015', 'Inclusive', true);
            firstDate = datenum(testVal.Properties.RowNames{1});
            testCase.verifyEqual(datenum('12/16/2015'), firstDate);
        end
        
        function testTrimEndInc(testCase)
            testVal = cbd.trim(testCase.gdph, 'endDate', testCase.dateRandEnd, ...
                'Inclusive', true);
            lastDate = datenum(testVal.Properties.RowNames{end});
            testCase.verifyEqual(lastDate, testCase.dateAfterRandEnd);
            
            % legacy
            testVal = cbd.trim(testCase.fedfunds, 'endDate', '12/16/2015', 'Inclusive', true);
            lastDate = datenum(testVal.Properties.RowNames{end});
            testCase.verifyEqual(datenum('12/16/2015'), lastDate);
        end
        
        function testTrimBothInc(testCase)
            % dates not in series
            testVal = cbd.trim(testCase.gdph, 'startDate', testCase.dateRandStart, ...
                'endDate', testCase.dateRandEnd, ...
                'Inclusive', true);
            firstDate = datenum(testVal.Properties.RowNames{1});
            testCase.verifyEqual(firstDate, testCase.dateBeforeRandStart);
            
            lastDate = datenum(testVal.Properties.RowNames{end});
            testCase.verifyEqual(lastDate, testCase.dateAfterRandEnd);
            
            % dates in series
            testVal = cbd.trim(testCase.gdph, 'startDate', testCase.dateBeforeRandStart, ...
                'endDate', testCase.dateBeforeRandEnd, ...
                'Inclusive', true);
            
            firstDate = datenum(testVal.Properties.RowNames{1});
            testCase.verifyEqual(firstDate, testCase.dateBeforeRandStart);
            
            lastDate = datenum(testVal.Properties.RowNames{end});
            testCase.verifyEqual(lastDate, testCase.dateBeforeRandEnd);
        end
        
        function testTrimEmptyTable(testCase)
            testVal = cbd.trim(table(), 'startDate', testCase.dateRandStart);
            testCase.verifyEqual(true, isempty(testVal));
        end
        
        function testTrimSameDates(testCase)
            % GDP is quarterly, this date is not in series
            testVal = cbd.trim(testCase.gdph, 'startDate', testCase.dateRandStart, ...
                'endDate', testCase.dateRandStart);
            testCase.verifyEqual(true, isempty(testVal));
            
            % date is in series
            testVal = cbd.trim(testCase.gdph, 'startDate', testCase.dateBeforeRandStart, ...
                'endDate', testCase.dateBeforeRandStart);
            lastDate = datenum(testVal.Properties.RowNames{end});
            testCase.verifyEqual(lastDate, testCase.dateBeforeRandStart);
            testCase.verifyEqual(1, height(testVal));
        end
        
        function testTrimSameDatesInc(testCase)
            % GDP is quarterly, this date is not in series
            testVal = cbd.trim(testCase.gdph, 'startDate', testCase.dateRandStart, ...
                'endDate', testCase.dateRandStart, ...
                'Inclusive', true);
            firstDate = datenum(testVal.Properties.RowNames{1});
            lastDate = datenum(testVal.Properties.RowNames{end});
            testCase.verifyEqual(firstDate, testCase.dateBeforeRandStart);
            testCase.verifyEqual(lastDate, testCase.dateAfterRandStart);
            
            % date is in series
            testVal = cbd.trim(testCase.gdph, 'startDate', testCase.dateBeforeRandStart, ...
                'endDate', testCase.dateBeforeRandStart, ...
                'Inclusive', true);
            lastDate = datenum(testVal.Properties.RowNames{end});
            testCase.verifyEqual(lastDate, testCase.dateBeforeRandStart);
            testCase.verifyEqual(1, height(testVal));
        end
    end
end
