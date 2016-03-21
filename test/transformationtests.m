%% Test suite for the transformation functions in cbd.
%
% Each test here works by calling cbd.data and comparing a computed result
% against a value taken from the Haver DLXVG3. This is all done against
% data from the ASREPGDP database because those data series will not be
% updated again.
%
% See also: execTests.m

% David Kelley, 2015

classdef transformationtests < matlab.unittest.TestCase
  properties
    gdph
  end
  
  methods(TestMethodSetup)
    function setupOnce(testCase)
      testCase.gdph = cbd.data('GDPH0001@ASREPGDP');
    end
  end
  
  methods (Test)
    % Lag
    function testLag(testCase)
      testD = (1:10)';
      lagTestD = [nan 1:9]';
      testCase.verifyEqual(cbd.lag(testD), lagTestD);
      
      testD = (1:10)';
      lagTestD = [nan nan 1:8]';
      testCase.verifyEqual(cbd.lag(testD, 2), lagTestD);
      
      testD = (1:10)';
      lagTestD = [2:10 nan]';
      testCase.verifyEqual(cbd.lag(testD, -1), lagTestD);
    end
    
    % Differences
    function testDiff(testCase)
      lastVal = cbd.last(cbd.diff(testCase.gdph));
      testCase.verifyEqual(lastVal{1,1}, 126.3, 'AbsTol', 0.1);
      
      lastVal = cbd.last(cbd.diff(testCase.gdph, 4));
      testCase.verifyEqual(lastVal{1,1}, 367.7, 'AbsTol', 0.1);
    end
    
    function testDifa(testCase)
      lastVal = cbd.last(cbd.difa(testCase.gdph));
      testCase.verifyEqual(lastVal{1,1}, 505.2, 'AbsTol', 0.1);
      
      lastVal = cbd.last(cbd.difa(testCase.gdph, 4));
      testCase.verifyEqual(lastVal{1,1}, 367.7, 'AbsTol', 0.1);
    end
    
    function testDifv(testCase)
      lastVal = cbd.last(cbd.difv(testCase.gdph));
      testCase.verifyEqual(lastVal{1,1}, 126.3, 'AbsTol', 0.1);
      
      lastVal = cbd.last(cbd.difv(testCase.gdph, 4));
      testCase.verifyEqual(lastVal{1,1}, 91.9, 'AbsTol', 0.1);
    end
    
    % Logs
    function testDiffl(testCase)
      lastVal = cbd.last(cbd.diffl(testCase.gdph));
      testCase.verifyEqual(lastVal{1,1}, 1.40903, 'AbsTol', 0.0001);
      
      lastVal = cbd.last(cbd.diffl(testCase.gdph, 4));
      testCase.verifyEqual(lastVal{1,1}, 4.15867, 'AbsTol', 0.0001);
    end
    
    function testDifal(testCase)
      lastVal = cbd.last(cbd.difal(testCase.gdph));
      testCase.verifyEqual(lastVal{1,1}, 5.63613, 'AbsTol', 0.0001);
      
      lastVal = cbd.last(cbd.difal(testCase.gdph, 4));
      testCase.verifyEqual(lastVal{1,1}, 4.15867, 'AbsTol', 0.0001);
    end
    
    function testDifvl(testCase)
      lastVal = cbd.last(cbd.difvl(testCase.gdph));
      testCase.verifyEqual(lastVal{1,1}, 1.40903, 'AbsTol', 0.0001);
      
      lastVal = cbd.last(cbd.difvl(testCase.gdph, 4));
      testCase.verifyEqual(lastVal{1,1}, 1.03967, 'AbsTol', 0.0001);
    end
    
    % Percentages
    function testDiffPct(testCase)
      lastVal = cbd.last(cbd.diffPct(testCase.gdph));
      testCase.verifyEqual(lastVal{1,1}, 1.41901, 'AbsTol', 0.0001);
      
      lastVal = cbd.last(cbd.diffPct(testCase.gdph, 4));
      testCase.verifyEqual(lastVal{1,1}, 4.24635, 'AbsTol', 0.0001);
    end
    
    function testDifaPct(testCase)
      lastVal = cbd.last(cbd.difaPct(testCase.gdph));
      testCase.verifyEqual(lastVal{1,1}, 5.79798, 'AbsTol', 0.0001);
      
      lastVal = cbd.last(cbd.difaPct(testCase.gdph, 4));
      testCase.verifyEqual(lastVal{1,1}, 4.24635, 'AbsTol', 0.0001);
    end
    
    function testDifvPct(testCase)
      lastVal = cbd.last(cbd.difvPct(testCase.gdph));
      testCase.verifyEqual(lastVal{1,1}, 1.41901, 'AbsTol', 0.0001);
      
      lastVal = cbd.last(cbd.difvPct(testCase.gdph, 4));
      testCase.verifyEqual(lastVal{1,1}, 1.04509, 'AbsTol', 0.0001);
    end
    
    % Year over Year
    function testYryr(testCase)
      lastVal = cbd.last(cbd.yryr(testCase.gdph));
      testCase.verifyEqual(lastVal{1,1}, 367.7, 'AbsTol', 0.1);
    end
    
    function testYryrPct(testCase)
      lastVal = cbd.last(cbd.yryrPct(testCase.gdph));
      testCase.verifyEqual(lastVal{1,1}, 4.24635, 'AbsTol', 0.0001);
    end
    
    function testYryrl(testCase)
      lastVal = cbd.last(cbd.yryrl(testCase.gdph));
      testCase.verifyEqual(lastVal{1,1}, 4.15867, 'AbsTol', 0.0001);
    end
    
    % Averages
    function testMovv(testCase)
      lastVal = cbd.last(cbd.movv(testCase.gdph,2));
      testCase.verifyEqual(lastVal{1,1}, 8963.8, 'AbsTol', 0.1);
      
      lastVal = cbd.last(cbd.movv(testCase.gdph,4));
      testCase.verifyEqual(lastVal{1,1}, 8861.0, 'AbsTol', 0.1);
    end
    
    function testMova(testCase)
      lastVal = cbd.last(cbd.mova(testCase.gdph,2));
      testCase.verifyEqual(lastVal{1,1}, 35855.0, 'AbsTol', 0.1);
      
      lastVal = cbd.last(cbd.mova(testCase.gdph,4));
      testCase.verifyEqual(lastVal{1,1}, 35444.0, 'AbsTol', 0.1);
    end
    
    function testMovt(testCase)
      lastVal = cbd.last(cbd.movt(testCase.gdph,2));
      testCase.verifyEqual(lastVal{1,1}, 17927.5, 'AbsTol', 0.1);
      
      lastVal = cbd.last(cbd.movt(testCase.gdph,4));
      testCase.verifyEqual(lastVal{1,1}, 35444.0, 'AbsTol', 0.1);
    end
    
    % Other
    function testStddm(testCase)
      havd = cbd.data('STDDM(GDPH)');
      compd = cbd.data('GDPH');
      comp = cbd.stddm(compd);
      testCase.verifyEqual(havd{:,:}, comp{:,:});
      
      testCase.verifyEqual(nanmean(havd{:,:}), 0, 'AbsTol', eps*10);
      testCase.verifyEqual(nanstd(havd{:,:}), 1, 'AbsTol', eps*10);
    end
    
    %         function testInterpNan(testCase)
    %
    %         end
    
    %% Transformation integration to data function
    % Lag
    function testDataLag(testCase)
      havd = cbd.data('LAG(GDPH)');
      compd = cbd.data('GDPH');
      comp = cbd.lag(compd);
      testCase.verifyEqual(havd{:,:}, comp{:,:});
      
      havd = cbd.data('LAG(GDPH, 3)');
      compd = cbd.data('GDPH');
      comp = cbd.lag(compd, 3);
      testCase.verifyEqual(havd{:,:}, comp{:,:});
    end
    
    % Differences
    function testDataDiff(testCase)
      havd = cbd.data('DIFF(GDPH)');
      compd = cbd.data('GDPH');
      comp = cbd.diff(compd);
      testCase.verifyEqual(havd{:,:}, comp{:,:});
      
      havd = cbd.data('DIFF(GDPH, 3)');
      compd = cbd.data('GDPH');
      comp = cbd.diff(compd, 3);
      testCase.verifyEqual(havd{:,:}, comp{:,:});
    end
    
    function testDataDifa(testCase)
      havd = cbd.data('DIFA(GDPH)');
      compd = cbd.data('GDPH');
      comp = cbd.difa(compd);
      testCase.verifyEqual(havd{:,:}, comp{:,:});
      
      havd = cbd.data('DIFA(GDPH, 3)');
      compd = cbd.data('GDPH');
      comp = cbd.difa(compd, 3);
      testCase.verifyEqual(havd{:,:}, comp{:,:});
    end
    
    function testDataDifv(testCase)
      havd = cbd.data('DIFV(GDPH)');
      compd = cbd.data('GDPH');
      comp = cbd.difv(compd);
      testCase.verifyEqual(havd{:,:}, comp{:,:});
      
      havd = cbd.data('DIFV(GDPH, 3)');
      compd = cbd.data('GDPH');
      comp = cbd.difv(compd, 3);
      testCase.verifyEqual(havd{:,:}, comp{:,:});
    end
    
    % Logs
    function testDataDiffl(testCase)
      havd = cbd.data('DIFFL(GDPH)');
      compd = cbd.data('GDPH');
      comp = cbd.diffl(compd);
      testCase.verifyEqual(havd{:,:}, comp{:,:});
      
      havd = cbd.data('DIFFL(GDPH, 3)');
      compd = cbd.data('GDPH');
      comp = cbd.diffl(compd, 3);
      testCase.verifyEqual(havd{:,:}, comp{:,:});
    end
    
    function testDataDifal(testCase)
      havd = cbd.data('DIFAL(GDPH)');
      compd = cbd.data('GDPH');
      comp = cbd.difal(compd);
      testCase.verifyEqual(havd{:,:}, comp{:,:});
      
      havd = cbd.data('DIFAL(GDPH, 3)');
      compd = cbd.data('GDPH');
      comp = cbd.difal(compd, 3);
      testCase.verifyEqual(havd{:,:}, comp{:,:});
    end
    
    function testDataDifvl(testCase)
      havd = cbd.data('DIFVL(GDPH)');
      compd = cbd.data('GDPH');
      comp = cbd.difvl(compd);
      testCase.verifyEqual(havd{:,:}, comp{:,:});
      
      havd = cbd.data('DIFVL(GDPH, 3)');
      compd = cbd.data('GDPH');
      comp = cbd.difvl(compd, 3);
      testCase.verifyEqual(havd{:,:}, comp{:,:});
    end
    
    % Percentages
    function testDataDiffPct(testCase)
      havd = cbd.data('DIFF%(GDPH)');
      compd = cbd.data('GDPH');
      comp = cbd.diffPct(compd);
      testCase.verifyEqual(havd{:,:}, comp{:,:});
      
      havd = cbd.data('DIFF%(GDPH, 3)');
      compd = cbd.data('GDPH');
      comp = cbd.diffPct(compd, 3);
      testCase.verifyEqual(havd{:,:}, comp{:,:});
    end
    
    function testDataDifaPct(testCase)
      havd = cbd.data('DIFA%(GDPH)');
      compd = cbd.data('GDPH');
      comp = cbd.difaPct(compd);
      testCase.verifyEqual(havd{:,:}, comp{:,:});
      
      havd = cbd.data('DIFA%(GDPH, 3)');
      compd = cbd.data('GDPH');
      comp = cbd.difaPct(compd, 3);
      testCase.verifyEqual(havd{:,:}, comp{:,:});
    end
    
    function testDataDifvPct(testCase)
      havd = cbd.data('DIFV%(GDPH)');
      compd = cbd.data('GDPH');
      comp = cbd.difvPct(compd);
      testCase.verifyEqual(havd{:,:}, comp{:,:});
      
      havd = cbd.data('DIFV%(GDPH, 3)');
      compd = cbd.data('GDPH');
      comp = cbd.difvPct(compd, 3);
      testCase.verifyEqual(havd{:,:}, comp{:,:});
    end
    
    % Year over Year
    function testDataYryr(testCase)
      havd = cbd.data('YRYR(GDPH)');
      compd = cbd.data('GDPH');
      comp = cbd.yryr(compd);
      testCase.verifyEqual(havd{:,:}, comp{:,:});
    end
    
    function testDataYryrPct(testCase)
      havd = cbd.data('YRYR%(GDPH)');
      compd = cbd.data('GDPH');
      comp = cbd.yryrPct(compd);
      testCase.verifyEqual(havd{:,:}, comp{:,:});
    end
    
    function testDataYryrl(testCase)
      havd = cbd.data('YRYRL(GDPH)');
      compd = cbd.data('GDPH');
      comp = cbd.yryrl(compd);
      testCase.verifyEqual(havd{:,:}, comp{:,:});
    end
    
    % Averages
    function testDataMovv(testCase)
      havd = cbd.data('MOVV(GDPH, 3)');
      compd = cbd.data('GDPH');
      comp = cbd.movv(compd, 3);
      testCase.verifyEqual(havd{:,:}, comp{:,:});
    end
    
    function testDataMova(testCase)
      havd = cbd.data('MOVA(GDPH, 3)');
      compd = cbd.data('GDPH');
      comp = cbd.mova(compd, 3);
      testCase.verifyEqual(havd{:,:}, comp{:,:});
    end
    
    function testDataMovt(testCase)
      havd = cbd.data('MOVT(GDPH, 3)');
      compd = cbd.data('GDPH');
      comp = cbd.movt(compd, 3);
      testCase.verifyEqual(havd{:,:}, comp{:,:});
    end
    
    % Other
    function testDataStddm(testCase)
      havd = cbd.data('STDDM(GDPH)');
      compd = cbd.data('GDPH');
      comp = cbd.stddm(compd);
      testCase.verifyEqual(havd{:,:}, comp{:,:});
    end
    
    %         function testDataInterpNan(testCase)
    %
    %         end
  end
end
