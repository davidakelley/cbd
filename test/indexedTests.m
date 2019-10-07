%% Test suite for the index methods in cbd
%

% Vamsi Kurakula, 2019

classdef indexedTests < matlab.unittest.TestCase
    
    properties
      idxDate 
      testSeries
      testData
    end
    
  methods(TestMethodSetup)
    function setupAll(testCase)
            testCase.idxDate = '02-Sep-2019';
            testCase.testSeries = 'SPSPF@DAILY';
            testCase.testData = cbd.data(testCase.testSeries, 'startDate', '1/1/2017');
    end   
  end
    
  methods (Test)

    function FindIdxDateBackward(testCase) 
      indexedData = cbd.indexed(testCase.testData, testCase.idxDate, -1);
      
      testCase.verifyEqual(indexedData{'30-Aug-2019',1}, 100);
    end 
    
    function FindIdxDateForward(testCase)           
      indexedData = cbd.indexed(testCase.testData, testCase.idxDate, 1);
      
      testCase.verifyEqual(indexedData{'03-Sep-2019',1}, 100);
    end 
    
    function assertTable(testCase)
        f = @() cbd.indexed(struct());
        testCase.assertError(f, 'indexed:inputNotTable')
    end  
    
    function assertDirFlag(testCase)
        f = @() cbd.indexed(testCase.testData, testCase.idxDate, 4);
        testCase.assertError(f, 'index:invalidDirFlag')
    end 
    
    function assertBackDate(testCase)
        f = @() cbd.indexed(testCase.testData, '12/31/1900', -1);
        testCase.assertError(f,'indexed:noBackDate')
    end
    
    function assertForwardDate(testCase)
        f = @() cbd.indexed(testCase.testData, '12/31/4000', 1);
        testCase.assertError(f, 'indexed:noForwardDate')
    end
    
    function assertIndexDate(testCase)
        f = @() cbd.indexed(testCase.testData, '9/15/2019');
        testCase.assertError(f, 'indexed:noDate')
    end
    
    function assertIdx100(testCase)
         randNrow = randi([1 size(testCase.testData,1)]);
         randDate = testCase.testData.Row{randNrow};
         
         idxData = cbd.indexed(testCase.testData, randDate);
         testCase.verifyEqual(idxData{randDate,1}, 100);
        
    end
        
        
        
  end
end
