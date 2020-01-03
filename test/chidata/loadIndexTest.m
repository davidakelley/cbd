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
            modifyIndex(tc, 'Series, Section\n"", SECTIONA');
            actualErr = @() cbd.chidata.loadIndex();
            expectedErr = 'chidata:loadIndex:emptySeries';
            tc.verifyError(actualErr, expectedErr);
        end % function
        
        function emptySeriesMultiple(tc)
            % Test the error when there are multiple empty series
            tc.initializeTestDir(tc);
            modifyIndex(tc, 'Series, Section\nSERIESA, SECTIONA\n"", SECTIONB\n"", SECTIONC');
            actualErr = @() cbd.chidata.loadIndex();
            expectedErr = 'chidata:loadIndex:emptySeries';
            tc.verifyError(actualErr, expectedErr);
        end % function

        function emptySections(tc)
            % Test the error when there is an empty section
            tc.initializeTestDir(tc);
            modifyIndex(tc, 'Series, Section\nSERIESA, ""');
            actualErr = @() cbd.chidata.loadIndex();
            expectedErr = 'chidata:loadIndex:emptySections';
            tc.verifyError(actualErr, expectedErr);
        end % function
        
        function emptySectionsMultiple(tc)
            % Test the error when there is an empty section
            tc.initializeTestDir(tc);
            modifyIndex(tc, 'Series, Section\nSERIES1, SECTIONA\nSERIES2, ""\nSERIES3, ""');
            actualErr = @() cbd.chidata.loadIndex();
            expectedErr = 'chidata:loadIndex:emptySections';
            tc.verifyError(actualErr, expectedErr);
        end % function

        function duplicateSeriesSameSection(tc)
            % Test the error when there are duplicate series in a section
            tc.initializeTestDir(tc);
            newIndexStr = 'Series, Section\nSERIESA, SECTIONA\nSERIESA, SECTIONA';
            modifyIndex(tc, newIndexStr);
            actualErr = @() cbd.chidata.loadIndex();
            expectedErr = 'chidata:loadIndex:duplicateSeries';
            tc.verifyError(actualErr, expectedErr);
        end % function

        function duplicateSeriesDiffSection(tc)
            % Test the error when there are duplicate series in different
            % sections
            tc.initializeTestDir(tc);
            newIndexStr = 'Series, Section\nSERIESA, SECTIONA\nSERIESA, SECTIONB';
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
        
        function testIndexReadLower(tc)
            % Test that an index that is lower case reads in correctly
            tc.initializeTestDir(tc);
            newIndexStr = 'Series, Section\nseriesa, sectiona';
            modifyIndex(tc, newIndexStr);
            actualIndex = cbd.chidata.loadIndex();
            tc.verifyEqual(keys(actualIndex), {'SERIESA'});
            tc.verifyEqual(values(actualIndex), {'SECTIONA'});
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