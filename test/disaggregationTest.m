classdef disaggregationTest < matlab.unittest.TestCase
    %DISSAGREGATIONTEST is the test suite for cbd.disagg();
    %
    % Each test here works by comparing a computed result against a value
    % taken from the Haver DLXVG3. This is all done against data from the
    % ASREPGDP database because those data series will not be updated
    %
    % The support CHIDATA directory is used here because some of the 
    % tests require premade data to test that aggregation works properly
    %
    % David Kelley, 2015

    properties
        AgdpVal
        gdpVal
        bbIndexVal
        lrVal
        nfciVal
        testDir
        supportDir
    end

    methods (TestClassSetup)
        
        function setupChidatadir(tc)
            % Set-up the CHIDATA directory
            clear '+cbd/+chidata/dir.m'
            thisPath = mfilename('fullpath');
            thisFile = mfilename();
            supportName = fullfile('chidata', 'support');
            tc.supportDir = strrep(thisPath, thisFile, supportName);
            tc.testDir = tempname();
            mkdir(tc.testDir);
            copyfile(tc.supportDir, tc.testDir)
            cbd.chidata.dir(tc.testDir);
        end
        
        function setupOnce(tc)
            % Pull the necessary data
            tc.AgdpVal = cbd.data('GDPCA@FRED', ...
                'asOf', '1/1/2015', ...
                'startDate', '1/1/2000');
            tc.gdpVal = cbd.data('GDPH0001@ASREPGDP');
            tc.bbIndexVal = cbd.data('BBSOUTLOOK@CHIDATA', ...
                'endDate', '8/31/2015');
            tc.lrVal = cbd.data('UNRATE@FRED', ...
                'asOf', '1/1/2015', ...
                'startDate', '1/1/2000');
            tc.nfciVal = cbd.data('NFCI@FRED', ...
                'asOf', '7/1/2015');
        end
    end
    
    methods (TestClassTeardown)
        function teardownOnce(tc)
            % Remove the chidata directory
            rmdir(tc.testDir, 's')
            clear '+cbd/+chidata/dir.m'
        end % function
    end % methods

    methods (Test)
        %% Nan
        function quarterlyDisaggNan(tc)
            % Annual => monthly
            testVal = cbd.disagg(tc.AgdpVal, 'Q', 'NAN');
            tc.verifyEqual(sum(isnan(testVal{:, :})), 42);
        end

        function monthlyDisaggNan(tc)
            % Quarter => monthly
            testVal = cbd.disagg(tc.gdpVal, 'M', 'NAN');
            tc.verifyEqual(sum(isnan(testVal{:, :})), 328);

            % Annual => monthly
            testVal = cbd.disagg(tc.AgdpVal, 'M', 'NAN');
            tc.verifyEqual(sum(isnan(testVal{:, :})), 154);
        end

        function weeklyDisaggNan(tc)
            % Month => Weekly
            testVal = cbd.disagg(tc.lrVal, 'W', 'NAN');
            tc.verifyEqual(sum(isnan(testVal{:, :})), 600);
            dates = datenum(testVal.Properties.RowNames);
            dateDiff = dates(2:end) - dates(1:end-1);
            tc.verifyEqual(size(unique(dateDiff), 1), 1); % All 7s

            % Quarter => Weekly
            testVal = cbd.disagg(tc.gdpVal, 'W', 'NAN');
            tc.verifyEqual(sum(isnan(testVal{:, :})), 1976);
            dates = datenum(testVal.Properties.RowNames);
            dateDiff = dates(2:end) - dates(1:end-1);
            tc.verifyEqual(size(unique(dateDiff), 1), 1);

            % Annual => Weekly
            testVal = cbd.disagg(tc.AgdpVal, 'W', 'NAN');
            tc.verifyEqual(sum(isnan(testVal{:, :})), 717);
            dates = datenum(testVal.Properties.RowNames);
            dateDiff = dates(2:end) - dates(1:end-1);
            tc.verifyEqual(size(unique(dateDiff), 1), 1);
        end

        function dailyDisaggNan(tc)
            % Weekly => Daily
            testVal = cbd.disagg(tc.nfciVal, 'D', 'NAN');
            tc.verifyEqual(sum(isnan(testVal{:, :})), 8868);
            dates = datenum(testVal.Properties.RowNames);
            dateDiff = dates(2:end) - dates(1:end-1);
            tc.verifyEqual(size(unique(dateDiff), 1), 2); % Weekend and day-to-day

            % Month => Daily
            testVal = cbd.disagg(tc.lrVal, 'D', 'NAN');
            tc.verifyEqual(sum(isnan(testVal{:, :})), 3711);
            dates = datenum(testVal.Properties.RowNames);
            dateDiff = dates(2:end) - dates(1:end-1);
            tc.verifyEqual(size(unique(dateDiff), 1), 2);

            % Quarter => Daily
            testVal = cbd.disagg(tc.gdpVal, 'D', 'NAN');
            tc.verifyEqual(sum(isnan(testVal{:, :})), 10533);
            dates = datenum(testVal.Properties.RowNames);
            dateDiff = dates(2:end) - dates(1:end-1);
            tc.verifyEqual(size(unique(dateDiff), 1), 2);

            % Annual => Daily
            testVal = cbd.disagg(tc.AgdpVal, 'D', 'NAN');
            tc.verifyEqual(sum(isnan(testVal{:, :})), 3638);
            dates = datenum(testVal.Properties.RowNames);
            dateDiff = dates(2:end) - dates(1:end-1);
            tc.verifyEqual(size(unique(dateDiff), 1), 2);
        end

        %% Fill
        function quarterlyDisaggFill(tc)
            % Annual => monthly
            testVal = cbd.disagg(tc.AgdpVal, 'Q', 'FILL');
            tc.verifyLessThanOrEqual(size(unique(testVal{:, :}), 1), ...
                size(tc.AgdpVal, 1));

            tc.verifyEqual(sum(isnan(testVal{:, :})), 0);
        end

        function monthlyDisaggFill(tc)
            % Quarter => monthly
            testVal = cbd.disagg(tc.gdpVal, 'M', 'FILL');
            tc.verifyLessThanOrEqual(size(unique(testVal{:, :}), 1), ...
                size(tc.gdpVal, 1));

            tc.verifyEqual(sum(isnan(testVal{:, :})), 0);

            % Annual => monthly
            testVal = cbd.disagg(tc.AgdpVal, 'M', 'FILL');
            tc.verifyLessThanOrEqual(size(unique(testVal{:, :}), 1), ...
                size(tc.AgdpVal, 1));

            tc.verifyEqual(sum(isnan(testVal{:, :})), 0);
        end

        function weeklyDisaggFill(tc)
            % Month => Weekly
            testVal = cbd.disagg(tc.lrVal, 'W', 'FILL');
            tc.verifyLessThanOrEqual(size(unique(testVal{:, :}), 1), ...
                size(tc.lrVal, 1));

            dates = datenum(testVal.Properties.RowNames);
            dateDiff = dates(2:end) - dates(1:end-1);
            tc.verifyEqual(size(unique(dateDiff), 1), 1);

            tc.verifyEqual(sum(isnan(testVal{:, :})), 1);

            % Quarter => Weekly
            testVal = cbd.disagg(tc.gdpVal, 'W', 'FILL');
            tc.verifyLessThanOrEqual(size(unique(testVal{:, :}), 1), ...
                size(tc.gdpVal, 1));

            dates = datenum(testVal.Properties.RowNames);
            dateDiff = dates(2:end) - dates(1:end-1);
            tc.verifyEqual(size(unique(dateDiff), 1), 1);

            tc.verifyEqual(sum(isnan(testVal{:, :})), 0);

            % Annual => Weekly
            testVal = cbd.disagg(tc.AgdpVal, 'W', 'FILL');
            tc.verifyLessThanOrEqual(size(unique(testVal{~isnan(testVal{:, :}), :}), 1), ...
                size(tc.AgdpVal, 1));

            dates = datenum(testVal.Properties.RowNames);
            dateDiff = dates(2:end) - dates(1:end-1);
            tc.verifyEqual(size(unique(dateDiff), 1), 1);

            tc.verifyEqual(sum(isnan(testVal{:, :})), 1);
        end

        function dailyDisaggFill(tc)
            % Weekly => Daily
            testVal = cbd.disagg(tc.nfciVal, 'D', 'FILL');
            tc.verifyLessThanOrEqual(size(unique(testVal{:, :}), 1), ...
                size(tc.nfciVal, 1));
            tc.verifyGreaterThan(size(unique(testVal{:, :}), 1), 1);

            dates = datenum(testVal.Properties.RowNames);
            dateDiff = dates(2:end) - dates(1:end-1);
            tc.verifyEqual(size(unique(dateDiff), 1), 2); % Weekend and day-to-day

            tc.verifyEqual(sum(isnan(testVal{:, :})), 0);

            % Month => Daily
            testVal = cbd.disagg(tc.lrVal, 'D', 'FILL');
            tc.verifyLessThanOrEqual(size(unique(testVal{:, :}), 1), ...
                size(tc.lrVal, 1));
            tc.verifyGreaterThan(size(unique(testVal{:, :}), 1), 1);

            dates = datenum(testVal.Properties.RowNames);
            dateDiff = dates(2:end) - dates(1:end-1);
            tc.verifyEqual(size(unique(dateDiff), 1), 2);

            tc.verifyEqual(sum(isnan(testVal{:, :})), 0);

            % Quarter => Daily
            testVal = cbd.disagg(tc.gdpVal, 'D', 'FILL');
            tc.verifyLessThanOrEqual(size(unique(testVal{:, :}), 1), ...
                size(tc.gdpVal, 1));
            tc.verifyGreaterThan(size(unique(testVal{:, :}), 1), 1);

            dates = datenum(testVal.Properties.RowNames);
            dateDiff = dates(2:end) - dates(1:end-1);
            tc.verifyEqual(size(unique(dateDiff), 1), 2);

            tc.verifyEqual(sum(isnan(testVal{:, :})), 0);

            % Annual => Daily
            testVal = cbd.disagg(tc.AgdpVal, 'D', 'FILL');
            tc.verifyLessThanOrEqual(size(unique(testVal{:, :}), 1), ...
                size(tc.AgdpVal, 1));
            tc.verifyGreaterThan(size(unique(testVal{:, :}), 1), 1);

            dates = datenum(testVal.Properties.RowNames);
            dateDiff = dates(2:end) - dates(1:end-1);
            tc.verifyEqual(size(unique(dateDiff), 1), 2);

            tc.verifyEqual(sum(isnan(testVal{:, :})), 0);
        end

        %% Interp
        function quarterlyDisaggInterp(tc)
            % Annual => monthly
            testVal = cbd.disagg(tc.AgdpVal, 'Q', 'INTERP');
            tc.verifyGreaterThan(size(unique(testVal{:, :}), 1), ...
                size(tc.AgdpVal, 1));

            tc.verifyEqual(sum(isnan(testVal{:, :})), 3);
        end

        function monthlyDisaggInterp(tc)
            % Quarter => monthly
            testVal = cbd.disagg(tc.gdpVal, 'M', 'INTERP');
            tc.verifyGreaterThan(size(unique(testVal{:, :}), 1), ...
                size(tc.gdpVal, 1));

            tc.verifyEqual(sum(isnan(testVal{:, :})), 2);

            % Annual => monthly
            testVal = cbd.disagg(tc.AgdpVal, 'M', 'INTERP');
            tc.verifyGreaterThan(size(unique(testVal{:, :}), 1), ...
                size(tc.AgdpVal, 1));

            tc.verifyEqual(sum(isnan(testVal{:, :})), 11);
        end

        function weeklyDisaggInterp(tc)
            % Month => Weekly
            testVal = cbd.disagg(tc.lrVal, 'W', 'INTERP');
            tc.verifyGreaterThan(size(unique(testVal{:, :}), 1), ...
                size(tc.lrVal, 1));

            dates = datenum(testVal.Properties.RowNames);
            dateDiff = dates(2:end) - dates(1:end-1);
            tc.verifyEqual(size(unique(dateDiff), 1), 1);

            tc.verifyEqual(sum(isnan(testVal{:, :})), 4);

            % Quarter => Weekly
            testVal = cbd.disagg(tc.gdpVal, 'W', 'INTERP');
            tc.verifyGreaterThan(size(unique(testVal{:, :}), 1), ...
                size(tc.gdpVal, 1));

            dates = datenum(testVal.Properties.RowNames);
            dateDiff = dates(2:end) - dates(1:end-1);
            tc.verifyEqual(size(unique(dateDiff), 1), 1);

            tc.verifyEqual(sum(isnan(testVal{:, :})), 12);

            % Annual => Weekly
            testVal = cbd.disagg(tc.AgdpVal, 'W', 'INTERP');
            tc.verifyGreaterThan(size(unique(testVal{:, :}), 1), ...
                size(tc.AgdpVal, 1));

            dates = datenum(testVal.Properties.RowNames);
            dateDiff = dates(2:end) - dates(1:end-1);
            tc.verifyEqual(size(unique(dateDiff), 1), 1);

            tc.verifyEqual(sum(isnan(testVal{:, :})), 52);
        end

        function DailyDisaggInterp(tc)
            % Weekly => Daily
            testVal = cbd.disagg(tc.nfciVal, 'D', 'INTERP');
            tc.verifyGreaterThan(size(unique(testVal{:, :}), 1), ...
                size(tc.nfciVal, 1));

            dates = datenum(testVal.Properties.RowNames);
            dateDiff = dates(2:end) - dates(1:end-1);
            tc.verifyEqual(size(unique(dateDiff), 1), 2); % Weekend and day-to-day

            tc.verifyEqual(sum(isnan(testVal{:, :})), 4);

            % Month => Daily
            testVal = cbd.disagg(tc.lrVal, 'D', 'INTERP');
            tc.verifyGreaterThan(size(unique(testVal{:, :}), 1), ...
                size(tc.lrVal, 1));

            dates = datenum(testVal.Properties.RowNames);
            dateDiff = dates(2:end) - dates(1:end-1);
            tc.verifyEqual(size(unique(dateDiff), 1), 2);

            tc.verifyEqual(sum(isnan(testVal{:, :})), 20);

            % Quarter => Daily
            testVal = cbd.disagg(tc.gdpVal, 'D', 'INTERP');
            tc.verifyGreaterThan(size(unique(testVal{:, :}), 1), ...
                size(tc.gdpVal, 1));

            dates = datenum(testVal.Properties.RowNames);
            dateDiff = dates(2:end) - dates(1:end-1);
            tc.verifyEqual(size(unique(dateDiff), 1), 2);

            tc.verifyEqual(sum(isnan(testVal{:, :})), 63);

            % Annual => Daily
            testVal = cbd.disagg(tc.AgdpVal, 'D', 'INTERP');
            tc.verifyGreaterThan(size(unique(testVal{:, :}), 1), ...
                size(tc.AgdpVal, 1));

            dates = datenum(testVal.Properties.RowNames);
            dateDiff = dates(2:end) - dates(1:end-1);
            tc.verifyEqual(size(unique(dateDiff), 1), 2);

            tc.verifyEqual(sum(isnan(testVal{:, :})), 259);
        end

        %% Growth
        function QuarterDisaggGrowth(tc)
            % Annual => monthly
            testVal = cbd.disagg(tc.AgdpVal, 'Q', 'GROWTH');
            tc.verifyGreaterThan(size(unique(testVal{:, :}), 1), ...
                size(tc.AgdpVal, 1));

            tc.verifyLessThan(abs(testVal{end, 1}-tc.AgdpVal{end, 1}), 1e9);

            tc.verifyEqual(sum(isnan(testVal{:, :})), 3); % 1st 3 quarters of A1
        end

        function MonthlyDisaggGrowth(tc)
            % Quarter => monthly
            testVal = cbd.disagg(tc.gdpVal, 'M', 'GROWTH');
            tc.verifyGreaterThan(size(unique(testVal{:, :}), 1), ...
                size(tc.gdpVal, 1));

            tc.verifyLessThan(abs(testVal{end, 1}-tc.gdpVal{end, 1}), 1e9);

            tc.verifyEqual(sum(isnan(testVal{:, :})), 2); % 1st 2 months of Q1

            % Annual => monthly
            testVal = cbd.disagg(tc.AgdpVal, 'M', 'GROWTH');
            tc.verifyGreaterThan(size(unique(testVal{:, :}), 1), ...
                size(tc.AgdpVal, 1));

            tc.verifyLessThan(abs(testVal{end, 1}-tc.AgdpVal{end, 1}), 1e9);

            tc.verifyEqual(sum(isnan(testVal{:, :})), 11); % 1st 11 months of A1
        end

        function weeklyDisaggGrowth(tc)
            % Month => Weekly
            testVal = cbd.disagg(tc.lrVal, 'W', 'GROWTH');
            tc.verifyGreaterThan(size(unique(testVal{:, :}), 1), ...
                size(tc.lrVal, 1));

            dates = datenum(testVal.Properties.RowNames);
            dateDiff = dates(2:end) - dates(1:end-1);
            tc.verifyEqual(size(unique(dateDiff), 1), 1);

            tc.verifyLessThan(abs(testVal{end-1, 1}-tc.lrVal{end, 1}), 1e-9);

            % 1st 3 weeks of M1,
            % last week missing too? No its not
            tc.verifyEqual(sum(isnan(testVal{:, :})), 3);

            % Quarter => Weekly
            testVal = cbd.disagg(tc.gdpVal, 'W', 'GROWTH');
            tc.verifyGreaterThan(size(unique(testVal{:, :}), 1), ...
                size(tc.gdpVal, 1));

            dates = datenum(testVal.Properties.RowNames);
            dateDiff = dates(2:end) - dates(1:end-1);
            tc.verifyEqual(size(unique(dateDiff), 1), 1);

            tc.verifyLessThan(abs(testVal{end, 1}-tc.gdpVal{end, 1}), 1e9);

            % 1st 12 weeks of Q1
            tc.verifyEqual(sum(isnan(testVal{:, :})), 12);

            % Annual => Weekly
            testVal = cbd.disagg(tc.AgdpVal, 'W', 'GROWTH');
            tc.verifyGreaterThan(size(unique(testVal{:, :}), 1), ...
                size(tc.AgdpVal, 1));

            dates = datenum(testVal.Properties.RowNames);
            dateDiff = dates(2:end) - dates(1:end-1);
            tc.verifyEqual(size(unique(dateDiff), 1), 1);

            tc.verifyLessThan(abs(testVal{end-1, 1}-tc.AgdpVal{end, 1}), 1e9);

            % 1st 51 weeks of A1, first week of A(end)
            tc.verifyEqual(sum(isnan(testVal{:, :})), 51);
        end

        function dailyDisaggGrowth(tc)
            % Weekly => Daily
            %{
            testVal = cbd.disagg(tc.nfciVal, 'D', 'GROWTH');
            tc.verifyGreaterThan(size(unique(testVal{:,:}), 1), ...
                size(tc.nfciVal, 1));

            dates = datenum(testVal.Properties.RowNames);
            dateDiff = dates(2:end)- dates(1:end-1);
            tc.verifyEqual(size(unique(dateDiff), 1), 2); % Weekend and day-to-day

            tc.verifyEqual(sum(isnan(testVal{:,:})), 4); % First 4 days
            %}

            % Month => Daily
            testVal = cbd.disagg(tc.lrVal, 'D', 'GROWTH');
            tc.verifyGreaterThan(size(unique(testVal{:, :}), 1), ...
                size(tc.lrVal, 1));

            dates = datenum(testVal.Properties.RowNames);
            dateDiff = dates(2:end) - dates(1:end-1);
            tc.verifyEqual(size(unique(dateDiff), 1), 2);

            tc.verifyLessThan(abs(testVal{end, 1}-tc.lrVal{end, 1}), 1e9);

            tc.verifyEqual(sum(isnan(testVal{:, :})), 20); % First 20 days

            % Quarter => Daily
            testVal = cbd.disagg(tc.gdpVal, 'D', 'GROWTH');
            tc.verifyGreaterThan(size(unique(testVal{:, :}), 1), ...
                size(tc.gdpVal, 1));

            dates = datenum(testVal.Properties.RowNames);
            dateDiff = dates(2:end) - dates(1:end-1);
            tc.verifyEqual(size(unique(dateDiff), 1), 2);

            tc.verifyLessThan(abs(testVal{end, 1}-tc.gdpVal{end, 1}), 1e9);

            tc.verifyEqual(sum(isnan(testVal{:, :})), 63); % Not sure on this one

            % Annual => Daily
            testVal = cbd.disagg(tc.AgdpVal, 'D', 'GROWTH');
            tc.verifyGreaterThan(size(unique(testVal{:, :}), 1), ...
                size(tc.AgdpVal, 1));

            dates = datenum(testVal.Properties.RowNames);
            dateDiff = dates(2:end) - dates(1:end-1);
            tc.verifyEqual(size(unique(dateDiff), 1), 2);

            tc.verifyLessThan(abs(testVal{end, 1}-tc.AgdpVal{end, 1}), 1e9);

            tc.verifyEqual(sum(isnan(testVal{:, :})), 259); % Again, not sure
        end

        %% 2 inputs
        function threeInputs(tc)
            % Annual => annual
            testVal = cbd.disagg(tc.AgdpVal, 'A');
            trueVal = cbd.disagg(tc.AgdpVal, 'A', 'NAN');
            tc.verifyEqual(testVal, trueVal);
        end

        %% IRREGULAR
        function disaggToIrregular(tc)
            testVal = cbd.disagg(tc.AgdpVal, 'IRREGULAR', 'NAN');
            tc.verifyEqual(testVal, tc.AgdpVal);
        end

        function disaggFromIrregular(tc)
            % Irregular => monthly
            warning('off', 'cbd:getFreq:oddDates');
            testVal = cbd.disagg(tc.bbIndexVal, 'M', 'NAN');
            warning('on', 'cbd:getFreq:oddDates');
            tc.verifyEqual(sum(isnan(testVal{:, :})), 11);
        end

        %% Disagg to current frequency
        function sameFreq(tc)
            % Annual => annual
            testVal = cbd.disagg(tc.AgdpVal, 'A', 'NAN');
            tc.verifyEqual(size(testVal, 1), size(tc.AgdpVal, 1));
        end
    end
end
