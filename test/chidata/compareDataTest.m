classdef compareDataTest < matlab.unittest.TestCase
    %COMPAREDATATEST is the test suite for cbd.chidata.compareData
    %
    % Santiago Sordo-Palacios, 2019
    
    properties (Constant)
        baseStart = 737426;
        baseEnd = 737439;
        tolerance = 1e-12;
        prompt = @(id, msg) cbd.chidata.prompt(id, msg, 'y');
    end
    
    properties 
        oldData
        dataNewStartsBeforeOld
        dataNewStartsAfterOld
        dataNewEndsBeforeOld
        dataNewEndsAfterOld
        dataNewHasRevisions
    end 
    
    methods (TestClassSetup)
        
        function getOldData(tc)
            % Create the expected table of data for sectionA
            tc.oldData = tc.generateData(tc.baseStart, tc.baseEnd);
        end % function
        
        function getNewHasRevisions(tc)
            data = tc.generateData(tc.baseStart, tc.baseEnd);
            data.series = data.series - tc.tolerance * 10;
            tc.dataNewHasRevisions = data;
        end % function
        
        
    end % methods
    
    methods (Static)
        
        function data = generateData(startDate, endDate)
            %GENERATEDATA creates a cbd-style table for testing
            dates = startDate:1:endDate;
            rowNames = cellstr(datestr(dates, 'dd-mmm-yyyy'));
            series = ones(length(dates), 1);
            data = table(series, 'RowNames', rowNames);
        end % function
            
    end % methods
    
    methods (Test)
        
        function compareSameData(tc)
            % Test that running data against itself works
            % THIS REQUIRES A MANUAL CHECK OF NO WARNING
            data = tc.oldData;
            cbd.chidata.compareData( ...
                data, tc.oldData, ...
                tc.tolerance, tc.prompt);
        end % function
        
        function compareNewStartsBeforeOld(tc)
            % Test the warning when new starts before old
            data = tc.generateData(tc.baseStart - 1, tc.baseEnd);
            expectedWarn = 'chidata:compareData:newStartsBeforeOld';
            actualWarn = @() cbd.chidata.compareData( ...
                data, tc.oldData, tc.tolerance, tc.prompt);
            tc.verifyWarning(actualWarn, expectedWarn);
        end % function
        
        function compareNewStartsAfterOld(tc)
            % Test the warning when new starts after old
            data = tc.generateData(tc.baseStart + 1, tc.baseEnd);
            expectedWarn = 'chidata:compareData:newStartsAfterOld';
            actualWarn = @() cbd.chidata.compareData( ...
                data, tc.oldData, tc.tolerance, tc.prompt);
            tc.verifyWarning(actualWarn, expectedWarn);
        end % function
        
        function compareNewEndsBeforeOld(tc)
            % Test the warning when new ends before old
            data = tc.generateData(tc.baseStart, tc.baseEnd - 1);
            expectedWarn = 'chidata:compareData:newEndsBeforeOld';
            actualWarn = @() cbd.chidata.compareData( ...
                data, tc.oldData, tc.tolerance, tc.prompt);
            tc.verifyWarning(actualWarn, expectedWarn);
        end % function
        
        function compareNewEndsAfterOld(tc)
            % Test that no warning comes when new ends after old
            % THIS REQUIRES A MANUAL CHECK OF NO WARNING
            data = tc.generateData(tc.baseStart, tc.baseEnd + 1);
            cbd.chidata.compareData( ...
                data, tc.oldData, ...
                tc.tolerance, tc.prompt);
        end % function
        
        function compareNewHasRevisions(tc)
            % Test the warning when new data is revised
            expectedWarn = 'chidata:compareData:newHasRevisions';
            actualWarn = @() cbd.chidata.compareData( ...
                tc.dataNewHasRevisions, tc.oldData, ...
                tc.tolerance, tc.prompt);
            tc.verifyWarning(actualWarn, expectedWarn);
        end % function
        
        function compareNewHasRevisionsChangeTolerance(tc)
            % Test that no warning comes when we revise the tolerance
            % THIS REQUIRES A MANUAL CHECK OF NO WARNING
            cbd.chidata.compareData( ...
                tc.dataNewHasRevisions, tc.oldData, ...
                tc.tolerance * 100, tc.prompt);
        end % function
        
    end % methods
    
    
    
end % classdef