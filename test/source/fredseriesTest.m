classdef (Sealed) fredseriesTest < sourceTest
    %FREDSERIES is the test suite for cbd.source.fredseries()
    %
    % USAGE
    %   >> runtests('fredseriesTest')
    %
    % Santiago I. Sordo Palacios, 2019
    
    properties
        % The abstract properties from the parent class
        source      = 'fredseries';
        seriesID    = 'GDP';
        dbID        = 'FRED';
        testfun     = @(x,y) cbd.source.fredseries(x,y);
        benchmark   = 0.50646; %v1.2.0
    end % properties
    
    properties (Constant)
        % The constant properties for the fredseries tests
        asOf        = '12/31/1999'; % the asOf date to test vintage
        asOfStart   = '6/30/2014'; % the asOfStart to test vintage
        asOfEnd     = today(); % the asOfEnd to test vintage data
    end % properties
    
    properties
        % Other properties needed in fredseries
        apiKey
        fredURL
    end % properties
    
    methods (TestClassSetup)
        
        function fredOpts(tc)
            % Set fredseries-specific options
            tc.opts.dbID = tc.dbID;
            tc.opts.asOf = [];
            tc.opts.asOfStart = [];
            tc.opts.asOfEnd = [];
        end % function
        
        function checkConnectFRED(tc)
            % Test connection to FRED
            [~, ~, foundFRED] = cbd.source.connectFRED();
            tc.fatalAssertTrue(foundFRED);
        end % function
        
    end % methods
    
    methods (Test)
        %% Tests for realtime specification
        function asOfSpecCaseA(tc)
            tc.opts.asOf = tc.asOf;
            tc.opts.asOfStart = tc.asOfStart;
            expectedErr = 'fredseries:asOfSpec';
            actualErr = @() tc.testfun(tc.seriesID, tc.opts);
            tc.verifyError(actualErr, expectedErr);
        end % function
        
        function asOfSpecCaseB(tc)
            tc.opts.asOf = tc.asOf;
            tc.opts.asOfEnd = tc.asOfEnd;
            expectedErr = 'fredseries:asOfSpec';
            actualErr = @() tc.testfun(tc.seriesID, tc.opts);
            tc.verifyError(actualErr, expectedErr);
        end % function
        
        %% Test for asOf
        function missAsOf(tc)
            % Test a pull with missing asOf field
            tc.opts = rmfield(tc.opts, 'asOf');
            actualErr = @() tc.testfun(tc.seriesID, tc.opts);
            expectedErr = 'fredseries:missasOf';
            tc.verifyError(actualErr, expectedErr);
        end % function
        
        function datestrAsOf(tc)
            % Bring in the testset
            testset = tc.testfun(tc.seriesID, tc.opts);
            
            % Test a pull with a datestr asOf
            tc.opts.asOf = tc.asOf;
            dataset = tc.testfun(tc.seriesID, tc.opts);
            tc.verifyNotEqual(size(dataset, 1), size(testset, 1));
        end % function
        
        %% Tests for asOfStart and asOfEnd
        function missAsOfStart(tc)
            % Test a pull with missing asOfStart field
            tc.opts = rmfield(tc.opts, 'asOfStart');
            actualErr = @() tc.testfun(tc.seriesID, tc.opts);
            expectedErr = 'fredseries:missasOfStart';
            tc.verifyError(actualErr, expectedErr);
        end % function
        
        function missAsOfEnd(tc)
            % Test a pull with missing asOfEnd field
            tc.opts = rmfield(tc.opts, 'asOfEnd');
            actualErr = @() tc.testfun(tc.seriesID, tc.opts);
            expectedErr = 'fredseries:missasOfEnd';
            tc.verifyError(actualErr, expectedErr);
        end % function
        
        function datestrAsOfStartAsOfEnd(tc)
            % Bring in the testset
            testset = tc.testfun(tc.seriesID, tc.opts);
            
            % Test a pull with datestr asOfStart and asOfEnd
            tc.opts.asOfStart = tc.asOfStart;
            tc.opts.asOfEnd = tc.asOfEnd;
            dataset = tc.testfun(tc.seriesID, tc.opts);
            tc.verifyGreaterThan(size(dataset, 2), 1);
            tc.verifyEqual(dataset{:,end}, testset{:,end});
        end % function
        
    end % methods
end % classdef
