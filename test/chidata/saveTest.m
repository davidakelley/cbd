classdef (Sealed) saveTest < parentChidata
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
        %% Test the input handling
        function invalidSectionErr(tc)
            % Test for invalid section input
            expectedErr = 'chidata:save:invalidSection';
            actualErr = @() cbd.chidata.save( ...
                char.empty, tc.data, tc.props);
            tc.verifyError(actualErr, expectedErr);
        end % function

        function invalidDataErr(tc)
            % Test for invalid data input
            expectedErr = 'chidata:save:invalidData';
            actualErr = @() cbd.chidata.save( ...
                tc.section, table.empty, tc.props);
            tc.verifyError(actualErr, expectedErr);
        end % function

        function invalidProps(tc)
            % Test for invalid properties inputs
            expectedErr = 'chidata:save:invalidProps';
            actualErr = @() cbd.chidata.save( ...
                tc.section, tc.data, struct.empty);
            tc.verifyError(actualErr, expectedErr);
            % Test an invalid props structure
        end % function

        function dataPropMismatchCase1(tc)
            % Test when the series in data are more than props
            expectedErr = 'chidata:save:dataPropMismatch';
            tc.data.seriesB = tc.data.SERIES1;
            actualErr = @() ...
                cbd.chidata.save(tc.section, tc.data, tc.props);
            tc.verifyError(actualErr, expectedErr);
        end % function

        function dataPropMismatchCase2(tc)
            % Test when the series in props are more than data
            expectedErr = 'chidata:save:dataPropMismatch';
            tc.props(2) = tc.props(1);
            actualErr = @() ...
                cbd.chidata.save(tc.section, tc.data, tc.props);
            tc.verifyError(actualErr, expectedErr);
        end % function
        
        %% Test updating a CHIDATA directory
        function updateExisting(tc)
            % Set-up the environemnt
            tc.initializeTestDir(tc);
            
            % Save the existing data
            saved = cbd.chidata.save(tc.section, tc.data, tc.props, ...
                'userInput', 'n');
            tc.verifyTrue(saved);
        end % function
        
        function addNewSection(tc)
            % Set-up the environemnt
            tc.initializeTestDir(tc);
            expectedWarn = 'chidata:updateIndex:addSection';
            
            % Create the new section, data, and props
            expSection = 'NEWSECTION';
            expSeries = 'NEWSERIES';
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