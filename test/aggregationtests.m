%% Test suite for the multi-series functions in cbd.
% 
% Each test here works by comparing a computed result against a value 
% taken from the Haver DLXVG3. This is all done against data from the 
% ASREPGDP database because those data series will not be updated again. 
% Note that the integration with cbd.data is tested in each function here
% as well.
%
% See also: execTests.m

% David Kelley, 2015

classdef aggregationtests < matlab.unittest.TestCase
    properties
        gdpVal
    end
    
    methods(TestMethodSetup)
        function setupAll(testCase)
            testCase.gdpVal = cbd.data('GDPH0001@ASREPGDP');
        end
    end
    
    methods (Test)
        %% Multi-series functions
        function testAnnualAgg(testCase)
            % Quarter => annual
            testVal = cbd.data({'GDPHA', 'AGG(GDPH, "A", "AVG")'});
            testCase.verifyLessThan(max(abs(testVal{:,1} - testVal{:,2})), .051);
                        
            % Month => annual
            testVal = cbd.data({'JAC', 'AGG(JCBM, "A", "AVG")'});
            testCase.verifyLessThan(max(abs(testVal{:,1} - testVal{:,2})), .0051);
        end
        
        function testQuarterAgg(testCase)
            % Month => quarter
            testVal = cbd.data({'JC', 'AGG(JCBM, "Q", "AVG")'});
            testCase.verifyLessThan(max(abs(testVal{:,1} - testVal{:,2})), .0051); 
        end
        
        function testMonthAgg(testCase)
            % Day => month
            testVal = cbd.data({'FCM10', 'AGG(FCM10@DAILY, "M", "AVG")'});
            testCase.verifyLessThan(max(abs(testVal{:,1} - testVal{:,2})), .01); 
            
            % week => month
            % Volatility in the 1980s makes this difficult. Only take the
            % last 100 values.
            testVal = cbd.data({'FCM10', 'AGG(FCM10@DAILY, "M", "AVG")'});
            testCase.verifyLessThan(max(abs(testVal{end-100:end,1} - testVal{end-100:end,2})), .06);
        end
        
        function testAvg(testCase)
            testVal = cbd.data({'PETEXA', 'AGG(PETEXA@DAILY, "M", "AVG")'});
            testCase.verifyLessThan(max(abs(testVal{:,1} - testVal{:,2})), .01); 
        end
        
        function testEop(testCase)
            testVal = cbd.data({'PETEXAE', 'AGG(PETEXA@DAILY, "M", "EOP")'});
            testCase.verifyLessThan(max(abs(testVal{:,1} - testVal{:,2})), .00001);            
        end
        
        function testSum(testCase)
            testVal = cbd.data({'AGG(FRBPMOS, "A", "SUM")', 'AGG(FRBPMOS@DAILY, "A", "SUM")'});
            testCase.verifyLessThan(max(abs(testVal{:,1} - testVal{:,2})), .00001);                        
        end
        
        function testNansum(testCase)
            testVal = cbd.data({'AGG(FRBPMOS, "A", "NANSUM")', 'AGG(FRBPMOS@DAILY, "A", "NANSUM")'});
            testCase.verifyLessThan(max(abs(testVal{:,1} - testVal{:,2})), .00001);                        
        end
        
        function testNanavg(testCase)
            testVal = cbd.data({'PETEXA', 'AGG(PETEXA@DAILY, "M", "NANAVG")'});
            testCase.verifyLessThan(max(abs(testVal{:,1} - testVal{:,2})), .01);           
        end
        
        function testSingleOutput(testCase)
            t1 = cbd.data('AGG(MLU67G@CHIDATA, "A", "EOP")', 'startDate', '1/1/2014', 'endDate', '12/31/2014');
            testCase.verifyTrue(~isnan(t1{1,1}));
        end
    end
end
