classdef aggregationTest < matlab.unittest.TestCase
    %AGGREGATIONTEST is the test suite for cbd.agg();
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
        gdpVal
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
        
        function setupOnce(testCase)
            testCase.gdpVal = cbd.expression('GDPH0001@ASREPGDP');
        end
    end
    
    methods (TestClassTeardown)
        function teardownOnce(tc)
            % Remove the chidata directory
            rmdir(tc.testDir, 's')
            clear '+cbd/+chidata/dir.m'
        end
    end

    methods (Test)
        %% Multi-series functions
        function annualAgg(testCase)
            % Quarter => annual
            testVal = cbd.expression({'GDPHA', ...
                'AGG(GDPH, "A", "AVG")'});
            testCase.verifyLessThan( ...
                max(abs(testVal{:, 1}-testVal{:, 2})), .076);

            % Month => annual
            testVal = cbd.expression({'JAC', ...
                'AGG(JCBM, "A", "AVG")'});
            testCase.verifyLessThan( ...
                max(abs(testVal{:, 1}-testVal{:, 2})), .0051);
        end

        function quarterAgg(testCase)
            % Month => quarter
            testVal = cbd.expression({'JC', ...
                'AGG(JCBM, "Q", "AVG")'});
            testCase.verifyLessThan( ...
                max(abs(testVal{:, 1}-testVal{:, 2})), .0051);
        end

        function monthAgg(testCase)
            % Day => month
            testVal = cbd.expression({'FCM10', ...
                'AGG(FCM10@DAILY, "M", "AVG")'});
            testCase.verifyLessThan( ...
                max(abs(testVal{:, 1}-testVal{:, 2})), .01);

            % week => month
            % Volatility in the 1980s makes this difficult. Only take the
            % last 100 values.
            testVal = cbd.expression( ...
                {'FCM10', 'AGG(FCM10@DAILY, "M", "AVG")'});
            testCase.verifyLessThan( ...
                max(abs(testVal{end-100:end, 1}-testVal{end-100:end, 2})), ...
                .06);
        end

        function avg(testCase)
            testVal = cbd.expression({'PETEXA', ...
                'AGG(PETEXA@DAILY, "M", "AVG")'});
            testCase.verifyLessThan( ...
                max(abs(testVal{:, 1}-testVal{:, 2})), .03); % Could reset to 0.01 tol
        end

        function eop(testCase)
            testVal = cbd.expression({'PETEXAE', ...
                'AGG(PETEXA@DAILY, "M", "EOP")'});
            testCase.verifyLessThan( ...
                max(abs(testVal{:, 1}-testVal{:, 2})), .00001);
        end

        function sum(testCase)
            testVal = cbd.expression({'AGG(FRBPMOS, "A", "SUM")', ...
                'AGG(FRBPMOS@DAILY, "A", "SUM")'});
            testCase.verifyLessThan( ...
                max(abs(testVal{:, 1}-testVal{:, 2})), .00001);
        end

        function nansum(testCase)
            testVal = cbd.expression({'AGG(FRBPMOS, "A", "NANSUM")', ...
                'AGG(FRBPMOS@DAILY, "A", "NANSUM")'});
            testCase.verifyLessThan( ...
                max(abs(testVal{:, 1}-testVal{:, 2})), .00001);
        end

        function nanavg(testCase)
            testVal = cbd.expression({'PETEXA', ...
                'AGG(PETEXA@DAILY, "M", "NANAVG")'});
            testCase.verifyLessThan( ...
                max(abs(testVal{:, 1}-testVal{:, 2})), .03);
        end

        function singleOutput(testCase)
            t1 = cbd.expression('AGG(MLU67G@CHIDATA, "A", "EOP")', ...
                'startDate', '1/1/2014', 'endDate', '12/31/2014');
            testCase.verifyTrue(~isnan(t1{1, 1}));
        end
    end
end
