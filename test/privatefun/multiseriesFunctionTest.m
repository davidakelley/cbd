classdef multiseriesFunctionTest < matlab.unittest.TestCase
    %MULTISERIESFUNCTIONTEST is the test suite for
    %cbd.private.multiseriesFunction
    %
    % Each test works by comparing a hand-computed value against a value
    % taken by pulling data from Haver and then performing some one of
    % the computations on it. The ASREPGDP database is used because those
    % series are no udpated in the future.
    %
    % David Kelley, 2015
    % Santiago I. Sordo-Palacios, 2019

    properties
        data table
        value double
        scalar1 = 1234;
        scalar2 = 12345;
        nanData table
    end
    
    methods (TestClassSetup)
        function createData(tc)
            %CREATEDATA gets the data that will be used for testing
            tc.data = cbd.expression('GDPH0001@ASREPGDP');
            tc.value = tc.data{end, 1};
        end % function
        
        function createNanData(tc)
            %CREATENANDATA gets a table of NaN's to test ignoreNan option
            tableSize = height(tc.data);
            nanArray = NaN(tableSize, 1);
            tc.nanData = array2table(nanArray, ...
                'VariableNames', {'NaN'}, ...
                'RowNames', tc.data.Properties.RowNames);
        end % function
    end % methods-TestClassSetup

    methods (Test)
        %% Addition tests
        function additionTwoTables(tc)
            actualVal = cbd.addition(tc.data, tc.data);
            expectedVal = tc.value + tc.value;
            tc.verifyEqual(actualVal{end, 1}, expectedVal, 'AbsTol', 0.1);
        end % function

        function additionTableScalar(tc)
            actualVal = cbd.addition(tc.data, tc.scalar1);
            expectedVal = tc.value + tc.scalar1;
            tc.verifyEqual(actualVal{end, 1}, expectedVal, 'AbsTol', 0.1);
        end % function

        function additionScalarTable(tc)
            actualVal = cbd.addition(tc.scalar2, tc.data);
            expectedVal = tc.scalar2 + tc.value;
            tc.verifyEqual(actualVal{end, 1}, expectedVal, 'AbsTol', 0.1);
        end % function

        function additionTwoScalars(tc)
            actualVal = cbd.addition(tc.scalar1, tc.scalar2);
            expectedVal = tc.scalar1 + tc.scalar2;
            tc.verifyEqual(actualVal, expectedVal, 'AbsTol', 0.1);
        end % function
        
        function additionIgnoreNanFalse(tc)
            actualVal = cbd.addition(tc.data, tc.nanData, 'ignoreNan', false);
            tc.verifyEqual(actualVal{1, :}, tc.nanData{1, :}, 'AbsTol', 0.1);
        end % function
        
        function additionIgnoreNanTrue(tc)
            actualVal = cbd.addition(tc.data, tc.nanData, 'ignoreNan', true);
            tc.verifyEqual(actualVal{1, :}, tc.data{1, :}, 'AbsTol', 0.1);
        end % function

        %% Subtraction tests
        function subtractionTwoTables(tc)
            actualVal = cbd.subtraction(tc.data, tc.data);
            expectedVal = tc.value - tc.value;
            tc.verifyEqual(actualVal{end, 1}, expectedVal, 'AbsTol', 0.1);
        end  % function

        function subtractionTableScalar(tc)
            actualVal = cbd.subtraction(tc.data, tc.scalar1);
            expectedVal = tc.value - tc.scalar1;
            tc.verifyEqual(actualVal{end, 1}, expectedVal, 'AbsTol', 0.1);
        end % function
        
        function subtractionScalarTable(tc)
            actualVal = cbd.subtraction(tc.scalar2, tc.data);
            expectedVal = tc.scalar2 - tc.value;
            tc.verifyEqual(actualVal{end, 1}, expectedVal, 'AbsTol', 0.1);
        end % function

        function subtractionScalars(tc)
            actualVal = cbd.subtraction(tc.scalar1, tc.scalar2);
            expectedVal = tc.scalar1 - tc.scalar2;
            tc.verifyEqual(actualVal, expectedVal, 'AbsTol', 0.1);
        end  % function
        
        function subtractionIgnoreNanFalse(tc)
            actualVal = cbd.subtraction(tc.data, tc.nanData, 'ignoreNan', false);
            tc.verifyEqual(actualVal{1, :}, tc.nanData{1, :}, 'AbsTol', 0.1);
        end % function
        
        function subtractionIgnoreNanTrue(tc)
            actualVal = cbd.subtraction(tc.data, tc.nanData, 'ignoreNan', true);
            tc.verifyEqual(actualVal{1, :}, tc.data{1, :}, 'AbsTol', 0.1);
        end % function

        %% Multiplication tests
        function multiplicationTwoTables(tc)
            actualVal = cbd.multiplication(tc.data, tc.data);
            expectedVal = tc.value * tc.value;
            tc.verifyEqual(actualVal{end, 1}, expectedVal, 'AbsTol', 0.1);
        end  % function

        function multiplicationTableScalar(tc)
            actualVal = cbd.multiplication(tc.data, tc.scalar1);
            expectedVal = tc.value * tc.scalar1;
            tc.verifyEqual(actualVal{end, 1}, expectedVal, 'AbsTol', 0.1);
        end % function
        
        function multiplicationScalarTable(tc)
            actualVal = cbd.multiplication(tc.scalar2, tc.data);
            expectedVal = tc.scalar2 * tc.value;
            tc.verifyEqual(actualVal{end, 1}, expectedVal, 'AbsTol', 0.1);
        end % function

        function multiplicationScalars(tc)
            actualVal = cbd.multiplication(tc.scalar1, tc.scalar2);
            expectedVal = tc.scalar1 * tc.scalar2;
            tc.verifyEqual(actualVal, expectedVal, 'AbsTol', 0.1);
        end % function
        
        function multiplicationIgnoreNanFalse(tc)
            actualVal = cbd.multiplication(tc.data, tc.nanData, 'ignoreNan', false);
            tc.verifyEqual(actualVal{1, :}, tc.nanData{1, :}, 'AbsTol', 0.1);
        end % function
        
        function multiplicationIgnoreNanTrue(tc)
            actualVal = cbd.multiplication(tc.data, tc.nanData, 'ignoreNan', true);
            tc.verifyEqual(actualVal{1, :}, tc.data{1, :}, 'AbsTol', 0.1);
        end % function

        %% Division tests
        function divisionTwoTables(tc)
            actualVal = cbd.division(tc.data, tc.data);
            expectedVal = tc.value / tc.value;
            tc.verifyEqual(actualVal{end, 1}, expectedVal, 'AbsTol', 0.1);
        end % function

        function divisionTableScalar(tc)
            actualVal = cbd.division(tc.data, tc.scalar1);
            expectedVal = tc.value / tc.scalar1;
            tc.verifyEqual(actualVal{end, 1}, expectedVal, 'AbsTol', 0.1);
        end % function
        
        function divisionScalarTable(tc)
            actualVal = cbd.division(tc.scalar2, tc.data);
            expectedVal = tc.scalar2 / tc.value;
            tc.verifyEqual(actualVal{end, 1}, expectedVal, 'AbsTol', 0.1);
        end % function

        function divisionScalars(tc)
            actualVal = cbd.division(tc.scalar1, tc.scalar2);
            expectedVal = tc.scalar1 / tc.scalar2;
            tc.verifyEqual(actualVal, expectedVal, 'AbsTol', 0.1);
        end % function
        
        function divisionIgnoreNanFalse(tc)
            actualVal = cbd.division(tc.data, tc.nanData, 'ignoreNan', false);
            tc.verifyEqual(actualVal{1, :}, tc.nanData{1, :}, 'AbsTol', 0.1);
        end % function
        
        function divisionIgnoreNanTrue(tc)
            actualVal = cbd.division(tc.data, tc.nanData, 'ignoreNan', true);
            tc.verifyEqual(actualVal{1, :}, tc.data{1, :}, 'AbsTol', 0.1);
        end % function

    end % methods-Test
    
end % classdef
