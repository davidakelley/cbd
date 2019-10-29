classdef movvTests < matlab.unittest.TestCase
    %MOVVTESTS is the test suite for the CBD.MOVV function
    %
    % Vamsi Kurakula, 2019

    properties
        testData
        movvWindow = 33;
    end % properties

    methods (TestClassSetup)
        function setupOnce(testCase)
            testCase.testData = cbd.data('SP500@DAILY', ...
                'startDate', '7/31/2019', 'endDate', '9/30/2019');
        end
    end % methods-TestClassSetup

    methods (Test)

        function testBadInputs(testCase)
            actualErr = @() cbd.movv(testCase.testData, ...
                testCase.movvWindow, 'badInput');
            expectedErr = 'movv:inputs';
            testCase.verifyError(actualErr, expectedErr)
        end

        function testMovvOmitnan(testCase)
            dataWindow = testCase.testData{end-testCase.movvWindow+1:end, 1};
            expectedVal = mean(dataWindow, 'omitnan');
            actualData = cbd.movv( ...
                testCase.testData, testCase.movvWindow, 'omitnan');
            actualVal = actualData{end, 1};
            testCase.assertEqual(actualVal, expectedVal);
        end

        function testMovvIncludeNanImplicit(testCase)
            actualData = cbd.movv(testCase.testData, testCase.movvWindow);
            actualVal = actualData{end, 1};
            expectedVal = NaN;
            testCase.verifyTrue(isequaln(actualVal, expectedVal));
        end
        
        function testMovvIncludeNanExplicit(testCase)
            actualData = cbd.movv(testCase.testData, ...
                testCase.movvWindow, 'includenan');
            actualVal = actualData{end, 1};
            expectedVal = NaN;
            testCase.verifyTrue(isequaln(actualVal, expectedVal));
        end

    end % methods-Test

end % classdef
