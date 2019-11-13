classdef (Sealed) chidataseriesTest < sourceTest
    %CHIDATASERIES is the test suite for cbd.source.chidataseries()
    %
    % USAGE
    %   >> runtests('chidataseries')
    %
    % NOTE
    % For general tests of the chidata suite, see CHIDATASUITETEST
    %
    % Santiago I. Sordo Palacios, 2019
    
    properties
        % The abstract properties from the parent class
        source      = 'chidataseries';
        seriesID    = 'testSeries'
        dbID        = 'CHIDATA';
        testfun     = @(x,y) cbd.source.chidataseries(x,y);
        benchmark   = 0.24087; %v1.2.0
    end % properties
    
    properties
        % The properties for the chidataseries tests
        testDir = tempname();
        supportDir
    end % properties
    
    methods (TestClassSetup)
        
        function chidataOpts(tc)
            % Set the chidataseries-specific options
            tc.opts.dbID = tc.dbID;
        end % function
        
        function getSupportDir(tc)
            % NOTE: THIS IS COPIED FROM CHIDATATEST
            % Get the path to the CHIDATA support directory
            thisPath = mfilename('fullpath');
            thisFile = mfilename();
            supportName = 'chidata_support';
            tc.supportDir = fullfile( ...
                strrep(thisPath, thisFile, ''), ...
                supportName);
        end % function
        
        function createTestDir(tc)
            % NOTE: THIS IS COPIED FROM CHIDATATEST
            % Creates a directory for performing tests
            mkdir(tc.testDir);
        end % function
        
        function clearChidataDir(tc) %#ok<MANU>
            % NOTE: THIS IS COPIED FROM CHIDATATEST
            % Clears the chidataDir persistent variable
            clear '+cbd/+chidata/dir.m'
        end % function
        
        function initializeTestDir(tc)
            % NOTE: THIS IS COPIED FROM CHIDATATEST
            % Copies support files from supportDir to testDir and
            % initalizes the CHIDATA directory
            copyfile(tc.supportDir, tc.testDir)
            cbd.chidata.dir(tc.testDir);
        end % function
         
    end % method-TestMethodSetup
    
    methods (TestClassTeardown)
        function teardownOnce(tc)
            % Remove the chidata directory
            rmdir(tc.testDir, 's')
        end % function
    end % methods
    
    methods (Test)
        
        % Test the chidata-specific properties
        function aggTypeProp(tc)
            [~, props] = tc.testfun(tc.seriesID, tc.opts);
            tc.verifyTrue(isfield(props.dbInfo, 'AggType'));
        end % function
        
        function dataTypeProp(tc)
            [~, props] = tc.testfun(tc.seriesID, tc.opts);
            tc.verifyTrue(isfield(props.dbInfo, 'DataType'));
        end % function
        
        function frequencyProp(tc)
            [~, props] = tc.testfun(tc.seriesID, tc.opts);
            tc.verifyTrue(isfield(props.dbInfo, 'Frequency'));
        end % function
        
        function magnitudeProp(tc)
            [~, props] = tc.testfun(tc.seriesID, tc.opts);
            tc.verifyTrue(isfield(props.dbInfo, 'Magnitude'));
        end % function
        
        function sourceProp(tc)
            [~, props] = tc.testfun(tc.seriesID, tc.opts);
            tc.verifyTrue(isfield(props.dbInfo, 'Source'));
        end % function
        
        function dateTimeModProp(tc)
            [~, props] = tc.testfun(tc.seriesID, tc.opts);
            tc.verifyTrue(isfield(props.dbInfo, 'DateTimeMod'));
        end % function
        
        function usernameModProp(tc)
            [~, props] = tc.testfun(tc.seriesID, tc.opts);
            tc.verifyTrue(isfield(props.dbInfo, 'UsernameMod'));
        end % function
        
        function fileModProp(tc)
            [~, props] = tc.testfun(tc.seriesID, tc.opts);
            tc.verifyTrue(isfield(props.dbInfo, 'FileMod'));
        end % function        
    end % methods

end % classdef


