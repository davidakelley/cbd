%% Test suite for the summarization functions in cbd.
% 
% Each test here works by comparing a computed result against a value 
% taken from the Haver DLXVG3. This is all done against data from the 
% ASREPGDP database because those data series will not be updated again. 
% Note that the integration with cbd.data is tested in each function here
% as well.
%
% See also: execTests.m

% David Kelley, 2015

classdef summarizationtests < matlab.unittest.TestCase
    properties
        gdph
    end
    
    methods(TestMethodSetup)
        function setupOnce(testCase)
            testCase.gdph = cbd.data('GDPH0001@ASREPGDP');
        end
    end
    
    methods (Test)
        %% Summarization functions
        function testLast(testCase)
            testVal = cbd.last(testCase.gdph);
            testCase.verifyEqual(testVal{1,1}, 9026.9, 'AbsTol', 0.1);
            
            testVal = cbd.data('LAST(GDPH0001@ASREPGDP)');
            testCase.verifyEqual(testVal{1,1}, 9026.9, 'AbsTol', 0.1);
            
            testVal = cbd.last(testCase.gdph, 4);
            testCase.verifyEqual(testVal{1,1}, 8737.9, 'AbsTol', 0.1);
            
            testVal = cbd.data('LAST(GDPH0001@ASREPGDP, 4)');
            testCase.verifyEqual(testVal{1,1}, 8737.9, 'AbsTol', 0.1);
        end
        
        function testMax(testCase)
            testVal = cbd.max(testCase.gdph);
            testCase.verifyEqual(testVal{1,1}, 9026.9, 'AbsTol', 0.1);
            
            testVal = cbd.max(cbd.data('GDPH1001@ASREPGDP'));
            testCase.verifyEqual(testVal{1,1}, 13415.3, 'AbsTol', 0.1);
            
            testVal = cbd.data('MAX(GDPH1001@ASREPGDP)');
            testCase.verifyEqual(testVal{1,1}, 13415.3, 'AbsTol', 0.1);
        end
        
        function testMin(testCase)
            testVal = cbd.min(testCase.gdph);
            testCase.verifyEqual(testVal{1,1}, 2254.4, 'AbsTol', 0.1);
            
            testVal = cbd.data('MIN(GDPH0001@ASREPGDP)');
            testCase.verifyEqual(testVal{1,1}, 2254.4, 'AbsTol', 0.1);
        end
        
        function testMean(testCase)
            testVal = cbd.mean(testCase.gdph);
            testCase.verifyEqual(testVal{1,1}, 4990.0, 'AbsTol', 0.1);
            
            testVal = cbd.data('MEAN(GDPH0001@ASREPGDP)');
            testCase.verifyEqual(testVal{1,1}, 4990.0, 'AbsTol', 0.1);
        end
        
        function testMedian(testCase)
            testVal = cbd.median(testCase.gdph);
            testCase.verifyEqual(testVal{1,1}, 4835.4, 'AbsTol', 0.1);
            
            testVal = cbd.data('MEDIAN(GDPH0001@ASREPGDP)');
            testCase.verifyEqual(testVal{1,1}, 4835.4, 'AbsTol', 0.1);
        end

    end
end
