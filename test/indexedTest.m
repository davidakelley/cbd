classdef indexedTest < matlab.unittest.TestCase
    %INDEXTEST is the test suite for cbd.indexed()
    %
    % Vamsi Kurakula, 2019
    
    properties
        idxDate
        testSeries
        testData
    end

    methods (TestClassSetup)
        function setupOnce(tc)
            tc.idxDate = '02-Sep-2019';
            tc.testSeries = 'SPSPF@DAILY';
            tc.testData = cbd.expression(tc.testSeries, ...
                'startDate', '1/1/2017');
        end
    end

    methods (Test)

        function findIdxDateBackward(tc)
            indexedData = cbd.indexed(tc.testData, tc.idxDate, -1);
            tc.verifyEqual(indexedData{'30-Aug-2019', 1}, 100);
        end

        function findIdxDateForward(tc)
            indexedData = cbd.indexed(tc.testData, tc.idxDate, 1);
            tc.verifyEqual(indexedData{'03-Sep-2019', 1}, 100);
        end

        function assertTable(tc)
            f = @() cbd.indexed(struct());
            tc.assertError(f, 'indexed:inputNotTable')
        end

        function assertDirFlag(tc)
            f = @() cbd.indexed(tc.testData, tc.idxDate, 4);
            tc.assertError(f, 'index:invalidDirFlag')
        end

        function assertBackDate(tc)
            f = @() cbd.indexed(tc.testData, '12/31/1900', -1);
            tc.assertError(f, 'indexed:noBackDate')
        end

        function assertForwardDate(tc)
            f = @() cbd.indexed(tc.testData, '12/31/4000', 1);
            tc.assertError(f, 'indexed:noForwardDate')
        end

        function assertIndexDate(tc)
            f = @() cbd.indexed(tc.testData, '9/15/2019');
            tc.assertError(f, 'indexed:noDate')
        end

        function assertIdx100(tc)
            randNrow = randi([1, size(tc.testData, 1)]);
            randDate = tc.testData.Row{randNrow};

            idxData = cbd.indexed(tc.testData, randDate);
            tc.verifyEqual(idxData{randDate, 1}, 100);
        end
    end
end
