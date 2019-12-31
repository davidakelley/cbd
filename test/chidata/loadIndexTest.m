classdef (Sealed) loadIndexTest < parentChidata
    %LOADINEXTEST is the test suite for cbd.chidata.loadIndex
    %
    % Santiago Sordo-Palacios, 2019

    methods (Test)

        function notFound(tc)
            % Test that an index file is not found
            tc.initializeTestDir(tc);
            indexFname = fullfile(tc.testDir, 'index.csv');
            delete(indexFname);
            expectedErr = 'chidata:loadIndex:notFound';
            actualErr = @() cbd.chidata.loadIndex();
            tc.verifyError(actualErr, expectedErr);
        end % function

        function badHeaders(tc)
            % Test the error when the index headers are wrong
            tc.initializeTestDir(tc);
            modifyIndex(tc, 'Section, Series\n');
            actualErr = @() cbd.chidata.loadIndex();
            expectedErr = 'chidata:loadIndex:badHeaders';
            tc.verifyError(actualErr, expectedErr);
        end % function
        
        function emptyIndex(tc)
            % Test whether a new/empty index can be loaded
            tc.initializeTestDir(tc);
            modifyIndex(tc, 'Series, Section\n');
           	index = cbd.chidata.loadIndex();
            tc.verifyEqual(index, containers.Map.empty);
        end % function

        function emptySeries(tc)
            % Test the error when there is an empty series
            tc.initializeTestDir(tc);
            modifyIndex(tc, 'Series, Section\n"", sectionA');
            actualErr = @() cbd.chidata.loadIndex();
            expectedErr = 'chidata:loadIndex:emptySeries';
            tc.verifyError(actualErr, expectedErr);
        end % function

        function emptySections(tc)
            % Test the error when there is an empty section
            tc.initializeTestDir(tc);
            modifyIndex(tc, 'Series, Section\nseriesA, ""');
            actualErr = @() cbd.chidata.loadIndex();
            expectedErr = 'chidata:loadIndex:emptySections';
            tc.verifyError(actualErr, expectedErr);
        end % function

        function duplicateSeriesCase1(tc)
            % Test the error when there are duplicate series in a section
            tc.initializeTestDir(tc);
            newIndexStr = 'Series, Section\nseriesA, sectionA\nseriesA, sectionA';
            modifyIndex(tc, newIndexStr);
            actualErr = @() cbd.chidata.loadIndex();
            expectedErr = 'chidata:loadIndex:duplicateSeries';
            tc.verifyError(actualErr, expectedErr);
        end % function

        function duplicateSeriesCase2(tc)
            % Test the error when there are duplicate series in different
            % sections
            tc.initializeTestDir(tc);
            newIndexStr = 'Series, Section\nseriesA, sectionA\nseriesA, sectionB';
            modifyIndex(tc, newIndexStr);
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

function modifyIndex(tc, newIndexStr)
% General function to modify the index in the directory

indexFname = fullfile(tc.testDir, 'index.csv');
delete(indexFname);
fid = fopen(indexFname, 'w');
fprintf(fid, newIndexStr);
fclose(fid);

end % function