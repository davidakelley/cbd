classdef (Sealed) bloombergseriesTest < sourceTest
    %BLOOMBERGSERIES is the test suite for cbd.source.bloombergseries()
    %
    % USAGE
    %   >> runtests('bloombergseriesTest')
    %
    % SEE ALSO: SOURCETEST
    %
    % Santiago I. Sordo Palacios, 2019

    properties
        source = 'bloombergseries';
        seriesID = 'C_US_EQUITY';
        dbID = 'BLOOMBERG';
        testfun = @(x, y) cbd.source.bloombergseries(x, y);
        benchmark = 7.5766; %v1.2.0
    end % properties

    properties (Constant)
        XexpectedFreq = 'DAILY'; % The default frequency
        XinvalidFreq = {'INVALID', 'I'}; % Invalid frequencies
        XshortFreq = {'D', 'W', 'M', 'Q'}; % short frequencies
        XlongFreq = {'DAILY', 'WEEKLY', 'MONTHLY', 'QUARTERLY'};
        XepectedBbfield = 'LAST_PRICE'; % The default field
        XotherBbfield = 'PX_BID'; % Another field to Test pull
    end % properties-constant

    methods (TestClassSetup)

        function bloombergOpts(tc)
            %sets up the  test class setup for bloombergseries
            tc.opts.dbID = tc.dbID;
            tc.opts.bbfield = '';
            tc.opts.frequency = '';
        end % function

        function checkConnectBloomberg(tc)
            c = cbd.source.connectBloomberg();
            tc.fatalAssertTrue(isequal(isconnection(c), 1))
        end % function

    end % methods

    methods (Test)
        %% Tests for frequency
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

        %% Tests for bbfield
        function missBbfield(tc)
            % Test pull with a missing field bbfield
            tc.opts = rmfield(tc.opts, 'bbfield');
            actualErr = @() tc.testfun(tc.seriesID, tc.opts);
            expectedErr = 'bloombergseries:missbbfield';
            tc.verifyError(actualErr, expectedErr);
        end % function

        function nullBbfield(tc)
            % Test pull with a blank field
            tc.opts.bbfield = '';
            [data, prop] = tc.testfun(tc.seriesID, tc.opts);
            tc.verifyGreaterThan(size(data, 1), 100);
            tc.verifyEqual(size(data, 2), 1);
            tc.verifyEqual(prop.bbfield, tc.XepectedBbfield);
        end % function

        function invalidBbfield(tc)
            % Test pull with invalid field
            tc.opts.bbfield = 'INVALIDBBFIELD';
            actualErr = @() tc.testfun(tc.seriesID, tc.opts);
            % note that the following error is NOT 'invalidBbfield' 
            % because there is no difference between a noPull and a bad 
            % field when it comes to history()
            expectedErr = 'bloombergseries:noPull'; 
            tc.verifyError(actualErr, expectedErr);
        end % function

        function expectedBbfield(tc)
            % Test pull with the expected Bbfield
            tc.opts.bbfield = tc.XepectedBbfield;
            [data, prop] = tc.testfun(tc.seriesID, tc.opts);
            tc.verifyGreaterThan(size(data, 1), 100);
            tc.verifyEqual(size(data, 2), 1);
            tc.verifyEqual(prop.bbfield, tc.XepectedBbfield);
        end % function

        function otherBbfield(tc)
            % Test pull with different field
            tc.opts.bbfield = tc.XotherBbfield;
            [data, prop] = tc.testfun(tc.seriesID, tc.opts);
            tc.verifyGreaterThan(size(data, 1), 100);
            tc.verifyEqual(size(data, 2), 1);
            tc.verifyEqual(prop.bbfield, tc.XotherBbfield);
        end % function

    end % methods-test

end % classdef-bloombergseries
