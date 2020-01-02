classdef (Sealed) updateIndexTest < parentChidata
    %UPDATEINDEXTEST is the test suite for cbd.chidata.updateIndex
    %
    % Santiago Sordo-Palacios, 2019

    properties
        prompty = @(id, msg) cbd.chidata.prompt(id, msg, 'y');
        promptn = @(id, msg) cbd.chidata.prompt(id, msg, 'n');
        testfun function_handle
    end % properties

    methods (TestClassSetup)

        function getTestfun(tc)
            tc.testfun = @(section, seriesNames, prompt) ...
                cbd.chidata.updateIndex(tc.expectedIndex, ...
                section, seriesNames, prompt);
        end % function

    end % methods

    methods (Test)

        function moveOneSeriesNewSection(tc)
            % Errow for a new section with a series that already exists
            section = 'NEWSECTION';
            seriesNames = {'SERIES1'};
            expectedErr = 'chidata:updateIndex:moveSeries';
            actualErr = @() tc.testfun(section, seriesNames, tc.prompty);
            tc.verifyError(actualErr, expectedErr);
        end % function
        
        function moveMultipleSeriesNewSection(tc)
            % Errow for a new section with a series that already exists
            section = 'NEWSECTION';
            seriesNames = {'SERIES1', 'SERIES2'};
            expectedErr = 'chidata:updateIndex:moveSeries';
            actualErr = @() tc.testfun(section, seriesNames, tc.prompty);
            tc.verifyError(actualErr, expectedErr);
        end % function
        
        function moveOneSeriesExistingSection(tc)
            % Errow for a new section with a series that already exists
            section = 'SECTIONB';
            seriesNames = {'SERIES1'};
            expectedErr = 'chidata:updateIndex:moveSeries';
            actualErr = @() tc.testfun(section, seriesNames, tc.prompty);
            tc.verifyError(actualErr, expectedErr);
        end % function
        
        function moveMultipleSeriesExistingSection(tc)
            % Errow for a new section with a series that already exists
            section = 'TESTSECTION';
            seriesNames = {'SERIES1', 'SERIES2'};
            expectedErr = 'chidata:updateIndex:moveSeries';
            actualErr = @() tc.testfun(section, seriesNames, tc.prompty);
            tc.verifyError(actualErr, expectedErr);
        end % function

        function addSectionOneSeries(tc)
            % Warning for adding a new section
            section = 'NEWSECTION';
            seriesNames = {'NEWSERIES1'};
            expectedWarn = 'chidata:updateIndex:addSection';
            actualWarn = @() tc.testfun(section, seriesNames, tc.prompty);
            tc.verifyWarning(actualWarn, expectedWarn);            
        end % function
        
        function addSectionMultipleSeries(tc)
            % Warning for adding a new section
            section = 'NEWSECTION';
            seriesNames = {'NEWSERIES1', 'NEWSERIES2'};
            expectedWarn = 'chidata:updateIndex:addSection';
            actualWarn = @() tc.testfun(section, seriesNames, tc.prompty);
            tc.verifyWarning(actualWarn, expectedWarn);            
        end % function
        
        function updateExisting(tc)
            % Test that when updating an existing section as is nothing
            % happens to the index returned
            section = 'SECTIONA';
            seriesNames = {'SERIES1'};
            actualIndex = tc.testfun(section, seriesNames, tc.promptn);
            tc.verifyEqual(actualIndex, tc.expectedIndex);
        end % function

        function removeOneSeries(tc)
            % Test for an existing section that removes series
            section = 'SECTIONB';
            seriesNames = {'SERIES2', 'SERIES3'}; % dropped SERIES4
            expectedWarn = 'chidata:updateIndex:removeSeries';
            actualWarn = @() tc.testfun(section, seriesNames, tc.prompty);
            tc.verifyWarning(actualWarn, expectedWarn);
        end % function
        
        function removeMultipleSeries(tc)
            % Test for an existing section that removes series
            section = 'SECTIONB';
            seriesNames = {'SERIES2'};
            expectedWarn = 'chidata:updateIndex:removeSeries';
            actualWarn = @() tc.testfun(section, seriesNames, tc.prompty);
            tc.verifyWarning(actualWarn, expectedWarn);
        end % function

        function addOneSeries(tc)
            % Test for existing section that adds series
            section = 'SECTIONA';
            seriesNames = {'SERIES1', 'NEWSERIES'}; 
            expectedWarn = 'chidata:updateIndex:addSeries';
            actualWarn = @() tc.testfun(section, seriesNames, tc.prompty);
            tc.verifyWarning(actualWarn, expectedWarn);
        end % function
        
        function addMultipleSeries(tc)
            % Test for existing section that adds series
            section = 'SECTIONA';
            seriesNames = {'SERIES1', 'NEWSERIES1', 'NEWSERIES2'}; 
            expectedWarn = 'chidata:updateIndex:addSeries';
            actualWarn = @() tc.testfun(section, seriesNames, tc.prompty);
            tc.verifyWarning(actualWarn, expectedWarn);
        end % function
        
        function addAndRemoveOneSeries(tc)
            % Test for existing section that renames a series
            section = 'SECTIONA';
            seriesNames = {'SERIES1RENAMED'};
            expectedWarn = 'chidata:updateIndex:modifySeries';
            actualWarn = @() tc.testfun(section, seriesNames, tc.prompty);
            tc.verifyWarning(actualWarn, expectedWarn);
        end % function
        
        function addAndRemoveMultipleSeries(tc)
            % Test for existing section that adds and removes series
            section = 'SECTIONB';
            seriesNames = {'SERIES2RENAMED', 'SERIES3RENAMED'};
            expectedWarn = 'chidata:updateIndex:modifySeries';
            actualWarn = @() tc.testfun(section, seriesNames, tc.prompty);
            tc.verifyWarning(actualWarn, expectedWarn);
        end % function

    end % methods-Test

end % classdef