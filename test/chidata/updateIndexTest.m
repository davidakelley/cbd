classdef updateIndexTest < chidataSuiteTest
    %UPDATEINDEXTEST is the test suite for cbd.chidata.updateIndex
    %
    % Santiago Sordo-Palacios, 2019

    properties
        prompt = @(id, msg) cbd.chidata.prompt(id, msg, 'y');
        testfun function_handle
    end % properties

    methods (TestMethodSetup)

        function getTestfun(tc)
            tc.testfun = @(section, seriesNames) ...
                cbd.chidata.updateIndex( ...
                tc.expectedIndex, section, seriesNames, ...
                tc.prompt);
        end % function

    end % methods

    methods (Test)

        function moveSeriesCase1(tc)
            % Errow for a new section with a series that already exists
            section = 'newSection';
            seriesNames = {'series1'};
            expectedErr = 'chidata:updateIndex:moveSeries';
            actualErr = @() tc.testfun(section, seriesNames);
            tc.verifyError(actualErr, expectedErr);
        end % function

        function addSection(tc)
            % Warning for adding a new section
            section = 'newSection';
            seriesNames = {'newSeries1', 'newSeries2'};
            expectedWarn = 'chidata:updateIndex:addSection';
            actualWarn = @() tc.testfun(section, seriesNames);
            tc.verifyWarning(actualWarn, expectedWarn);
        end % function

        function moveSeriesCase2(tc)
            % Error for an existing section with an existing series from
            % a different section
            section = 'sectionB';
            seriesNames = {'series1'};
            expectedErr = 'chidata:updateIndex:moveSeries';
            actualErr = @() tc.testfun(section, seriesNames);
            tc.verifyError(actualErr, expectedErr);
        end % function

        function updateExisting(tc)
            % Test that when updating an existing section as is nothing
            % happens to the index returned
            section = 'sectionA';
            seriesNames = {'series1'};
            actualIndex = tc.testfun(section, seriesNames);
            tc.verifyEqual(actualIndex, tc.expectedIndex);
        end % function

        function removeSeries(tc)
            % Test for an existing section that removes series
            section = 'sectionB';
            seriesNames = {'series2'};
            expectedWarn = 'chidata:updateIndex:removeSeries';
            actualWarn = @() tc.testfun(section, seriesNames);
            tc.verifyWarning(actualWarn, expectedWarn);
        end % function

        function addSeries(tc)
            % Test for existing section that adds series
            section = 'sectionA';
            seriesNames = {'series1', 'newSeries'};
            expectedWarn = 'chidata:updateIndex:addSeries';
            actualWarn = @() tc.testfun(section, seriesNames);
            tc.verifyWarning(actualWarn, expectedWarn);
        end % function
        
        function modifySeries(tc)
            % Test for existing section that adds and removes series
            section = 'sectionA';
            seriesNames = {'newSeries'};
            expectedWarn = 'chidata:updateIndex:modifySeries';
            actualWarn = @() tc.testfun(section, seriesNames);
            tc.verifyWarning(actualWarn, expectedWarn);
        end % function

    end % methods-Test

end % classdef