classdef transformationTest < matlab.unittest.TestCase
    %TRANSFORMATIONTEST is the test suite for transformation functions
    %
    % Each test here works by comparing a computed result against a value
    % taken from the Haver DLXVG3. This is all done against data from the
    % ASREPGDP database because those data series will not be updated
    %
    % Functions tested:
    %   ~ cbd.lag
    %   ~ cbd.diff
    %   ~ cbd.difa
    %   ~ cbd.difa
    %   ~ cbd.difv
    %   ~ cbd.diffl
    %   ~ cbd.difal
    %   ~ cbd.difvl
    %   ~ cbd.diffPct
    %   ~ cbd.difaPct
    %   ~ cbd.difvPct
    %   ~ cbd.yryr
    %   ~ cbd.yryrPct
    %   ~ cbd.yryrl
    %   ~ cbd.movv
    %   ~ cbd.mova
    %   ~ cbd.movt
    %   ~ cbd.stddm
    %
    % David Kelley, 2015

    properties
        gdph
    end

    methods (TestClassSetup)
        function setupOnce(testCase)
            testCase.gdph = cbd.expression('GDPH0001@ASREPGDP');
        end
    end

    methods (Test)
        %% Lag
        function lag(testCase)
            testD = (1:10)';
            lagTestD = [nan, 1:9]';
            testCase.verifyEqual(cbd.lag(testD), lagTestD);

            testD = (1:10)';
            lagTestD = [nan, nan, 1:8]';
            testCase.verifyEqual(cbd.lag(testD, 2), lagTestD);

            testD = (1:10)';
            lagTestD = [2:10, nan]';
            testCase.verifyEqual(cbd.lag(testD, -1), lagTestD);
        end

        %% Differences
        function diff(testCase)
            lastVal = cbd.last(cbd.diff(testCase.gdph));
            testCase.verifyEqual(lastVal{1, 1}, 126.3, 'AbsTol', 0.1);

            lastVal = cbd.last(cbd.diff(testCase.gdph, 4));
            testCase.verifyEqual(lastVal{1, 1}, 367.7, 'AbsTol', 0.1);
        end

        function difa(testCase)
            lastVal = cbd.last(cbd.difa(testCase.gdph));
            testCase.verifyEqual(lastVal{1, 1}, 505.2, 'AbsTol', 0.1);

            lastVal = cbd.last(cbd.difa(testCase.gdph, 4));
            testCase.verifyEqual(lastVal{1, 1}, 367.7, 'AbsTol', 0.1);
        end

        function difv(testCase)
            lastVal = cbd.last(cbd.difv(testCase.gdph));
            testCase.verifyEqual(lastVal{1, 1}, 126.3, 'AbsTol', 0.1);

            lastVal = cbd.last(cbd.difv(testCase.gdph, 4));
            testCase.verifyEqual(lastVal{1, 1}, 91.9, 'AbsTol', 0.1);
        end

        %% Logs
        function diffl(testCase)
            lastVal = cbd.last(cbd.diffl(testCase.gdph));
            testCase.verifyEqual(lastVal{1, 1}, 1.40903, 'AbsTol', 0.0001);

            lastVal = cbd.last(cbd.diffl(testCase.gdph, 4));
            testCase.verifyEqual(lastVal{1, 1}, 4.15867, 'AbsTol', 0.0001);
        end

        function difal(testCase)
            lastVal = cbd.last(cbd.difal(testCase.gdph));
            testCase.verifyEqual(lastVal{1, 1}, 5.63613, 'AbsTol', 0.0001);

            lastVal = cbd.last(cbd.difal(testCase.gdph, 4));
            testCase.verifyEqual(lastVal{1, 1}, 4.15867, 'AbsTol', 0.0001);
        end

        function difvl(testCase)
            lastVal = cbd.last(cbd.difvl(testCase.gdph));
            testCase.verifyEqual(lastVal{1, 1}, 1.40903, 'AbsTol', 0.0001);

            lastVal = cbd.last(cbd.difvl(testCase.gdph, 4));
            testCase.verifyEqual(lastVal{1, 1}, 1.03967, 'AbsTol', 0.0001);
        end

        %% Percentages
        function diffPct(testCase)
            lastVal = cbd.last(cbd.diffPct(testCase.gdph));
            testCase.verifyEqual(lastVal{1, 1}, 1.41901, 'AbsTol', 0.0001);

            lastVal = cbd.last(cbd.diffPct(testCase.gdph, 4));
            testCase.verifyEqual(lastVal{1, 1}, 4.24635, 'AbsTol', 0.0001);
        end

        function difaPct(testCase)
            lastVal = cbd.last(cbd.difaPct(testCase.gdph));
            testCase.verifyEqual(lastVal{1, 1}, 5.79798, 'AbsTol', 0.0001);

            lastVal = cbd.last(cbd.difaPct(testCase.gdph, 4));
            testCase.verifyEqual(lastVal{1, 1}, 4.24635, 'AbsTol', 0.0001);
        end

        function difvPct(testCase)
            lastVal = cbd.last(cbd.difvPct(testCase.gdph));
            testCase.verifyEqual(lastVal{1, 1}, 1.41901, 'AbsTol', 0.0001);

            lastVal = cbd.last(cbd.difvPct(testCase.gdph, 4));
            testCase.verifyEqual(lastVal{1, 1}, 1.04509, 'AbsTol', 0.0001);
        end

        %% Year over Year
        function yryr(testCase)
            lastVal = cbd.last(cbd.yryr(testCase.gdph));
            testCase.verifyEqual(lastVal{1, 1}, 367.7, 'AbsTol', 0.1);
        end

        function yryrPct(testCase)
            lastVal = cbd.last(cbd.yryrPct(testCase.gdph));
            testCase.verifyEqual(lastVal{1, 1}, 4.24635, 'AbsTol', 0.0001);
        end

        function yryrl(testCase)
            lastVal = cbd.last(cbd.yryrl(testCase.gdph));
            testCase.verifyEqual(lastVal{1, 1}, 4.15867, 'AbsTol', 0.0001);
        end

        %% Averages
        function movv(testCase)
            % TODO: MIGRATE TO movvTest
            lastVal = cbd.last(cbd.movv(testCase.gdph, 2));
            testCase.verifyEqual(lastVal{1, 1}, 8963.8, 'AbsTol', 0.1);

            lastVal = cbd.last(cbd.movv(testCase.gdph, 4));
            testCase.verifyEqual(lastVal{1, 1}, 8861.0, 'AbsTol', 0.1);
        end

        function mova(testCase)
            lastVal = cbd.last(cbd.mova(testCase.gdph, 2));
            testCase.verifyEqual(lastVal{1, 1}, 35855.0, 'AbsTol', 0.1);

            lastVal = cbd.last(cbd.mova(testCase.gdph, 4));
            testCase.verifyEqual(lastVal{1, 1}, 35444.0, 'AbsTol', 0.1);
        end

        function movt(testCase)
            lastVal = cbd.last(cbd.movt(testCase.gdph, 2));
            testCase.verifyEqual(lastVal{1, 1}, 17927.5, 'AbsTol', 0.1);

            lastVal = cbd.last(cbd.movt(testCase.gdph, 4));
            testCase.verifyEqual(lastVal{1, 1}, 35444.0, 'AbsTol', 0.1);
        end

        %% Other
        function stddm(testCase)
            havd = cbd.expression('STDDM(GDPH)');
            compd = cbd.expression('GDPH');
            comp = cbd.stddm(compd);
            testCase.verifyEqual(havd{:, :}, comp{:, :});

            testCase.verifyEqual(nanmean(havd{:, :}), 0, 'AbsTol', eps*10);
            testCase.verifyEqual(nanstd(havd{:, :}), 1, 'AbsTol', eps*10);
        end
    end
end
