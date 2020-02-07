classdef (Sealed) loadPropsTest < parentChidata
    %LOADPROPSTEST is the test suite for cbd.chidata.loadProps()
    %
    % Santiago Sordo-Palacios, 2019

    methods (Test)

        function notFound(tc)
            % Test that a properties file is not found
            tc.initializeTestDir(tc);
            delete(fullfile(tc.testDir, 'SECTIONA_prop.csv'));
            expectedErr = 'chidata:loadProps:notFound';
            actualErr = @() cbd.chidata.loadProps('SECTIONA');
            tc.verifyError(actualErr, expectedErr);
        end % function

        function readSectionA(tc)
            % Test that the properties structure reads-in correctly
            tc.initializeTestDir(tc);
            actualProps = cbd.chidata.loadProps('SECTIONA');
            tc.verifyEqual(actualProps, tc.expectedSectionAProp);
        end % function
        
        function readSectionALower(tc)
            % Test that the properties structure reads-in correctly when lowercase
            tc.initializeTestDir(tc);
            actualProps = cbd.chidata.loadProps('sectiona');
            tc.verifyEqual(actualProps, tc.expectedSectionAProp);
        end % function

        function readSectionB(tc)
            % Test that multiple prop can be read-in as expected
            tc.initializeTestDir(tc);
            actualProps = cbd.chidata.loadProps('SECTIONB');
            tc.verifyEqual(actualProps, tc.expectedSectionBProp);
        end % function

        function missingSeries(tc)
            % Test the correct error when a series is missing
            tc.initializeTestDir(tc);
            expectedErr = 'chidata:loadProps:missingSeries';
            thisSeries = 'FAKESERIES';
            actualErr = @() cbd.chidata.loadProps('SECTIONA', thisSeries);
            tc.verifyError(actualErr, expectedErr);
        end % function

        function readOneSeries(tc)
            % Test that a single series can be read-in
            tc.initializeTestDir(tc);
            thisSeries = 'SERIES3';
            actualProps = cbd.chidata.loadProps('SECTIONB', thisSeries);
            [~, propIdx] = ismember( ...
                thisSeries, {tc.expectedSectionBProp.Name});
            expectedProps = tc.expectedSectionBProp(propIdx);
            tc.verifyEqual(actualProps, expectedProps);
        end % function
        
        function readOneSeriesLower(tc)
            % Test that a single series can be read-in
            tc.initializeTestDir(tc);
            thisSeries = 'series3';
            actualProps = cbd.chidata.loadProps('SECTIONB', thisSeries);
            [~, propIdx] = ismember( ...
                upper(thisSeries), {tc.expectedSectionBProp.Name});
            expectedProps = tc.expectedSectionBProp(propIdx);
            tc.verifyEqual(actualProps, expectedProps);
        end % function

    end % methods

end % classdef