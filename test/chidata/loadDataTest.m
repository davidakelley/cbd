classdef (Sealed) loadDataTest < parentChidata
    %LAODDATATEST is the test suite for cbd.chidata.loadData()
    %
    % Santiago Sordo-Palacios, 2019

    methods (Test)

        function notFound(tc)
            % Test that a data file is not found
            tc.initializeTestDir(tc);
            delete(fullfile(tc.testDir, 'SECTIONA_data.csv'));
            expectedErr = 'chidata:loadData:notFound';
            actualErr = @() cbd.chidata.loadData('SECTIONA');
            tc.verifyError(actualErr, expectedErr);
        end % function

        function readSectionA(tc)
            % Test that the data reads-in as expected
            tc.initializeTestDir(tc);
            actualData = cbd.chidata.loadData('SECTIONA');
            tc.verifyEqual(actualData, tc.expectedSectionAData);
        end % function
        
        function readSectionALower(tc)
            % Test that the data reads-in as expected when lowercase
            tc.initializeTestDir(tc);
            actualData = cbd.chidata.loadData('sectiona');
            tc.verifyEqual(actualData, tc.expectedSectionAData);
        end % function

        function readSectionB(tc)
            % Test that multiple timeseries can be read-in as expected
            tc.initializeTestDir(tc);
            actualData = cbd.chidata.loadData('SECTIONB');
            tc.verifyEqual(actualData, tc.expectedSectionBData);
        end % function

        function missingSeries(tc)
            % Test the correct error when a series is missing
            tc.initializeTestDir(tc);
            expectedErr = 'chidata:loadData:missingSeries';
            thisSeries = 'FAKESERIES';
            actualErr = @() cbd.chidata.loadData('SECTIONA', thisSeries);
            tc.verifyError(actualErr, expectedErr);
        end % function

        function readOneSeries(tc)
            % Test that a single series can be read-in from multi-series
            tc.initializeTestDir(tc);
            selectedSeries = 'SERIES3';
            actualData = cbd.chidata.loadData('SECTIONB', selectedSeries);
            expectedData = tc.expectedSectionBData(:, selectedSeries);
            tc.verifyEqual(actualData, expectedData);
        end % functions
        
        function readOneSeriesLower(tc)
            % Test that a single series can be read-in from multi-series
            tc.initializeTestDir(tc);
            selectedSeries = 'series3';
            actualData = cbd.chidata.loadData('SECTIONB', selectedSeries);
            expectedData = tc.expectedSectionBData(:, upper(selectedSeries));
            tc.verifyEqual(actualData, expectedData);
        end % functions

    end % methods

end % classdef