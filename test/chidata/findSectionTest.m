classdef findSectionTest < chidataSuiteTest
    % Test cbd.chidata.findSection
    
    methods (Test) 
        
        function findSectionEmpty(tc)
            % Test when the section is empty for a given series
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
                'seriesA', tc.expectedIndex);
            tc.verifyEqual(actualSection, expectedSection);
        end % function
    
    end % methods
    
end % classdef