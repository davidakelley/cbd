classdef saveTest < chidataSuiteTest
    %SAVETEST is the test suite for the cbd.chidata.save function
    %
    % Santiago Sordo-Palacios, 2019

    properties
        section char % The sectionName argument
        data table % The data argument
        props struct % The properties argument
    end % properties

    methods (TestClassSetup)

        function loadSaveVars(tc)
            % Loads variables for testing in save()
            tc.section = 'sectionA';
            tc.data = tc.expectedSectionAData;
            tc.props = rmfield(tc.expectedSectionAProp, tc.dynamicFields);
        end % function

    end % methods-TestClassSetup

    methods (Test)
        %% Test the handle inputs step
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
            tc.data.seriesB = tc.data.series1;
            actualErr = @() ...
                cbd.chidata.save(tc.section, tc.data, tc.props);
            tc.verifyError(actualErr, expectedErr);
        end % function

        function saveDataPropMismatchCase2(tc)
            expectedErr = 'chidata:save:dataPropMismatch';
            tc.props(2) = tc.props(1);
            actualErr = @() ...
                cbd.chidata.save(tc.section, tc.data, tc.props);
            tc.verifyError(actualErr, expectedErr);
        end % function

        function saveInvalidPropsCase2(tc)
            % Test invalid fields in properties structure
            expectedErr = 'chidata:save:invalidProps';
            nFields = length(tc.dynamicFields);
            for iField = 1:nFields
                thisStruct = struct((tc.dynamicFields{iField}), '');
                actualErr = @() ...
                    cbd.chidata.save(tc.section, tc.data, thisStruct);
                tc.verifyError(actualErr, expectedErr)
            end % for-iField
        end % function
        
        %% Test the index step
        function saveAddNewSection(tc)
            % Set-up the environemtn
            tc.initializeTestDir(tc);
            expectedWarn = 'chidata:updateIndex:addSection';
            
            % Create the new section, data, and props
            expSection = 'newSection';
            expSeries = 'newSeries';
            tc.data.Properties.VariableNames = {expSeries};
            expData = tc.data;
            expProps = tc.props;
            
            % Check that the right warning was issued
            actualWarn = @ () cbd.chidata.save( ...
                expSection, expData, expProps, 'userInput', 'y');
            tc.verifyWarning(actualWarn, expectedWarn);
            
            % Check that the index was updated
            index = cbd.chidata.loadIndex();
            actualSection = index(expSeries);
            tc.verifyEqual(actualSection, expSection);
            
            % Check that the data were saved
            actualData = cbd.chidata.loadData(expSection, expSeries);
            tc.verifyEqual(actualData, expData);
            
            % Check that the properties were updated
            actualProps = cbd.chidata.loadProps(expSection, expSeries);
            actualProps = rmfield(actualProps, tc.dynamicFields);
            tc.verifyEqual(actualProps, expProps);
        end % function
        
    end % methods

end % classdef