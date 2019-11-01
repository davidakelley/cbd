classdef chidataTest < matlab.unittest.TestCase
    %CHIDATATEST is the test suite for the +chidata folder
    %
    % USAGE
    %   >> runtests('chidataTest');
    %
    % Santiago Sordo-Palacios, 2019
    
    properties
        testDir char
        supportDir char
        
        expectedIndex table
        expectedSectionAData table
        expectedSectionAProp struct
        expectedSectionBData table
        expectedSectionBProp struct
        
        badIndex table
        
        section
        data
        props
        
    end % properties
    
    properties (Constant)
        dynamicFields = {'Name', 'DateTimeMod', 'UsernameMod', 'FileMod'};
    end % properties
    
    methods (TestClassSetup)
        
        function getSupportDir(tc)
            % Get the path to the CHIDATA support directory
            thisPath = mfilename('fullpath');
            thisFile = mfilename();
            supportName = 'chidata_support';
            tc.supportDir = fullfile( ...
                strrep(thisPath, thisFile, ''), ...
                supportName);
        end % function
        
        function getExpectedIndex(tc)
            % Create the expected index as a table
            Series = {'series1'; 'series2'; 'series3'};
            Section = {'sectionA'; 'sectionB'; 'sectionB'};
            tc.expectedIndex = table(Series, Section);
        end % function
        
        function getExpectedSectionAData(tc)
            % Create the expected table of data for sectionA
            startDate = 737426;
            dates = startDate:1:startDate+6;
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
            dates = startDate:7:startDate+28;
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
            dates =  {'01/02/2019 12:00', ...
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
    
    methods (Test)
        
        %% Test cbd.chidata.prompt
        function promptUserBreak(tc)
            % Test that a user can break in prompt
        end % function
        
        function promptUserContinue(tc)
            % Test that a user can conitnue in prompt
        end % function
        
        %% Test cbd.chidata.dir
        function dirNotInitialized(tc)
            % Test error to dir call when not initialized
            expectedErr = 'chidata:dir:notInitialized';
            actualErr = @() cbd.chidata.dir();
            tc.verifyError(actualErr, expectedErr);
        end % function
        
        function dirNotPath(tc)
            % Test error when dir call is not a full path
            expectedErr = 'chidata:dir:notPath';
            notPathDir = 'fakedirectory';
            actualErr = @() cbd.chidata.dir(notPathDir);
            tc.verifyError(actualErr, expectedErr);
        end % function
        
        function dirNotFound(tc)
            % Test error when dir is not found
            expectedErr = 'chidata:dir:notFound';
            notFoundDir = 'C:fakedirectory';
            actualErr = @() cbd.chidata.dir(notFoundDir);
            tc.verifyError(actualErr, expectedErr);
        end % function
        
        function dirSet(tc)
            % Test that creating a CHIDATA directory works
            chidataDir = cbd.chidata.dir(tc.testDir);
            % TODO: inputdialog press OK
            tc.verifyEqual(chidataDir, tc.testDir);
        end % function
        
        function dirGet(tc)
            % Test that querying a CHIDATA directory works
            tc.initializeTestDir(tc);
            chidataDir = cbd.chidata.dir();
            tc.verifyEqual(chidataDir, tc.testDir);
        end % function
        
        function dirChange(tc)
            % Test that you can change the CHIDATA directory in a call
            tc.initializeTestDir(tc);
            otherDir = tempname();
            mkdir(otherDir);
            chidataDir = cbd.chidata.dir(otherDir);
            % TODO: inputdialog press OK
            tc.verifyEqual(chidataDir, otherDir);
            rmdir(otherDir, 's');
        end % function
        
        %% Test cbd.chidata.loadIndex
        function indexNotFound(tc)
            % Test that an index file is not found
            tc.initializeTestDir(tc);
            delete(fullfile(tc.testDir, 'index.csv'));
            expectedErr = 'chidata:loadIndex:notFound';
            actualErr = @() cbd.chidata.loadIndex();
            tc.verifyError(actualErr, expectedErr);
        end % function
        
        function indexRead(tc)
            % Test that the index reads-in as expected
            tc.initializeTestDir(tc);
            actualIndex = cbd.chidata.loadIndex();
            tc.verifyEqual(actualIndex, tc.expectedIndex);
        end % function
        
        %% Test cbd.chidata.findSection
        function findSectionEmpty(tc)
            % Test when the section is empty
            expectedErr = 'chidata:findSection:empty';
            actualErr = @() cbd.chidata.findSection( ...
                'badSeries1', tc.badIndex);
            tc.verifyError(actualErr, expectedErr);
        end % function
        
        function findSectionDuplicateCase1(tc)
            % Test when there are duplicate series to the same section
            expectedErr = 'chidata:findSection:duplicate';
            actualErr = @() cbd.chidata.findSection( ...
                'badSeries2', tc.badIndex);
            tc.verifyError(actualErr, expectedErr);
        end % function
        
        function findSectionDuplicateCase2(tc)
            % Test when there are duplicate series to different sections
            expectedErr = 'chidata:findSection:duplicate';
            actualErr = @() cbd.chidata.findSection( ...
                'badSeries3', tc.badIndex);
            tc.verifyError(actualErr, expectedErr);
        end % function
        
        function findSectionMissing(tc)
            % Test when the series is missing
            expectedErr = 'chidata:findSection:missing';
            actualErr = @() cbd.chidata.findSection( ...
                'badSeries4', tc.badIndex);
            tc.verifyError(actualErr, expectedErr);
        end % function
        
        function findSectionPass(tc)
            % Test that the section returns the correct one
            tc.initializeTestDir(tc);
            expectedSection = 'sectionA';
            actualSection = cbd.chidata.findSection( ...
                'series1', tc.expectedIndex);
            tc.verifyEqual(actualSection, expectedSection);
        end % function
        
        %% Test cbd.chidata.loadData
        function dataNotFound(tc)
            % Test that a data file is not found
            tc.initializeTestDir(tc);
            delete(fullfile(tc.testDir, 'sectionA_data.csv'));
            expectedErr = 'chidata:loadData:notFound';
            actualErr = @() cbd.chidata.loadData('sectionA');
            tc.verifyError(actualErr, expectedErr);
        end % function
        
        function dataReadSectionA(tc)
            % Test that the data reads-in as expected
            tc.initializeTestDir(tc);
            actualData = cbd.chidata.loadData('sectionA');
            tc.verifyEqual(actualData, tc.expectedSectionAData);
        end % function
        
        function dataReadSectionB(tc)
            tc.initializeTestDir(tc);
            actualData = cbd.chidata.loadData('sectionB');
            tc.verifyEqual(actualData, tc.expectedSectionBData);
            % Test that multiple timeseries can be read-in as expected
        end % function
        
        function dataReadOneSeries(tc)
            
            
        end % function
        
        %% Test cbd.chidata.loadProps
        function propNotFound(tc)
            % Test that a properties file is not found
            tc.initializeTestDir(tc);
            delete(fullfile(tc.testDir, 'sectionA_prop.csv'));
            expectedErr = 'chidata:loadProps:notFound';
            actualErr = @() cbd.chidata.loadProps('sectionA');
            tc.verifyError(actualErr, expectedErr);
        end % function
        
        function propReadSectionA(tc)
            % Test that the properties structure reads-in correctly
            tc.initializeTestDir(tc);
            actualProps = cbd.chidata.loadProps('sectionA');
            tc.verifyEqual(actualProps, tc.expectedSectionAProp);
        end % function
        
        function propReadSectionB(tc)
            % Test that multiple prop can be read-in as expected
            tc.initializeTestDir(tc);
            actualProps = cbd.chidata.loadProps('sectionB');
            tc.verifyEqual(actualProps, tc.expectedSectionBProp);
        end % function
        
        function propReadOneSeries(tc)
            
            
        end % function
        
        %% Test cbd.chidata.props
        function chidataProps(tc)
            % Tests the props works correctly
            nSer = 5;
            Source = 'Haver';
            Frequency = 'W';
            Magnitude = 7;
            AggType = 'Average';
            DataType = 'USD';
            
            testProps = cbd.chidata.prop(nSer, ...
                'Source', Source, ...
                'Frequency', Frequency, ...
                'Magnitude', Magnitude, ...
                'AggType', AggType, ...
                'DataType', DataType);
            
            for iSer = 1:nSer
                tc.verifyEqual(testProps(iSer).Source, Source);
                tc.verifyEqual(testProps(iSer).Frequency, Frequency);
                tc.verifyEqual(testProps(iSer).Magnitude, Magnitude);
                tc.verifyEqual(testProps(iSer).AggType, AggType);
                tc.verifyEqual(testProps(iSer).DataType, DataType);
            end % for-iSer
        end % function
        
        %% Test cbd.chidata.save
        function saveInvalidSectionErr(tc)
            % Test for invalid section input
            expectedErr = 'chidata:save:invalidSection';
            actualErr = @() cbd.chidata.save( ...
                char.empty, tc.data, tc.props);
            tc.verifyError(actualErr, expectedErr);
        end % function
        
        function saveInvalidDataErr(tc)
            % Test for invalid data input
            expectedErr = 'chidata:save:invalidData';
            actualErr = @() cbd.chidata.save( ...
                tc.section, table.empty, tc.props);
            tc.verifyError(actualErr, expectedErr);
        end % function
        
        function saveInvalidPropsCase1(tc)
            % Test for invalid properties inputs
            expectedErr = 'chidata:save:invalidProps';
            actualErr = @() cbd.chidata.save( ...
                tc.section, tc.data, struct.empty);
            tc.verifyError(actualErr, expectedErr);
            % Test an invalid props structure
        end % function
        
        function saveDataPropMismatchCase1(tc)
            expectedErr = 'chidata:save:dataPropMismatch';
            tc.data.seriesB = tc.data.seriesA;
            actualErr = @() cbd.chidata.save(tc.section, tc.data, tc.props);
            tc.verifyError(actualErr, expectedErr);
        end % function
        
        function saveDataPropMismatchCase2(tc)
            expectedErr = 'chidata:save:dataPropMismatch';
            tc.props(2) = tc.props(1);
            actualErr = @() cbd.chidata.save(tc.section, tc.data, tc.props);
            tc.verifyError(actualErr, expectedErr);
        end % function
        
        function saveInvalidPropsCase2(tc)
            % Test invalid fields in properties structure
            expectedErr = 'chidata:save:invalidProps';
            nFields = length(tc.dynamicFields);
            for iField = 1:nFields
                thisStruct = struct((tc.dynamicFields{iField}), '');
                actualErr = @() cbd.chidata.save(tc.section, tc.data, ...
                    thisStruct);
                tc.verifyError(actualErr, expectedErr)
            end % for-iField
        end % function
        
    end % methods
    
    
end % classdef