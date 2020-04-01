classdef summarizationTest < matlab.unittest.TestCase
    %SUMMARIZATIONTEST is the test suite for summarization functions
    %
    % Each test here works by comparing a computed result against a value
    % taken from the Haver DLXVG3. This is all done against data from the
    % ASREPGDP database because those data series will not be updated
    %
    % Functions tested:
    %   ~ cbd.last
    %   ~ cbd.max
    %   ~ cbd.min
    %   ~ cbd.mean
    %   ~ cbd.median
    %
    % David Kelley, 2015

    properties
        gdph
        prices
    end

    methods (TestMethodSetup)
        function setupOnce(tc)
            tc.gdph = cbd.expression('GDPH0001@ASREPGDP');
            tc.prices = cbd.expression( ...
                {'YRYR%(JCXF1401@ASREPGDP)', 'YRYR%(JC1001@ASREPGDP)'});
        end
    end

    methods (Test)
        
        function last(tc)
            testVal = cbd.last(tc.gdph);
            tc.verifyEqual(testVal{1, 1}, 9026.9, 'AbsTol', 0.1);

            testVal = cbd.last(tc.gdph, 4);
            tc.verifyEqual(testVal{1, 1}, 8737.9, 'AbsTol', 0.1);
        end

        function max(tc)
            testVal = cbd.max(tc.gdph);
            tc.verifyEqual(testVal{1, 1}, 9026.9, 'AbsTol', 0.1);
            tc.verifySize(testVal, [1, 1]);

            testVal = cbd.max(tc.prices);
            tc.verifyEqual(testVal{1, 2}, 11.52, 'AbsTol', 0.1);
            tc.verifySize(testVal, [1, 2]);
        end

        function min(tc)
            testVal = cbd.min(tc.gdph);
            tc.verifyEqual(testVal{1, 1}, 2254.4, 'AbsTol', 0.1);
            tc.verifySize(testVal, [1, 1]);

            testVal = cbd.min(tc.prices);
            tc.verifyEqual(testVal{1, 2}, -2.26, 'AbsTol', 0.1);
            tc.verifySize(testVal, [1, 2]);
        end

        function mean(tc)
            testVal = cbd.mean(tc.gdph);
            tc.verifyEqual(testVal{1, 1}, 4990.0, 'AbsTol', 0.1);
        end

        function median(tc)
            testVal = cbd.median(tc.gdph);
            tc.verifyEqual(testVal{1, 1}, 4835.4, 'AbsTol', 0.1);
        end

    end
end
