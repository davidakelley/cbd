classdef saveTest < chidataSuiteTest
    % Test the save function
    
    methods (Test)

        % Test cbd.chidata.save
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

    end % methods

end % classdef