classdef (Abstract) parentChidata < matlab.unittest.TestCase
    %PARENTCHIDATA is the test suite for the +chidata folder
    %
    % Santiago Sordo-Palacios, 2019

    properties
        testDir char % The temporary directory used to test chidata
        supportDir char % The location of the support files for tests

        expectedIndex containers.Map % The index saved as index.csv
        expectedSectionAData table % The data saved as sectionA_data.csv
        expectedSectionAProp struct % The props saved as sectionA_prop.csv
        expectedSectionBData table % The data saved as sectionB_data.csv
        expectedSectionBProp struct % The props saved as sectionB_prop.csv

    end % properties

    properties (Constant)
        dynamicFields = {'Name', 'DateTimeMod', 'UsernameMod', 'FileMod'};
    end % properties

    methods (TestClassSetup)

        function getSupportDir(tc)
            % Get the path to the CHIDATA support directory
            thisPath = mfilename('fullpath');
            thisFile = mfilename();
            supportName = 'support';
            tc.supportDir = fullfile( ...
                strrep(thisPath, thisFile, ''), ...
                supportName);
        end % function

        function getExpectedIndex(tc)
            % Create the expected index as a table
            Series = {'BBSDEMAND'; 'BBSOUTLOOK'; ...
                'SERIES1'; 'SERIES2'; 'SERIES3'; 'SERIES4'; ...
                'TESTSERIES'; 'MLU67G'};
            Section = {'DISAGG'; 'DISAGG'; ...
                'SECTIONA'; 'SECTIONB'; 'SECTIONB'; 'SECTIONB'; ...
                'TESTSECTION'; 'AGG'};
            tc.expectedIndex = containers.Map(Series, Section);
        end % function

        function getExpectedSectionAData(tc)
            % Create the expected table of data for sectionA
            startDate = 737426;
            dates = startDate:1:startDate + 6;
            rowNames = cellstr(datestr(dates, 'dd-mmm-yyyy'));
            series1 = transpose(1:1:7);
            varNames = {'SERIES1'};
            tc.expectedSectionAData = table( ...
                series1, ...
                'VariableNames', varNames, ...
                'RowNames', rowNames);
        end % function

        function getExpectedSectionAProp(tc)
            % Create the expected structure of props for sectionA
            tc.expectedSectionAProp = struct( ...
                'Name', 'SERIES1', ...
                'Frequency', 'freq1', ...
                'Magnitude', 1, ...
                'AggType', 'agg1', ...
                'DataType', 'type1', ...
                'Source', 'source1', ...
                'DateTimeMod', 'time1', ...
                'UsernameMod', 'name1', ...
                'FileMod', 'file1');
        end % function

        function getExpectedSectionBData(tc)
            % Create the expected table of data for sectionAB
            startDate = 737426;
            dates = startDate:7:startDate + 28;
            rowNames = cellstr(datestr(dates, 'dd-mmm-yyyy'));
            series2 = transpose(1:1:5);
            series3 = [-10; NaN; 10; NaN; -10];
            series4 = [123.456; -321.879; 231.234; -232.234; 801.234];
            varNames = {'SERIES2', 'SERIES3', 'SERIES4'};
            tc.expectedSectionBData = table( ...
                series2, series3, series4, ...
                'VariableNames', varNames, ...
                'RowNames', rowNames);
        end % function

        function getExpectedSectionBProp(tc)
            % Create the expected table of data for sectionB
            tc.expectedSectionBProp = struct( ...
                'Name', {'SERIES2', 'SERIES3', 'SERIES4'}, ...
                'Frequency', {'freq2', 'freq3', 'freq4'}, ...
                'Magnitude', {2, 3, 4}, ...
                'AggType', {'agg2', 'agg3', 'agg4'}, ...
                'DataType', {'type2', 'type3', 'type4'}, ...
                'Source', {'source2', 'source3', 'source4'}, ...
                'DateTimeMod', {'time2', 'time3', 'time4'}, ...
                'UsernameMod', {'name2', 'name3', 'name4'}, ...
                'FileMod', {'file2', 'file3', 'file4'});
        end % function
        
        function clearChidataDirStart(tc) %#ok<MANU>
            % Clears the chidataDir persistent variable
            clear '+cbd/+chidata/dir.m'
        end % function

    end % methods

    methods (TestMethodSetup)

        function createTestDir(tc)
            % Creates a directory for performing tests
            tc.testDir = tempname();
            mkdir(tc.testDir);
        end % function

    end % methods

    methods (TestMethodTeardown)

        function deleteTestDir(tc)
            % Removes the directory for performing tests
            rmdir(tc.testDir, 's');
        end % function
        
        function clearChidataDir(tc) %#ok<MANU>
            % Clears the chidataDir persistent variable
            clear '+cbd/+chidata/dir.m'
        end % function

    end % methods

    methods (Static)

        function initializeTestDir(tc)
            % Copies support files from supportDir to testDir and
            % initalizes the CHIDATA directory
            copyfile(tc.supportDir, tc.testDir)
            cbd.chidata.dir(tc.testDir);
        end % function

    end % methods

end % classdef