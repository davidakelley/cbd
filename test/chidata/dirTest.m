classdef dirTest < chidataSuiteTest
    %DIRTEST is the test suite for cbd.chidata.dir()
    %
    % Santiago Sordo-Palacios, 2019
    
    properties
        otherDir char
    end % properties
    
    properties (Constant)
        notFoundDir = tempname();
        makeNewID = 'chidata:dir:makeNew';
        changeLocID = 'chidata:dir:changeLoc';
    end % properties
    
    methods (Static)
        
        function createOtherDir(tc)
            % Create the other directory we change to
            tc.otherDir = tempname();
            mkdir(tc.otherDir);
        end % function
        
        function removeOtherDir(tc)
            % Removes the other directory we change to
            rmdir(tc.otherDir, 's');
        end % function
        
    end % methods
    
    methods (Test)

        function dirNotInitialized(tc)
            % Test error to dir call when not initialized
            expectedErr = 'chidata:dir:notInitialized';
            actualErr = @() cbd.chidata.dir();
            tc.verifyError(actualErr, expectedErr);
        end % function

        function dirNotFound(tc)
            % Test error when dir is not found
            expectedErr = 'chidata:dir:notFound';
            actualErr = @() cbd.chidata.dir(tc.notFoundDir);
            tc.verifyError(actualErr, expectedErr);
        end % function
        
        function dirSetExisting(tc)
            % Test whether an existing chidata directory can be set
            % If this fails, shut down the testing suite
            chidataDir = cbd.chidata.dir(tc.supportDir);
            tc.fatalAssertEqual(chidataDir, tc.supportDir);
        end % function

        function dirMakeNewWarning(tc)
            % Test that creating a CHIDATA directory issues a warning
            actualWarn = @ () cbd.chidata.dir(tc.testDir, ...
                'userInput', 'y');
            tc.verifyWarning(actualWarn, tc.makeNewID);
            
            % Test that an index file was created
            indexFname = fullfile(tc.testDir, 'index.csv');
            indexExists = isequal(exist(indexFname, 'file'), 2);
            tc.verifyTrue(indexExists);
        end % function

        function dirQuery(tc)
            % Test that querying a CHIDATA directory works
            tc.initializeTestDir(tc);
            chidataDir = cbd.chidata.dir();
            tc.verifyEqual(chidataDir, tc.testDir);
        end % function

        function dirChangeLocWarning(tc)
            % Test that you changing directory issues correct warning
            tc.initializeTestDir(tc);
            tc.createOtherDir(tc);
            actualWarn = @() cbd.chidata.dir(tc.otherDir, ...
                'userInput', 'y');
            tc.verifyWarning(actualWarn, tc.changeLocID);
            
            % Test that the directory did in fact change
            chidataDir = cbd.chidata.dir();
            tc.verifyEqual(chidataDir, tc.otherDir);
            tc.removeOtherDir(tc);
        end % function
        
    end % methods
    
end % function