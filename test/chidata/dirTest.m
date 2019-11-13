classdef dirTest < chidataSuiteTest
    % Test cbd.chidata.dir
    
    methods (Test)

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
            notFoundDir = 'C:\myfakedirectory';
            actualErr = @() cbd.chidata.dir(notFoundDir);
            tc.verifyError(actualErr, expectedErr);
        end % function

        function dirMakeNew(tc)
            % Test that creating a CHIDATA directory works
            chidataDir = cbd.chidata.dir(tc.testDir);
            % TODO: inputdialog press OK
            % WARNING: 'chidata:dir:makeNew'
            tc.verifyEqual(chidataDir, tc.testDir);
        end % function

        function dirQuery(tc)
            % Test that querying a CHIDATA directory works
            tc.initializeTestDir(tc);
            chidataDir = cbd.chidata.dir();
            tc.verifyEqual(chidataDir, tc.testDir);
        end % function

        function dirChangeLoc(tc)
            % Test that you can change the CHIDATA directory in a call
            tc.initializeTestDir(tc);
            otherDir = tempname();
            mkdir(otherDir);
            chidataDir = cbd.chidata.dir(otherDir);
            % TODO: inputdialog press OK
            % WARNING: 'chidata:dir:changeLoc'
            tc.verifyEqual(chidataDir, otherDir);
            rmdir(otherDir, 's');
        end % function
        
    end % methods
    
end % function