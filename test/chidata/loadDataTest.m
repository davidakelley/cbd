classdef loadDataTest < chidataSuiteTest
    %LAODDATATEST is the test suite for cbd.chidata.loadData()
    %
    % Santiago Sordo-Palacios, 2019

    methods (Test)

        function notFound(tc)
            % Test that a data file is not found
            tc.initializeTestDir(tc);
            delete(fullfile(tc.testDir, 'sectionA_data.csv'));
            expectedErr = 'chidata:loadData:notFound';
            actualErr = @() cbd.chidata.loadData('sectionA');
            tc.verifyError(actualErr, expectedErr);
        end % function

        function readSectionA(tc)
            % Test that the data reads-in as expected
            tc.initializeTestDir(tc);
            actualData = cbd.chidata.loadData('sectionA');
            tc.verifyEqual(actualData, tc.expectedSectionAData);
        end % function

        function readSectionB(tc)
            % Test that multiple timeseries can be read-in as expected
            tc.initializeTestDir(tc);
            actualData = cbd.chidata.loadData('sectionB');
            tc.verifyEqual(actualData, tc.expectedSectionBData);
        end % function

        function missingSeries(tc)
            % Test the correct error when a series is missing
            tc.initializeTestDir(tc);
            expectedErr = 'chidata:loadData:missingSeries';
            thisSeries = 'seriesC';
            actualErr = @() cbd.chidata.loadData('sectionA', thisSeries);
            tc.verifyError(actualErr, expectedErr);
        end % function

        function readOneSeries(tc)
            % Test that a single series can be read-in from multi-series
            tc.initializeTestDir(tc);
            selectedSeries = 'series3';
            actualData = cbd.chidata.loadData('sectionB', selectedSeries);
            expectedData = tc.expectedSectionBData(:, selectedSeries);
            tc.verifyEqual(actualData, expectedData);
        end % function

    end % methods

end % classdef