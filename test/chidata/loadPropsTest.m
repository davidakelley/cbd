classdef loadPropsTest < chidataSuiteTest
    %LOADPROPSTEST is the test suite for cbd.chidata.loadProps()
    %
    % Santiago Sordo-Palacios, 2019

    methods (Test)

        function notFound(tc)
            % Test that a properties file is not found
            tc.initializeTestDir(tc);
            delete(fullfile(tc.testDir, 'sectionA_prop.csv'));
            expectedErr = 'chidata:loadProps:notFound';
            actualErr = @() cbd.chidata.loadProps('sectionA');
            tc.verifyError(actualErr, expectedErr);
        end % function

        function readSectionA(tc)
            % Test that the properties structure reads-in correctly
            tc.initializeTestDir(tc);
            actualProps = cbd.chidata.loadProps('sectionA');
            tc.verifyEqual(actualProps, tc.expectedSectionAProp);
        end % function

        function readSectionB(tc)
            % Test that multiple prop can be read-in as expected
            tc.initializeTestDir(tc);
            actualProps = cbd.chidata.loadProps('sectionB');
            tc.verifyEqual(actualProps, tc.expectedSectionBProp);
        end % function

        function missingSeries(tc)
            % Test the correct error when a series is missing
            tc.initializeTestDir(tc);
            expectedErr = 'chidata:loadProps:missingSeries';
            thisSeries = 'seriesC';
            actualErr = @() cbd.chidata.loadProps('sectionA', thisSeries);
            tc.verifyError(actualErr, expectedErr);
        end % function

        function readOneSeries(tc)
            % Test that a single series can be read-in
            tc.initializeTestDir(tc);
            thisSeries = 'series3';
            actualProps = cbd.chidata.loadProps('sectionB', thisSeries);
            [~, propIdx] = ismember( ...
                thisSeries, {tc.expectedSectionBProp.Name});
            expectedProps = tc.expectedSectionBProp(propIdx);
            tc.verifyEqual(actualProps, expectedProps);
        end % function

    end % methods

end % classdef