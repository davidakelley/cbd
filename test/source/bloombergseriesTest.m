classdef (Sealed) bloombergseriesTest < parentSource
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
        XshortFreq = {'D', 'W', 'M', 'Q'}; % short frequencies
        XlongFreq = {'DAILY', 'WEEKLY', 'MONTHLY', 'QUARTERLY'};
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
            expectedFreq = 'DAILY';
            [~, dataProp] = tc.testfun(tc.seriesID, tc.opts);
            tc.verifyEqual(dataProp.frequency, expectedFreq);
        end % function

        function invalidFreq(tc)
            expectedErr = 'bloombergseries:invalidfrequency';
            invalidFreqCell = {'INVALID', 'I'};
            nInv = length(invalidFreqCell);
            for iInv = 1:nInv
                tc.opts.frequency = invalidFreqCell{iInv};
                actualErr = @() tc.testfun(tc.seriesID, tc.opts);
                tc.verifyError(actualErr, expectedErr);
            end % for-iChar
        end % function

        function shortFreq(tc)
            % Test pull with explicit short frequencies
            nShortFreqs = length(tc.XshortFreq);
            for jFreq = 1:nShortFreqs
                tc.opts.frequency = tc.XshortFreq{jFreq};
                [~, props] = tc.testfun(tc.seriesID, tc.opts);
                expectedFreq = tc.XlongFreq{jFreq};
                tc.verifyEqual(props.frequency, expectedFreq);
            end % for-iFreq
        end % function

        function longFreq(tc)
            % Test pull with explicit long frequencies
            nLongFreqs = length(tc.XlongFreq);
            for iFreq = 1:nLongFreqs
                tc.opts.frequency = tc.XlongFreq{iFreq};
                [~, props] = tc.testfun(tc.seriesID, tc.opts);
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
            % Test pull with a blank bbfield
            tc.opts.bbfield = '';
            expectedBbfield = 'LAST_PRICE';
            [data, prop] = tc.testfun(tc.seriesID, tc.opts);
            tc.verifyGreaterThan(size(data, 1), 100);
            tc.verifyEqual(size(data, 2), 1);
            tc.verifyEqual(prop.bbfield, expectedBbfield);
        end % function

        function invalidBbfield(tc)
            % Test pull with an invalid bbfield
            % Note: This field should not be defined at all in Bloomberg
            tc.opts.bbfield = 'INVALIDBBFIELD';
            actualErr = @() tc.testfun(tc.seriesID, tc.opts);
            expectedErr = 'bloombergseries:invalidbbfield'; 
            tc.verifyError(actualErr, expectedErr);
        end % function

        function expectedBbfield(tc)
            % Test pull with the expected bbfield
            tc.opts.bbfield = 'LAST_PRICE';
            [data, prop] = tc.testfun(tc.seriesID, tc.opts);
            tc.verifyGreaterThan(size(data, 1), 100);
            tc.verifyEqual(size(data, 2), 1);
            tc.verifyEqual(prop.bbfield, tc.opts.bbfield);
        end % function

        function otherBbfield(tc)
            % Test pull with different bbfield than the default
            tc.opts.bbfield = 'PX_BID';
            [data, prop] = tc.testfun(tc.seriesID, tc.opts);
            tc.verifyGreaterThan(size(data, 1), 100);
            tc.verifyEqual(size(data, 2), 1);
            tc.verifyEqual(prop.bbfield, tc.opts.bbfield);
        end % function
        
        %% Test error when pulling undefined fields and time ranges
        function nanPullField(tc)
            % Test a field that exists but is undefined for a security
            tc.seriesID = 'GDP_CQOQ_Index';
            tc.opts.bbfield = 'ASK_SIZE';
            expectedWarn = 'bloombergseries:nanPull';
            actualWarn = @() tc.testfun(tc.seriesID, tc.opts);
            tc.verifyWarning(actualWarn, expectedWarn);
        end % function
        
        function nanPullTimeRange(tc)
            % Test a security that is undefined between a time range
            tc.seriesID = 'USB8WAM_Index';
            tc.opts.startDate = '01-Jan-2016';
            tc.opts.endDate = '31-Dec-2017';
            expectedWarn = 'bloombergseries:nanPull';
            actualWarn = @() tc.testfun(tc.seriesID, tc.opts);
            tc.verifyWarning(actualWarn, expectedWarn);
        end % function

    end % methods-test

end % classdef-bloombergseries
