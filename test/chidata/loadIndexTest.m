classdef loadIndexTest < chidataSuiteTest
    % Test cbd.chidata.loadIndex
    
    methods (Test)
        
        function indexNotFound(tc)
            % Test that an index file is not found
            tc.initializeTestDir(tc);
            indexFname = fullfile(tc.testDir, 'index.csv');
            delete(indexFname);
            expectedErr = 'chidata:loadIndex:notFound';
            actualErr = @() cbd.chidata.loadIndex();
            tc.verifyError(actualErr, expectedErr);
        end % function

        function indexBadHeaders(tc)
            % Test the error when the index headers are wrong
            tc.initializeTestDir(tc);
            oldIndexFname = fullfile(tc.testDir, 'index.csv');
            delete(oldIndexFname);
            badHeaderFname = fullfile(tc.testDir, 'indexBadHeaders.csv');
            movefile(badHeaderFname, oldIndexFname);
            actualErr = @() cbd.chidata.loadIndex();
            expectedErr = 'chidata:loadIndex:badHeaders';
            tc.verifyError(actualErr, expectedErr);
        end % function

        function indexRead(tc)
            % Test that the index reads-in as expected
            tc.initializeTestDir(tc);
            actualIndex = cbd.chidata.loadIndex();
            tc.verifyEqual(actualIndex, tc.expectedIndex);
        end % function
        
    end % methods
    
end % classdef