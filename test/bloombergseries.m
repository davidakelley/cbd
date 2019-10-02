classdef (Sealed) bloombergseries < sourceseries
    %BLOOMBERGSERIES is the test suite for cbd.private.bloombergseries()
    %
    % USAGE
    %   >> runtests('bloombergseries')
    %
    % Santiago I. Sordo Palacios, 2019
    
    properties
        source      = 'bloombergseries';
        seriesID    = 'C_US_EQUITY';
        dbID        = 'BLOOMBERG';
        testfun     = @(x, y) cbd.private.bloombergseries(x, y);
        benchmark   = 7.5766; %v1.2.0
    end % properties
    
    properties (Constant)
        jarPath         = 'C:\blp\DAPI\blpapi3.jar'; % Path to BLP jarfile
        XexpectedFreq   = 'DAILY'; % The default frequency
        XinvalidFreq    = {'INVALID' ,'I'}; % Invalid frequencies
        XshortFreq      = {'D', 'W', 'M', 'Q', 'Y'}; % short frequencies
        XlongFreq       = {'DAILY', 'WEEKLY', 'MONTHLY', 'QUARTERLY', 'YEARLY'};
        XexpectedField  = 'LAST_PRICE'; % The default field
        XotherField     = 'PX_BID';  % Another field to Test pull
    end % properties-constant
    
    methods (TestClassSetup)
        
        function bloombergOpts(tc)
            %sets up the  test class setup for bloombergseries
            tc.opts.dbID = tc.dbID;
            tc.opts.field = '';
            tc.opts.frequency = '';
        end % function
        
        function offWarning(tc) %#ok<MANU>
            warning('off', 'bloombergseries:noYellowKey')
        end % function
        
        function checkJarFile(tc)
            % Check the existence of the BLP jar file
            [~, fmsg] = fileattrib(tc.jarPath);
            foundFile = ~ischar(fmsg);
            tc.fatalAssertTrue(foundFile);
            tc.fatalAssertTrue(fmsg.UserRead);
        end % function
        
        function checkBLPConn(tc)
            % Check the connection to BLP
            try
                warning('off', 'MATLAB:Java:DuplicateClass');
                javaaddpath(tc.jarPath);
                warning('on', 'MATLAB:Java:DuplicateClass');
                c = blp;
                pause(5);
                isbloomberg = isequal(isconnection(c), 1);
            catch
                isbloomberg = false;
            end % try-catch
            tc.fatalAssertTrue(isbloomberg)
        end % function
        
    end % methods
    
    methods (TestClassTeardown)
        
        function onWarning(tc) %#ok<MANU>
            warning('on', 'bloombergseries:noYellowKey')
        end % function
        
    end % methods
    
    methods (Test)
        
        %------------------------------------------------------------------
        % Tests for frequency
        function missFreq(tc)
            % Test pull with missing frequency
            tc.opts = rmfield(tc.opts, 'frequency');
            actualErr = @() tc.testfun(tc.seriesID, tc.opts);
            expectedErr = 'bloombergseries:missfrequency';
            tc.verifyError(actualErr, expectedErr);
        end % function
        
        function nullFreq(tc)
            % Test pull with empty frequency
            tc.opts.frequency = '';
            [~, dataProp] = tc.testfun(tc.seriesID, tc.opts);
            tc.verifyEqual(dataProp.frequency, tc.XexpectedFreq);
        end % function
        
        function invalidFreq(tc)
            expectedErr = 'bloombergseries:invalidFrequency';
            nInv = length(tc.XinvalidFreq);
            for iInv = 1:nInv
                tc.opts.frequency = tc.XinvalidFreq{iInv};
                actualErr = @() tc.testfun(tc.seriesID, tc.opts);
                tc.verifyError(actualErr, expectedErr);
            end % for-iChar
        end % function
        
        function shortFreq(tc)
            % Test pull with explicit short frequencies
            nShortFreqs = length(tc.XshortFreq);
            for jFreq = 1:nShortFreqs
                tc.opts.frequency = tc.XshortFreq{jFreq};
                try
                    [~, props] = tc.testfun(tc.seriesID, tc.opts);
                catch
                    props = struct();
                    props.frequency = '';
                end % try-catch
                expectedFreq = tc.XlongFreq{jFreq};
                tc.verifyEqual(props.frequency, expectedFreq);
            end % for-iFreq
        end % function
        
        function longFreq(tc)
            % Test pull with explicit long frequencies
            nLongFreqs = length(tc.XlongFreq);
            for iFreq = 1:nLongFreqs
                tc.opts.frequency = tc.XlongFreq{iFreq};
                try
                    [~, props] = tc.testfun(tc.seriesID, tc.opts);
                catch
                    props = struct();
                    props.frequency = '';
                end % try-catch
                expectedFreq = tc.XlongFreq{iFreq};
                tc.verifyEqual(props.frequency, expectedFreq);
            end % for-iFreq
        end % function
        
        %------------------------------------------------------------------
        % Tests for field
        function missField(tc)
            % Test pull with a missing field field
            tc.opts = rmfield(tc.opts, 'field');
            actualErr = @() tc.testfun(tc.seriesID, tc.opts);
            expectedErr = 'bloombergseries:missfield';
            tc.verifyError(actualErr, expectedErr);
        end % function
        
        function nullField(tc)
            % Test pull with a blank field
            tc.opts.field = '';
            [data, prop] = tc.testfun(tc.seriesID, tc.opts);
            tc.verifyGreaterThan(size(data, 1), 100);
            tc.verifyEqual(size(data, 2), 1);
            tc.verifyEqual(prop.field, tc.XexpectedField);
        end % function
        
        function invalidField(tc)
            % Test pull with invalid field
            tc.opts.field = 'INVALIDFIELD';
            actualErr = @() tc.testfun(tc.seriesID, tc.opts);
            expectedErr = 'bloombergseries:noPull'; %note ~':invalidField'
            tc.verifyError(actualErr, expectedErr);
        end % function
        
        function expectedField(tc)
            % Test pull with the expected Field
            tc.opts.field = tc.XexpectedField;
            [data, prop] = tc.testfun(tc.seriesID, tc.opts);
            tc.verifyGreaterThan(size(data, 1), 100);
            tc.verifyEqual(size(data, 2), 1);
            tc.verifyEqual(prop.field, tc.XexpectedField);
        end % function
        
        function otherField(tc)
            % Test pull with different field
            tc.opts.field = tc.XotherField;
            [data, prop] = tc.testfun(tc.seriesID, tc.opts);
            tc.verifyGreaterThan(size(data, 1), 100);
            tc.verifyEqual(size(data, 2), 1);
            tc.verifyEqual(prop.field, tc.XotherField);
        end % function
        
    end % methods-test
    
end % classdef-bloombergseries

