classdef (Abstract) chidataSuiteTest < matlab.unittest.TestCase
    %CHIDATATEST is the test suite for the +chidata folder
    %
    % USAGE
    %   >> runtests('chidataTestSuite');
    %
    % Santiago Sordo-Palacios, 2019

    properties
        testDir char % The temporary directory used to test chidata
        supportDir char % The location of the support files for tests

        expectedIndex table % The index saved as index.csv
        expectedSectionAData table % The data saved as sectionA_data.csv
        expectedSectionAProp struct % The props saved as sectionA_prop.csv
        expectedSectionBData table % The data saved as sectionB_data.csv
        expectedSectionBProp struct % The props saved as sectionB_prop.csv

        badIndex table % A bad index used to test errors

        section % The sectionName input argument to the save function
        data % The data input argument to the save function
        props % The properties input argument to the save function

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
            Series = {'seriesA'; 'seriesB'; 'seriesC'; ...
                'seriesD'; 'testSeries'};
            Section = {'sectionA'; 'sectionB'; 'sectionB'; ...
                'sectionB'; 'testSection'};
            tc.expectedIndex = table(Series, Section);
        end % function

        function getExpectedSectionAData(tc)
            % Create the expected table of data for sectionA
            startDate = 737426;
            dates = startDate:1:startDate + 6;
            rowNames = cellstr(datestr(dates, 'dd-mmm-yyyy'));
            seriesA = transpose(1:1:7);
            varNames = {'seriesA'};
            tc.expectedSectionAData = table( ...
                seriesA, ...
                'VariableNames', varNames, ...
                'RowNames', rowNames);
        end % function

        function getExpectedSectionAProp(tc)
            % Create the expected structure of props for sectionA
            tc.expectedSectionAProp = struct( ...
                'Name', 'seriesA', ...
                'Frequency', 'freqA', ...
                'Magnitude', 0, ...
                'AggType', 'aggA', ...
                'DataType', 'typeA', ...
                'Source', 'sourceA', ...
                'DateTimeMod', '01/01/2019 12:00', ...
                'UsernameMod', 'nameA', ...
                'FileMod', 'fileA');
        end % function

        function getExpectedSectionBData(tc)
            % Create the expected table of data for sectionAB
            startDate = 737426;
            dates = startDate:7:startDate + 28;
            rowNames = cellstr(datestr(dates, 'dd-mmm-yyyy'));
            seriesB = transpose([1:1:5]);
            seriesC = [-10; NaN; 10; NaN; -10];
            seriesD = [123.456; -321.879; 231.234; -232.234; 801.234];
            varNames = {'seriesB', 'seriesC', 'seriesD'};
            tc.expectedSectionBData = table( ...
                seriesB, seriesC, seriesD, ...
                'VariableNames', varNames, ...
                'RowNames', rowNames);
        end % function

        function getExpectedSectionBProp(tc)
            % Create the expected table of data for sectionB
            dates = {'01/02/2019 12:00', ...
                '01/03/2019 12:00', '01/04/2019 12:00'};
            tc.expectedSectionBProp = struct( ...
                'Name', {'seriesB', 'seriesC', 'seriesD'}, ...
                'Frequency', {'freqB', 'freqC', 'freqD'}, ...
                'Magnitude', {1, 2, 3}, ...
                'AggType', {'aggB', 'aggC', 'aggD'}, ...
                'DataType', {'typeB', 'typeC', 'typeD'}, ...
                'Source', {'sourceB', 'sourceC', 'sourceD'}, ...
                'DateTimeMod', dates, ...
                'UsernameMod', {'nameB', 'nameC', 'nameD'}, ...
                'FileMod', {'fileB', 'fileC', 'fileD'});
        end % function

        function loadBadIndex(tc)
            % Loads the bad index file for testing in findSection()
            badIndexFname = fullfile(tc.supportDir, 'badIndex.csv');
            tc.badIndex = readtable(badIndexFname);
        end % function

        function loadSaveVars(tc)
            % Loads variables for testing in save()
            tc.section = 'sectionA';
            tc.data = tc.expectedSectionAData;
            tc.props = rmfield(tc.expectedSectionAProp, tc.dynamicFields);
        end % function

    end % methods

    methods (TestMethodSetup)

        function clearChidataDir(tc) %#ok<MANU>
            % Clears the chidataDir persistent variable
            clear '+cbd/+chidata/dir.m'
        end % function

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