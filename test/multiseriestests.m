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

classdef multiseriestests < matlab.unittest.TestCase
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
        function testAddition(testCase)
            testVal = cbd.last(cbd.addition(testCase.gdpVal, testCase.gdpVal));
            testCase.verifyEqual(testVal{1,1}, 9026.9+9026.9, 'AbsTol', 0.1);
            
            testVal = cbd.data('LAST(ADDITION(GDPH0001@ASREPGDP, GDPH0001@ASREPGDP))');
            testCase.verifyEqual(testVal{1,1}, 9026.9+9026.9, 'AbsTol', 0.1);
        end
        
        function testAdditionScalar(testCase)
            testVal = cbd.last(cbd.addition(testCase.gdpVal, 1234));
            testCase.verifyEqual(testVal{1,1}, 9026.9+1234, 'AbsTol', 0.1);
            
            testVal = cbd.last(cbd.addition(12345, testCase.gdpVal));
            testCase.verifyEqual(testVal{1,1}, 12345+9026.9, 'AbsTol', 0.1);
            
            testVal = cbd.last(cbd.addition(12345, 1234));
            testCase.verifyEqual(testVal, 1234+12345, 'AbsTol', 0.1);
        end
        
        function testSubtraction(testCase)
            testVal = cbd.last(cbd.subtraction(testCase.gdpVal, testCase.gdpVal));
            testCase.verifyEqual(testVal{1,1}, 9026.9-9026.9, 'AbsTol', 0.1);
            
            testVal = cbd.data('LAST(SUBTRACTION(GDPH0001@ASREPGDP, GDPH0001@ASREPGDP))');
            testCase.verifyEqual(testVal{1,1}, 9026.9-9026.9, 'AbsTol', 0.1);
        end
        
        function testSubtractionScalar(testCase)
            testVal = cbd.last(cbd.subtraction(testCase.gdpVal, 1234));
            testCase.verifyEqual(testVal{1,1}, 9026.9-1234, 'AbsTol', 0.1);
            
            testVal = cbd.last(cbd.subtraction(12345, testCase.gdpVal));
            testCase.verifyEqual(testVal{1,1}, 12345-9026.9, 'AbsTol', 0.1);
            
            testVal = cbd.last(cbd.subtraction(12345, 1234));
            testCase.verifyEqual(testVal, 12345-1234, 'AbsTol', 0.1);
        end
        
        function testMultiplication(testCase)
            testVal = cbd.last(cbd.multiplication(testCase.gdpVal, testCase.gdpVal));
            testCase.verifyEqual(testVal{1,1}, 9026.9*9026.9, 'AbsTol', 0.1);
            
            testVal = cbd.data('LAST(MULTIPLICATION(GDPH0001@ASREPGDP, GDPH0001@ASREPGDP))');
            testCase.verifyEqual(testVal{1,1}, 9026.9*9026.9, 'AbsTol', 0.1);
        end
        
        function testMultiplicationScalar(testCase)
            testVal = cbd.last(cbd.multiplication(testCase.gdpVal, 2));
            testCase.verifyEqual(testVal{1,1}, 9026.9*2, 'AbsTol', 0.1);
            
            testVal = cbd.last(cbd.multiplication(3, testCase.gdpVal));
            testCase.verifyEqual(testVal{1,1}, 3*9026.9, 'AbsTol', 0.1);
            
            testVal = cbd.last(cbd.multiplication(3, 2));
            testCase.verifyEqual(testVal, 3*2, 'AbsTol', 0.1);
        end
        
        function testDivision(testCase)
            testVal = cbd.last(cbd.division(testCase.gdpVal, testCase.gdpVal));
            testCase.verifyEqual(testVal{1,1}, 9026.9/9026.9, 'AbsTol', 0.1);
            
            testVal = cbd.data('LAST(DIVISION(GDPH0001@ASREPGDP, GDPH0001@ASREPGDP))');
            testCase.verifyEqual(testVal{1,1}, 9026.9/9026.9, 'AbsTol', 0.1);
        end
        
        function testDivisionScalar(testCase)
            testVal = cbd.last(cbd.division(testCase.gdpVal, 2));
            testCase.verifyEqual(testVal{1,1}, 9026.9/2, 'AbsTol', 0.1);
            
            testVal = cbd.last(cbd.division(3, testCase.gdpVal));
            testCase.verifyEqual(testVal{1,1}, 3/9026.9, 'AbsTol', 0.1);
            
            testVal = cbd.last(cbd.division(3, 2));
            testCase.verifyEqual(testVal, 3/2, 'AbsTol', 0.1);
        end
    end
end
