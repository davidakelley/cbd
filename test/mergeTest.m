classdef mergeTest < matlab.unittest.TestCase
    %MERGETEST is the test sutie for cbd.merge
    %
    % David Kelley, 2014
    
    properties
        gdph
        gdph2
        gdph3
        fedfunds
        set1
        set2
    end
    
    methods(TestClassSetup)
        function setupOnce(tc)
            tc.gdph = cbd.data('GDPH0001@ASREPGDP');
            tc.gdph2 = cbd.data('GDPH0002@ASREPGDP');
            tc.gdph3 = cbd.data('GDPH0003@ASREPGDP');
            tc.fedfunds = cbd.data({'FFEDTAL@DAILY', 'FFEDTAH@DAILY'});
            tc.set1 = cbd.data({'GDPH0001@ASREPGDP', 'GDPH0001@ASREPGDP'});
            tc.set2 = cbd.data({'GDPH0002@ASREPGDP', 'GDPH0002@ASREPGDP'});
        end
    end
    
    methods (Test)
        %% Merge function
        function merge2(tc)
            testVal = cbd.merge(tc.gdph, tc.gdph2);
            tc.verifyEqual(size(testVal, 2), 2);
        end
        
        function mergeMulti(tc)
            testVal = cbd.merge(tc.gdph, tc.gdph2, tc.gdph3);
            tc.verifyEqual(size(testVal, 2), 3);
        end
        
        function mergeSameName(tc)
            testVal = cbd.merge(tc.gdph, tc.gdph);
            tc.verifyEqual(size(testVal, 2), 2);
        end
        
        function mergeSameNameMulti(tc)
            testVal = cbd.merge(tc.gdph, tc.gdph, tc.gdph);
            tc.verifyEqual(size(testVal, 2), 3);
        end
        
        function mergeSameNameMultiSet(tc)
            testVal = cbd.merge(tc.set1, tc.set2);
            tc.verifyEqual(size(testVal, 2), 4);
        end
        
        function mergeSameNameMultiSetSame(tc)
            testVal = cbd.merge(tc.set1, tc.set1);
            tc.verifyEqual(size(testVal, 2), 4);
        end
    end
    
end % classdef