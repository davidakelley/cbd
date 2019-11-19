classdef loadIndexTest < chidataSuiteTest
    %LOADINEXTEST is the test suite for cbd.chidata.loadIndex
    %
    % Santiago Sordo-Palacios, 2019
    
    methods (Static)
        
        function modifyIndex(tc, newIndexStr)
            % General function to modify the index in the directory
            indexFname = fullfile(tc.testDir, 'index.csv');
            delete(indexFname);
            fid = fopen(indexFname, 'w');
            fprintf(fid, newIndexStr);
            fclose(fid);
        end % function   
        
    end % methods
    
    methods (Test)
        
        function testNotFound(tc)
            % Test that an index file is not found
            tc.initializeTestDir(tc);
            indexFname = fullfile(tc.testDir, 'index.csv');
            delete(indexFname);
            expectedErr = 'chidata:loadIndex:notFound';
            actualErr = @() cbd.chidata.loadIndex();
            tc.verifyError(actualErr, expectedErr);
        end % function

        function testBadHeaders(tc)
            % Test the error when the index headers are wrong
            tc.initializeTestDir(tc);
            tc.modifyIndex(tc, 'Section, Series\n');
            actualErr = @() cbd.chidata.loadIndex();
            expectedErr = 'chidata:loadIndex:badHeaders';
            tc.verifyError(actualErr, expectedErr);
        end % function
        
        function testEmptySeries(tc)
            % Test the error when there is an empty series
            tc.initializeTestDir(tc);
            tc.modifyIndex(tc, 'Series, Section\n"", sectionA');
            actualErr = @() cbd.chidata.loadIndex();
            expectedErr = 'chidata:loadIndex:emptySeries';
            tc.verifyError(actualErr, expectedErr);
        end % function

        function testEmptySection(tc)
            % Test the error when there is an empty section
            tc.initializeTestDir(tc);
            tc.modifyIndex(tc, 'Series, Section\nseriesA, ""');
            actualErr = @() cbd.chidata.loadIndex();
            expectedErr = 'chidata:loadIndex:emptySections';
            tc.verifyError(actualErr, expectedErr);
        end % function
        
        function testDuplicateSeriesCase1(tc)
            % Test the error when there are duplicate series in a section
            tc.initializeTestDir(tc);
            newIndexStr = 'Series, Section\nseriesA, sectionA\nseriesA, sectionA';
            tc.modifyIndex(tc, newIndexStr);
            actualErr = @() cbd.chidata.loadIndex();
            expectedErr = 'chidata:loadIndex:duplicateSeries';
            tc.verifyError(actualErr, expectedErr);
        end % function      
        
        function testDuplicateSeriesCase2(tc)
            % Test the error when there are duplicate series in different
            % sections
            tc.initializeTestDir(tc);
            newIndexStr = 'Series, Section\nseriesA, sectionA\nseriesA, sectionB';
            tc.modifyIndex(tc, newIndexStr);
            actualErr = @() cbd.chidata.loadIndex();
            expectedErr = 'chidata:loadIndex:duplicateSeries';
            tc.verifyError(actualErr, expectedErr);
        end % function      
        
        function testIndexRead(tc)
            % Test that the index reads-in as expected
            tc.initializeTestDir(tc);
            actualIndex = cbd.chidata.loadIndex();
            tc.verifyEqual(actualIndex, tc.expectedIndex);
        end % function
        
    end % methods
    
end % classdef