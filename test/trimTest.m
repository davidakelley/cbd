classdef trimTest < matlab.unittest.TestCase
    %TRIMTEST is the test suite for cbd.trim
    %
    % Steve Lee, 2019

    properties
        gdph
        fedfunds
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

    methods (TestClassSetup)
        function setupOnce(tc)
            % Get the data
            tc.gdph = cbd.expression('GDPH0001@ASREPGDP');
            tc.fedfunds = cbd.expression( ...
                {'FFEDTAL@DAILY', 'FFEDTAH@DAILY'});

            % useful testing dates
            tc.dateBeforeFirst = datenum('12/12/1940');
            tc.dateFirst = datenum(tc.gdph.Properties.RowNames{1});
            tc.dateLast = datenum(tc.gdph.Properties.RowNames{end});
            tc.dateAfterLast = datenum('1/1/2040');

            % random starting dates
            tc.dateRandStart = datenum('1/1/1990');
            tc.dateBeforeRandStart = datenum('12/31/1989');
            tc.dateAfterRandStart = datenum('3/31/1990');

            % random ending dates
            tc.dateRandEnd = datenum('1/1/1991');
            tc.dateBeforeRandEnd = datenum('12/31/1990');
            tc.dateAfterRandEnd = datenum('3/31/1991');
        end % function

        function warningOff(tc) %#ok<MANU>
            warning('off', 'trim:emptyTable');
            warning('off', 'trim:startLastMismatch');
        end % function
    end

    methods (TestClassTeardown)
        function warningOn(tc) %#ok<MANU>
            warning('on', 'trim:emptyTable');
            warning('on', 'trim:startLastMismatch');
        end % function
    end % methods

    methods (Test)
        %% Basic functionality
        function trimStart(tc)
            testVal = cbd.trim(tc.gdph, ...
                'startDate', tc.dateRandStart);
            firstDate = datenum(testVal.Properties.RowNames{1});
            tc.verifyEqual(firstDate, tc.dateAfterRandStart);
        end

        function trimStartAfterLastDate(tc)
            testVal = cbd.trim(tc.gdph, ...
                'startDate', tc.dateAfterLast);
            tc.verifyEqual(isempty(testVal), true);
        end

        function trimEnd(tc)
            testVal = cbd.trim(tc.gdph, ...
                'endDate', tc.dateRandEnd);
            lastDate = datenum(testVal.Properties.RowNames{end});
            tc.verifyEqual(lastDate, tc.dateBeforeRandEnd);
        end

        function trimEndBeforeFirstDate(tc)
            testVal = cbd.trim(tc.gdph, ...
                'endDate', tc.dateBeforeFirst);
            tc.verifyEqual(true, isempty(testVal));
        end

        function trimBothNotInSeries(tc)
            % dates not in series
            testVal = cbd.trim(tc.gdph, ...
                'startDate', tc.dateRandStart, ...
                'endDate', tc.dateRandEnd);

            firstDate = datenum(testVal.Properties.RowNames{1});
            tc.verifyEqual(firstDate, tc.dateAfterRandStart);

            lastDate = datenum(testVal.Properties.RowNames{end});
            tc.verifyEqual(lastDate, tc.dateBeforeRandEnd);
        end

        function trimBothInSeries(tc)
            % dates in series
            testVal = cbd.trim(tc.gdph, ...
                'startDate', tc.dateFirst, ...
                'endDate', tc.dateLast);

            firstDate = datenum(testVal.Properties.RowNames{1});
            tc.verifyEqual(firstDate, tc.dateFirst);

            lastDate = datenum(testVal.Properties.RowNames{end});
            tc.verifyEqual(lastDate, tc.dateLast);
        end

        %% Inclusive trim option
        function trimStartInc(tc)
            testVal = cbd.trim(tc.gdph, ...
                'startDate', tc.dateRandStart, ...
                'Inclusive', true);
            firstDate = datenum(testVal.Properties.RowNames{1});
            tc.verifyEqual(firstDate, tc.dateBeforeRandStart);
        end

        function trimEndInc(tc)
            testVal = cbd.trim(tc.gdph, ...
                'endDate', tc.dateRandEnd, ...
                'Inclusive', true);
            lastDate = datenum(testVal.Properties.RowNames{end});
            tc.verifyEqual(lastDate, tc.dateAfterRandEnd);
        end

        function trimBothIncNotInSeries(tc)
            % dates not in series
            testVal = cbd.trim(tc.gdph, 'startDate', tc.dateRandStart, ...
                'endDate', tc.dateRandEnd, ...
                'Inclusive', true);
            firstDate = datenum(testVal.Properties.RowNames{1});
            tc.verifyEqual(firstDate, tc.dateBeforeRandStart);

            lastDate = datenum(testVal.Properties.RowNames{end});
            tc.verifyEqual(lastDate, tc.dateAfterRandEnd);
        end

        function trimBothIncInSeries(tc)
            % dates in series
            testVal = cbd.trim(tc.gdph, ...
                'startDate', tc.dateBeforeRandStart, ...
                'endDate', tc.dateBeforeRandEnd, ...
                'Inclusive', true);

            firstDate = datenum(testVal.Properties.RowNames{1});
            tc.verifyEqual(firstDate, tc.dateBeforeRandStart);

            lastDate = datenum(testVal.Properties.RowNames{end});
            tc.verifyEqual(lastDate, tc.dateBeforeRandEnd);
        end

        function trimEmptyTable(tc)
            testVal = cbd.trim(table(), ...
                'startDate', tc.dateRandStart);
            tc.verifyTrue(isempty(testVal));
        end

        function trimSameDatesNotInSeries(tc)
            % GDP is quarterly, this date is not in series
            testVal = cbd.trim(tc.gdph, ...
                'startDate', tc.dateRandStart, ...
                'endDate', tc.dateRandStart);
            tc.verifyTrue(isempty(testVal));
        end

        function trimSameDatesInSeries(tc)
            % date is in series
            testVal = cbd.trim(tc.gdph, ...
                'startDate', tc.dateBeforeRandStart, ...
                'endDate', tc.dateBeforeRandStart);
            lastDate = datenum(testVal.Properties.RowNames{end});
            tc.verifyEqual(lastDate, tc.dateBeforeRandStart);
            tc.verifyEqual(1, height(testVal));
        end

        function trimSameDatesIncNotInSeries(tc)
            % GDP is quarterly, this date is not in series
            testVal = cbd.trim(tc.gdph, ...
                'startDate', tc.dateRandStart, ...
                'endDate', tc.dateRandStart, ...
                'Inclusive', true);
            firstDate = datenum(testVal.Properties.RowNames{1});
            lastDate = datenum(testVal.Properties.RowNames{end});
            tc.verifyEqual(firstDate, tc.dateBeforeRandStart);
            tc.verifyEqual(lastDate, tc.dateAfterRandStart);
        end

        function trimDatesIncInSeries(tc)
            % date is in series
            testVal = cbd.trim(tc.gdph, ...
                'startDate', tc.dateBeforeRandStart, ...
                'endDate', tc.dateBeforeRandStart, ...
                'Inclusive', true);
            lastDate = datenum(testVal.Properties.RowNames{end});
            tc.verifyEqual(lastDate, tc.dateBeforeRandStart);
            tc.verifyEqual(1, height(testVal));
        end

    end
end