%% Test suite for the misc functions in cbd.
%
% Each test here works by comparing a computed result against a value
% taken from the Haver DLXVG3. This is all done against data from the
% ASREPGDP database because those data series will not be updated again.
% Note that the integration with cbd.data is tested in each function here
% as well.
%
% See also: execTests.m

% David Kelley, 2015

classdef misctests < matlab.unittest.TestCase
  properties
    gdph
    gdph2
    gdph3
    fedfunds
    set1
    set2
  end
  
  methods(TestMethodSetup)
    function setupOnce(testCase)
      testCase.gdph = cbd.data('GDPH0001@ASREPGDP');
      testCase.gdph2 = cbd.data('GDPH0002@ASREPGDP');
      testCase.gdph3 = cbd.data('GDPH0003@ASREPGDP');
      testCase.fedfunds = cbd.data({'FFEDTAL@DAILY', 'FFEDTAH@DAILY'});
      
      testCase.set1 = cbd.data({'GDPH0001@ASREPGDP', 'GDPH0001@ASREPGDP'});
      testCase.set2 = cbd.data({'GDPH0002@ASREPGDP', 'GDPH0002@ASREPGDP'});
    end
  end
  
  methods (Test)
    %% Merge function
    function testMerge2(testCase)
      testVal = cbd.merge(testCase.gdph, testCase.gdph2);
      testCase.verifyEqual(size(testVal, 2), 2);
    end
    
    function testMergeMulti(testCase)
      testVal = cbd.merge(testCase.gdph, testCase.gdph2, testCase.gdph3);
      testCase.verifyEqual(size(testVal, 2), 3);
    end
    
    function testMergeSameName(testCase)
      testVal = cbd.merge(testCase.gdph, testCase.gdph);
      testCase.verifyEqual(size(testVal, 2), 2);
    end
    
    function testMergeSameNameMulti(testCase)
      testVal = cbd.merge(testCase.gdph, testCase.gdph, testCase.gdph);
      testCase.verifyEqual(size(testVal, 2), 3);
    end
    
    function testMergeSameNameMultiSet(testCase)
      testVal = cbd.merge(testCase.set1, testCase.set2);
      testCase.verifyEqual(size(testVal, 2), 4);
    end
    
    function testMergeSameNameMultiSetSame(testCase)
      testVal = cbd.merge(testCase.set1, testCase.set1);
      testCase.verifyEqual(size(testVal, 2), 4);
    end
    
    %% Trim function
    function testTrimStart(testCase)
      testVal = cbd.trim(testCase.gdph, 'startDate', '1/1/1990');
      firstDate = datenum(testVal.Properties.RowNames{1});
      testCase.verifyEqual(datenum('3/31/1990'), firstDate);
    end
    
    function testTrimEnd(testCase)
      testVal = cbd.trim(testCase.gdph, 'endDate', '12/31/1990');
      lastDate = datenum(testVal.Properties.RowNames{end});
      testCase.verifyEqual(datenum('12/31/1990'), lastDate);
    end
    
    function testTrimBoth(testCase)
      testVal = cbd.trim(testCase.gdph, 'startDate', '1/1/1990', 'endDate', '12/31/1990');
      
      firstDate = datenum(testVal.Properties.RowNames{1});
      testCase.verifyEqual(datenum('3/31/1990'), firstDate);
      
      lastDate = datenum(testVal.Properties.RowNames{end});
      testCase.verifyEqual(datenum('12/31/1990'), lastDate);
    end
    
    function testTrimStartInc(testCase)
      testVal = cbd.trim(testCase.gdph, 'startDate', '1/1/1990', 'Inclusive', true);
      firstDate = datenum(testVal.Properties.RowNames{1});
      testCase.verifyEqual(datenum('12/31/1989'), firstDate);
      
      testVal = cbd.trim(testCase.fedfunds, 'startDate', '12/16/2015', 'Inclusive', true);
      firstDate = datenum(testVal.Properties.RowNames{1});
      testCase.verifyEqual(datenum('12/16/2015'), firstDate);
    end
    
    function testTrimEndInc(testCase)
      testVal = cbd.trim(testCase.gdph, 'endDate', '5/31/1990', 'Inclusive', true);
      lastDate = datenum(testVal.Properties.RowNames{end});
      testCase.verifyEqual(datenum('6/30/1990'), lastDate);
      
      testVal = cbd.trim(testCase.fedfunds, 'endDate', '12/16/2015', 'Inclusive', true);
      lastDate = datenum(testVal.Properties.RowNames{end});
      testCase.verifyEqual(datenum('12/16/2015'), lastDate);
    end
    
    function testTrimBothInc(testCase)
      testVal = cbd.trim(testCase.gdph, 'startDate', '1/1/1990', 'endDate', '5/31/1990', 'Inclusive', true);
      
      firstDate = datenum(testVal.Properties.RowNames{1});
      testCase.verifyEqual(datenum('12/31/1989'), firstDate);
      
      lastDate = datenum(testVal.Properties.RowNames{end});
      testCase.verifyEqual(datenum('6/30/1990'), lastDate);
    end
  end
end
