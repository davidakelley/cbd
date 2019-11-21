classdef dirTest < chidataSuiteTest
    %DIRTEST is the test suite for cbd.chidata.dir()
    %
    % Santiago Sordo-Palacios, 2019
    
    methods (Test)

        function notInitialized(tc)
            % Test error to dir call when not initialized
            expectedErr = 'chidata:dir:notInitialized';
            actualErr = @() cbd.chidata.dir();
            tc.verifyError(actualErr, expectedErr);
        end % function

        function notFound(tc)
            % Test error when dir is not found
            notFoundDir = tempname();
            actualErr = @() cbd.chidata.dir(notFoundDir);
            expectedErr = 'chidata:dir:notFound';
            tc.verifyError(actualErr, expectedErr);
        end % function

        function makeNew(tc)
            % Test that creating a CHIDATA directory issues a warning
            actualWarn = @() cbd.chidata.dir( ...
                tc.testDir, 'userInput', 'y');
            expectedWarn = 'chidata:dir:makeNew';
            tc.verifyWarning(actualWarn, expectedWarn);
            
            % Test that an index file was created
            indexFname = fullfile(tc.testDir, 'index.csv');
            indexExists = isequal(exist(indexFname, 'file'), 2);
            tc.verifyTrue(indexExists);
        end % function
        
        function setExisting(tc)
            % Test whether an existing chidata directory can be set
            % If this fails, shut down the testing suite
            chidataDir = cbd.chidata.dir(tc.supportDir);
            tc.fatalAssertEqual(chidataDir, tc.supportDir);
        end % function

        function queryExisting(tc)
            % Test that querying a CHIDATA directory works
            tc.initializeTestDir(tc);
            chidataDir = cbd.chidata.dir();
            tc.verifyEqual(chidataDir, tc.testDir);
        end % function

        function changeLoc(tc)
            % Test the warning when a directory is changed
            % Initialize a directory and create one to change to
            tc.initializeTestDir(tc);
            otherDir = tempname();
            mkdir(otherDir);
            
            % Verify that the warning wworks
            expectedWarn = 'chidata:dir:changeLoc';
            actualWarn = @() cbd.chidata.dir(otherDir, 'userInput', 'y');
            tc.verifyWarning(actualWarn, expectedWarn);
            
            % Test that the directory did in fact change by querying
            chidataDir = cbd.chidata.dir();
            tc.verifyEqual(chidataDir, otherDir);
            rmdir(otherDir, 's');
        end % function
        
    end % methods
    
end % function