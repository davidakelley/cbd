classdef (Sealed) chidataseriesTest < parentSource
    %CHIDATASERIES is the test suite for cbd.source.chidataseries()
    %
    % USAGE
    %   >> runtests('chidataseriesTest')
    %
    % NOTE:
    %   For general tests of the chidata suite, see CHIDATASUITETEST
    %
    % Santiago I. Sordo Palacios, 2019

    properties
        % The abstract properties from the parent class
        source      = 'chidataseries';
        seriesID    = 'TESTSERIES'
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

        function setupChidatadir(tc)
            % Set-up the CHIDATA directory
            clear '+cbd/+chidata/dir.m'
            thisPath = mfilename('fullpath');
            thisFile = fullfile('source', 'chidataseriesTest');
            supportName = fullfile('chidata', 'support');
            tc.supportDir = strrep(thisPath, thisFile, supportName);
            mkdir(tc.testDir);
            copyfile(tc.supportDir, tc.testDir)
            cbd.chidata.dir(tc.testDir);
        end % function

    end % method-TestMethodSetup

    methods (TestClassTeardown)
        function teardownOnce(tc)
            % Remove the chidata directory
            rmdir(tc.testDir, 's')
            clear '+cbd/+chidata/dir.m'
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
        
        function chidataDirProp(tc)
            [~, props] = tc.testfun(tc.seriesID, tc.opts);
            tc.verifyTrue(isfield(props, 'chidataDir'));
        end % function
        
    end % methods

end % classdef


