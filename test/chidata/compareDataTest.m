classdef compareDataTest < matlab.unittest.TestCase
    %COMPAREDATATEST is the test suite for cbd.chidata.compareData
    %
    % Santiago Sordo-Palacios, 2019

    properties (Constant)
        baseStart = 737426;
        baseEnd = 737439;
        tolerance = 1e-12;
        prompty = @(id, msg) cbd.chidata.prompt(id, msg, 'y');
        promptn = @(id, msg) cbd.chidata.prompt(id, msg, 'n');
    end % properties

    properties
        oldData
        dataNewHasRevisions
    end % properties

    methods (TestClassSetup)

        function getOldData(tc)
            % Create the expected table of data for sectionA
            tc.oldData = generateData(tc.baseStart, tc.baseEnd);
        end % function

        function getNewHasRevisions(tc)
            data = generateData(tc.baseStart, tc.baseEnd);
            data.series = data.series - tc.tolerance * 10;
            tc.dataNewHasRevisions = data;
        end % function

    end % methods

    methods (Test)

        function sameData(tc)
            % Test that running data against itself works
            data = tc.oldData;
            cbd.chidata.compareData( ...
                data, tc.oldData, ...
                tc.tolerance, tc.promptn);
        end % function

        function newStartsBeforeOld(tc)
            % Test the warning when new starts before old
            data = generateData(tc.baseStart-1, tc.baseEnd);
            expectedWarn = 'chidata:compareData:newStartsBeforeOld';
            actualWarn = @() cbd.chidata.compareData( ...
                data, tc.oldData, tc.tolerance, tc.prompty);
            tc.verifyWarning(actualWarn, expectedWarn);
        end % function

        function newStartsAfterOld(tc)
            % Test the warning when new starts after old
            data = generateData(tc.baseStart+1, tc.baseEnd);
            expectedWarn = 'chidata:compareData:newStartsAfterOld';
            actualWarn = @() cbd.chidata.compareData( ...
                data, tc.oldData, tc.tolerance, tc.prompty);
            tc.verifyWarning(actualWarn, expectedWarn);
        end % function

        function newEndsBeforeOld(tc)
            % Test the warning when new ends before old
            data = generateData(tc.baseStart, tc.baseEnd-1);
            expectedWarn = 'chidata:compareData:newEndsBeforeOld';
            actualWarn = @() cbd.chidata.compareData( ...
                data, tc.oldData, tc.tolerance, tc.prompty);
            tc.verifyWarning(actualWarn, expectedWarn);
        end % function

        function newEndsAfterOld(tc)
            % Test that no warning comes when new ends after old
            data = generateData(tc.baseStart, tc.baseEnd+1);
            cbd.chidata.compareData( ...
                data, tc.oldData, ...
                tc.tolerance, tc.promptn);
        end % function

        function newHasRevisions(tc)
            % Test the warning when new data is revised
            expectedWarn = 'chidata:compareData:newHasRevisions';
            actualWarn = @() cbd.chidata.compareData( ...
                tc.dataNewHasRevisions, tc.oldData, ...
                tc.tolerance, tc.prompty);
            tc.verifyWarning(actualWarn, expectedWarn);
        end % function

        function compareNewHasRevisionsChangeTolerance(tc)
            % Test that no warning comes when we revise the tolerance
            cbd.chidata.compareData( ...
                tc.dataNewHasRevisions, tc.oldData, ...
                tc.tolerance*100, tc.promptn);
        end % function

    end % methods

end % classdef

function data = generateData(startDate, endDate)
%GENERATEDATA creates a cbd-style table for testing

dates = startDate:1:endDate;
rowNames = cellstr(datestr(dates, 'dd-mmm-yyyy'));
series = ones(length(dates), 1);
data = table(series, 'RowNames', rowNames);

end % function