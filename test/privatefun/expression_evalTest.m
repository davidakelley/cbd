classdef expression_evalTest < matlab.unittest.TestCase
    %EXPRESSION_EVALTEST is the test suite for cbd.private.expression_eval
    %although it relies on its wrapper cbd.expression to execute it
    %
    % USAGE
    %   >> runtests('expression_evalTest')
    %
    % SEE ALSO: SOURCESERIES
    %
    % David Kelley, 2015
    % Santiago Sordo-Palacios, 2019
    
    properties
        % Haver properties
        idA = 'GDPH'
        dbA = 'USECON';
        seriesA char
        optsA = struct();
        dataA table
        propsA struct
        funA = @(x,y) cbd.source.haverseries(x,y)
        
        % FRED properties
        idB = 'GDP';
        dbB = 'FRED';
        seriesB char
        optsB = struct();
        dataB table
        propsB struct
        funB = @(x,y) cbd.source.fredseries(x,y)
        
        % opts properties
        startDate = '01-Jan-2000';
        endDate = '31-Dec-2000';
    end % properties
    
    methods (TestClassSetup)
        
        function baseOpts(tc)
            % options for data series A
            tc.seriesA = [tc.idA '@' tc.dbA];
            tc.optsA.dbID = tc.dbA;
            tc.optsA.startDate = [];
            tc.optsA.endDate = [];
            
            % options for data series B
            tc.seriesB = [tc.idB '@' tc.dbB];
            tc.optsB.dbID = tc.dbB;
            tc.optsB.startDate = [];
            tc.optsB.endDate = [];
            tc.optsB.asOf = [];
            tc.optsB.asOfStart = [];
            tc.optsB.asOfEnd = [];
        end % function
        
        function getData(tc)
            [tc.dataA, tc.propsA] = tc.funA(tc.idA, tc.optsA);
            [tc.dataB, tc.propsB] = tc.funB(tc.idB, tc.optsB);
        end % function
        
    end % methods
    
    methods (Test)       
        %% Test expression_eval input errors
        function specTooManyD(tc)
            expectedErr = 'expression_eval:spec';
            testStr = '%d%d';
            actualErr = @() cbd.expression(testStr, tc.dataA);
            tc.verifyError(actualErr, expectedErr);
        end % function
        
        function specTooFewD(tc)
            expectedErr = 'expression_eval:spec';
            testStr = '%d';
            actualErr = @() ...
                cbd.expression(testStr, tc.dataA, tc.dataB);
            tc.verifyError(actualErr, expectedErr);
        end % function
        
        function extraParenStart(tc)
            expectedErr = 'expression_eval:parens';
            testStr = ['(' tc.seriesA];
            actualErr = @() cbd.expression(testStr);
            tc.verifyError(actualErr, expectedErr);
        end % function
        
        function extraParenEnd(tc)
            expectedErr = 'expression_eval:parens';
            testStr = [tc.seriesA ')'];
            actualErr = @() cbd.expression(testStr);
            tc.verifyError(actualErr, expectedErr);
        end % function
        
        function badFunction(tc)
            expectedErr = 'expression_eval:missFunction';
            testStr = ['BADFUN(' tc.seriesA ')'];
            actualErr = @() cbd.expression(testStr);
            tc.verifyError(actualErr, expectedErr);
        end % function
        
        function mismatchedStringStart(tc)
            expectedErr = 'expression_eval:mismatchedString';
            testStr = ['"' tc.seriesA];
            actualErr = @() cbd.expression(testStr);
            tc.verifyError(actualErr, expectedErr);
        end % function
        
        function mismatchedStringEnd(tc)
            expectedErr = 'expression_eval:mismatchedString';
            testStr = [tc.seriesA '"'];
            actualErr = @() cbd.expression(testStr);
            tc.verifyError(actualErr, expectedErr);
        end % function
        
        function invalidInput(tc)
            % TODO: this brings up an interesting point with blank inputs
            expectedErr = 'expression_eval:invalidInput';
            testCell = {'@@', 'X@X@X'};
            for iStr = 1:length(testCell)
                actualErr = @() cbd.expression(testCell{iStr});
                tc.verifyError(actualErr, expectedErr);
            end % for-iStr
        end % function
        
        %% Test sourceseries errors
        % Note: these tests are equivalent to those in haverseries
        function nullSeries(tc)
            % Bad data series
            expectedErr = 'expression_eval:invalidInput';
            actualErr = @() cbd.expression(' ');
            tc.verifyError(actualErr, expectedErr);
        end
        
        function noPull(tc)
            % Bad data series
            expectedErr = 'haverseries:noPull';
            actualErr = @() cbd.expression('VALIDBUTBADSERIES');
            tc.verifyError(actualErr, expectedErr);
        end
        
        function invalidDB(tc)
            % Invalid database
            expectedErr = 'haverseries:invaliddbID';
            actualErr = @() cbd.expression('VALID@INVALIDDBID');
            tc.verifyError(actualErr, expectedErr);
        end % function
        
        %% Test basic usage of data calls
        function oneTable(tc)
            % Use one table and return it
            testStr = '%d';
            [data, props] = cbd.expression(testStr, tc.dataA);
            tc.verifyEqual(data, tc.dataA);
            tc.verifyEqual(props{1}.ID, '%d')
            tc.verifyEqual(props{1}.value, tc.propsA.value)
        end % function
        
        function oneHaver(tc)
            % Pull one series from Haver
            [data, props] = cbd.expression(tc.seriesA);
            tc.verifyEqual(data, tc.dataA);
            tc.verifyEqual(props{1}, tc.propsA)
        end % function
        
        function oneFRED(tc)
            % Pull one series from FRED
            [data, props] = cbd.expression(tc.seriesB);
            tc.verifyEqual(data, tc.dataB);
            tc.verifyEqual(props{1}, tc.propsB)
        end % function
        
        function multPulls(tc)
            % Pull two series and merge them
            expected = cbd.merge(tc.dataA, tc.dataB);
            [data, props] = cbd.expression({tc.seriesA, tc.seriesB});
            tc.verifyEqual(data, expected);
            tc.verifyEqual(props{1}, tc.propsA)
            tc.verifyEqual(props{2}, tc.propsB);
        end % function
        
        %% Test basic operations
        function addition(tc)
            expected = cbd.addition(tc.dataA, tc.dataB);
            testStr = [tc.seriesA '+' tc.seriesB];
            [data, props] = cbd.expression(testStr);
            
            tc.verifyEqual(data, expected);
            tc.verifyEqual(props{1}.func, str2func('cbd.addition'));
            tc.verifyEqual(props{1}.series{1}, tc.propsA);
            tc.verifyEqual(props{1}.series{2}, tc.propsB);
        end % function
        
        function subtraction(tc)
            expected = cbd.subtraction(tc.dataA, tc.dataB);
            testStr = [tc.seriesA '-' tc.seriesB];
            [data, props] = cbd.expression(testStr);
            
            tc.verifyEqual(data, expected);
            tc.verifyEqual(props{1}.func, str2func('cbd.subtraction'));
            tc.verifyEqual(props{1}.series{1}, tc.propsA);
            tc.verifyEqual(props{1}.series{2}, tc.propsB);
        end % function
        
        function multiplication(tc)
            expected = cbd.multiplication(tc.dataA, tc.dataB);
            testStr = [tc.seriesA '*' tc.seriesB];
            [data, props] = cbd.expression(testStr);
            
            tc.verifyEqual(data, expected);
            tc.verifyEqual(props{1}.func, str2func('cbd.multiplication'));
            tc.verifyEqual(props{1}.series{1}, tc.propsA);
            tc.verifyEqual(props{1}.series{2}, tc.propsB);
        end % function
        
        function scalar(tc)
            expected = cbd.multiplication(7, tc.dataA);
            testStr = ['7*' tc.seriesA];
            [data, props] = cbd.expression(testStr);
            
            tc.verifyEqual(data, expected);
            tc.verifyEqual(props{1}.func, str2func('cbd.multiplication'));
            tc.verifyEqual(props{1}.series{1}.ID, 'scalar');
            tc.verifyEqual(props{1}.series{1}.value, 7);
            tc.verifyEqual(props{1}.series{2}, tc.propsA);
        end % function
        
        function negative(tc)
            expected = cbd.multiplication(-1, tc.dataA);
            testStr = ['-' tc.seriesA];
            [data, props] = cbd.expression(testStr);
            
            tc.verifyEqual(data, expected);
            tc.verifyEqual(props{1}.func, str2func('cbd.multiplication'));
            tc.verifyEqual(props{1}.series{1}.ID, 'scalar');
            tc.verifyEqual(props{1}.series{1}.value, -1);
            tc.verifyEqual(props{1}.series{2}, tc.propsA);
        end % function
        
        function division(tc)
            expected = cbd.division(tc.dataA, tc.dataB);
            testStr = [tc.seriesA '/' tc.seriesB];
            [data, props] = cbd.expression(testStr);
            
            tc.verifyEqual(data, expected);
            tc.verifyEqual(props{1}.func, str2func('cbd.division'));
            tc.verifyEqual(props{1}.series{1}, tc.propsA);
            tc.verifyEqual(props{1}.series{2}, tc.propsB);
        end % function
        
        function parens(tc)
            expected = tc.dataA;
            testStr = ['(' tc.seriesA ')'];
            [data, props] = cbd.expression(testStr);
            
            tc.verifyEqual(data, expected);
            tc.verifyEqual(props{1}.func, 'parentheses');
            tc.verifyEqual(props{1}.series{1}, tc.propsA);
        end % function
        
        %% Test order of operations
        function operationsA(tc)
            expected = 4;
            testStr = 'C05 - C01';
            [data, props] = cbd.expression(testStr);
            
            tc.verifyEqual(data{end, 1}, expected);
            tc.verifyEqual(props{1}.func, str2func('cbd.subtraction'));
        end % function
        
        function operationsB(tc)
            expected = 1;
            testStr = 'C10 / C05 - C01';
            [data, props] = cbd.expression(testStr);
            
            tc.verifyEqual(data{end, 1}, expected);
            tc.verifyEqual(props{1}.func, str2func('cbd.subtraction'));
            tc.verifyEqual(props{1}.series{1}.func, str2func('cbd.division')); 
        end % function
        
        function operationsC(tc)
            expected = 3;
            testStr = 'C02 + C10 / C05 - C01';
            [data, props] = cbd.expression(testStr);
            
            tc.verifyEqual(data{end, 1}, expected);
            tc.verifyEqual(props{1}.func, str2func('cbd.addition'));
            tc.verifyEqual(props{1}.series{2}.func, str2func('cbd.subtraction'));
            tc.verifyEqual(props{1}.series{2}.series{1}.func, str2func('cbd.division'));
        end % function
        
        function operationsD(tc)
            expected = 4.5;
            testStr = 'C02 + C10 / (C05 - C01)';
            [data, props] = cbd.expression(testStr);
            
            tc.verifyEqual(data{end, 1}, expected);
            tc.verifyEqual(props{1}.func, str2func('cbd.addition'));
            tc.verifyEqual(props{1}.series{2}.func, str2func('cbd.division'));
            tc.verifyEqual(props{1}.series{2}.series{2}.func, 'parentheses');
            tc.verifyEqual(props{1}.series{2}.series{2}.series{1}.func, str2func('cbd.subtraction'));
        end % function
        
        function operationsE(tc)
            expected = 3;
            testStr = '(C02 + C10) / (C05 - C01)';
            [data, props] = cbd.expression(testStr);
            
            tc.verifyEqual(data{end, 1}, expected);
            tc.verifyEqual(props{1}.func, str2func('cbd.division'));
            tc.verifyEqual(props{1}.series{1}.func, 'parentheses');
            tc.verifyEqual(props{1}.series{1}.series{1}.func, str2func('cbd.addition'));
            tc.verifyEqual(props{1}.series{2}.func, 'parentheses');
            tc.verifyEqual(props{1}.series{2}.series{1}.func, str2func('cbd.subtraction'));
        end % function
        
        %% Test order with varied inputs
        function orderTables(tc)
            expected = cbd.division( ...
                cbd.addition(tc.dataA, tc.dataB), 1000);
            testStr = '(%d+%d)/1000';
            [data, props] = cbd.expression(testStr, tc.dataA, tc.dataB);
            
            tc.verifyEqual(data, expected);
            tc.verifyEqual(props{1}.func, str2func('cbd.division'));
            tc.verifyEqual(props{1}.series{1}.func, 'parentheses');
            tc.verifyEqual(props{1}.series{1}.series{1}.func, str2func('cbd.addition'));
            tc.verifyEqual(props{1}.series{1}.series{1}.series{1}.ID, '%d');
            tc.verifyEqual(props{1}.series{1}.series{1}.series{2}.ID, '%d');
            tc.verifyEqual(props{1}.series{2}.ID, 'scalar');
            tc.verifyEqual(props{1}.series{2}.value, 1000);
        end % function
        
        function orderPulls(tc)
            expected = cbd.division( ...
                cbd.addition(tc.dataA, tc.dataB), 1000);
            testStr = ['(' tc.seriesA '+' tc.seriesB ')/1000'];
            [data, props] = cbd.expression(testStr);
            
            tc.verifyEqual(data, expected);
            tc.verifyEqual(props{1}.func, str2func('cbd.division'));
            tc.verifyEqual(props{1}.series{1}.func, 'parentheses');
            tc.verifyEqual(props{1}.series{1}.series{1}.func, str2func('cbd.addition'));
            tc.verifyEqual(props{1}.series{1}.series{1}.series{1}, tc.propsA);
            tc.verifyEqual(props{1}.series{1}.series{1}.series{2}, tc.propsB);
            tc.verifyEqual(props{1}.series{2}.ID, 'scalar');
            tc.verifyEqual(props{1}.series{2}.value, 1000);
        end % function
        
        function orderMixed(tc)
            expected = cbd.division( ...
                cbd.addition(tc.dataA, tc.dataB), 1000);
            testStr = ['(%d+' tc.seriesB ')/1000'];
            [data, props] = cbd.expression(testStr, tc.dataA);
            
            tc.verifyEqual(data, expected);
            tc.verifyEqual(props{1}.func, str2func('cbd.division'));
            tc.verifyEqual(props{1}.series{1}.func, 'parentheses');
            tc.verifyEqual(props{1}.series{1}.series{1}.func, str2func('cbd.addition'));
            tc.verifyEqual(props{1}.series{1}.series{1}.series{1}.ID, '%d');
            tc.verifyEqual(props{1}.series{1}.series{1}.series{2}, tc.propsB);
            tc.verifyEqual(props{1}.series{2}.ID, 'scalar');
            tc.verifyEqual(props{1}.series{2}.value, 1000);
        end % function
        
        %% Test function calls with varying case sensitivity
        function changePct(tc)
            expected = cbd.changePct(tc.dataA);
            testStr = ['changePct(' tc.seriesA ')'];
            [data, props] = cbd.expression(testStr);
            tc.verifyEqual(data, expected);
            tc.verifyEqual(props{1}.func, str2func('cbd.changePct'));
        end % function
        
        function changeSign(tc)
            expected = cbd.changePct(tc.dataA);
            testStr = ['change%(' tc.seriesA ')'];
            [data, props] = cbd.expression(testStr);
            tc.verifyEqual(data, expected);
            tc.verifyEqual(props{1}.func, str2func('cbd.changePct'));
        end % function
        
        function changepct(tc)
            expected = cbd.changePct(tc.dataA);
            testStr = ['changepct(' tc.seriesA ')'];
            [data, props] = cbd.expression(testStr);
            tc.verifyEqual(data, expected);
            tc.verifyEqual(props{1}.func, str2func('cbd.changePct'));
        end % function
        
        function CHANGEPCT(tc)
            expected = cbd.changePct(tc.dataA);
            testStr = ['CHANGEPCT(' tc.seriesA ')'];
            [data, props] = cbd.expression(testStr);
            tc.verifyEqual(data, expected);
            tc.verifyEqual(props{1}.func, str2func('cbd.changePct'));
        end % function
        
        %% Test function calls with input arguments
        function movv(tc)
            expected = cbd.movv(tc.dataA, 5);
            testStr = ['MOVV(' tc.seriesA ', 5)'];
            [data, props] = cbd.expression(testStr);
            tc.verifyEqual(data, expected);
            tc.verifyEqual(props{1}.func, str2func('cbd.movv'));
            tc.verifyEqual(props{1}.series{2}.value, 5);
        end % function
        
        function movvIncludeNan(tc)
            expected = cbd.movv(tc.dataA, 5, 'includenan');
            testStr = ['MOVV(' tc.seriesA ', 5, "includenan")'];
            [data, props] = cbd.expression(testStr);
            tc.verifyEqual(data, expected);
            tc.verifyEqual(props{1}.func, str2func('cbd.movv'));
            tc.verifyEqual(props{1}.series{2}.value, 5);
            tc.verifyEqual(props{1}.series{3}.value, 'includenan');
        end % function
        
        function movvOmitNan(tc)
            expected = cbd.movv(tc.dataA, 5, 'omitnan');
            testStr = ['MOVV(' tc.seriesA ', 5, "omitnan")'];
            [data, props] = cbd.expression(testStr);
            tc.verifyEqual(data, expected);
            tc.verifyEqual(props{1}.func, str2func('cbd.movv'));
            tc.verifyEqual(props{1}.series{2}.value, 5);
            tc.verifyEqual(props{1}.series{3}.value, 'omitnan');
        end % function
        
        %% Specified dbID
        function vararginDB(tc)
            % Pull multiple series
            expected = tc.dataB;
            actual = cbd.expression(tc.idB, 'dbID', 'FRED');
            tc.verifyEqual(actual, expected);
        end % function
        
        function hashDB(tc)
            expected = tc.dataB;
            testStr = [tc.idB '#dbID:"' tc.dbB '"'];
            actual = cbd.expression(testStr);
            tc.verifyEqual(actual, expected);
        end % function
        
        %% Specified dates
        function vararginStartDate(tc)
            tc.optsA.startDate = tc.startDate;
            expected = tc.funA(tc.idA, tc.optsA);
            actual = cbd.expression(tc.seriesA, 'startDate', tc.startDate);
            tc.verifyEqual(actual, expected);
        end % function
        
        function hashStartDate(tc)
            tc.optsA.startDate = tc.startDate;
            expected = tc.funA(tc.idA, tc.optsA);
            testStr = [tc.seriesA '#startDate:"' tc.startDate '"'];
            actual = cbd.expression(testStr);
            tc.verifyEqual(actual, expected);
        end % function
        
        function vararginEndDate(tc)
            tc.optsA.endDate = tc.endDate;
            expected = tc.funA(tc.idA, tc.optsA);
            actual = cbd.expression(tc.seriesA, 'endDate', tc.endDate);
            tc.verifyEqual(actual, expected);
        end % function
        
        function hashEndDate(tc)
            tc.optsA.endDate = tc.endDate;
            expected = tc.funA(tc.idA, tc.optsA);
            testStr = [tc.seriesA '#endDate:"' tc.endDate '"'];
            actual = cbd.expression(testStr);
            tc.verifyEqual(actual, expected);
        end % function
        
        function vararginBothDates(tc)
            tc.optsA.startDate = tc.startDate;
            tc.optsA.endDate = tc.endDate;
            expected = tc.funA(tc.idA, tc.optsA);
            actual = cbd.expression(tc.seriesA, ...
                'startDate', tc.startDate, ...
                'endDate', tc.endDate);
            tc.verifyEqual(actual, expected);
        end % function
        
        function hashBothDates(tc)
            tc.optsA.startDate = tc.startDate;
            tc.optsA.endDate = tc.endDate;
            expected = tc.funA(tc.idA, tc.optsA);
            testStr = [tc.seriesA ...
                '#startDate:"' tc.startDate '"' ...
                '#endDate:"' tc.endDate '"'];
            actual = cbd.expression(testStr);
            tc.verifyEqual(actual, expected);
        end % function
        
        %% Special edge case tests in legacy format
        % Discontinued series come back as nan unless explicitly stated
        function noOption(tc)
            testset = cbd.expression('FRSBTAW + FRACW');
            tc.verifyTrue(isnan(testset{end,1}));
        end % function
        
        function groupedOption(tc)
            testset = cbd.expression('(FRSBTAW + FRACW)#ignoreNan');
            tc.verifyFalse(isnan(testset{end,1}));
        end % function
       
        function singleOption(tc)
            % Should only apply to argument its attached to, not later
            testset = cbd.expression('FRSBTAW + FRACW#ignoreNan');
            tc.verifyTrue(isnan(testset{end,1}));
        end % function
        
        function functionMult(tc)
            testset = cbd.expression('DIFF%(AGG(IP,"Q","AVG"))');
            ip = cbd.expression('IP');
            ipDiffQ = cbd.expression('DIFF%(AGG(%d,"Q","AVG"))', ip);
            tc.verifyEqual(testset{end, 1}, ipDiffQ{end,1});
        end % function
        
        function expressionMult(tc)
            % Test that multiple additions are worked out
            t1 = cbd.expression('C1');
            testset = cbd.expression('%d + %d + %d', t1, t1, t1);
            tc.verifyEqual(testset{end, 1}, 3);
        end % function
        
        function argFuncMult(tc)
            % Make sure we can handle expressions where there's multiple
            % arguments passed to one function.
            fisherTogether = cbd.expression( ...
                'FISHERPRICE(JFNS, FNS, JFR, FR)');
            dataSeparate = cellfun(@(x) cbd.expression(x), ...
                {'JFNS', 'FNS', 'JFR', 'FR'}, 'Uniform', false);
            fisherSeparate = cbd.expression( ...
                'FISHERPRICE(%d, %d, %d, %d)', dataSeparate{:});
            tc.verifyEqual(fisherTogether, fisherSeparate);
        end % function
        
        function ArgFuncMultMixed(tc)
            % Make sure we can handle expressions where there's mixed
            % tables and data pulls in one function.
            fisherTogether = cbd.expression( ...
                'FISHERPRICE(JFNS, FNS, JFR, FR)');
            dataSeparate = cellfun(@(x) cbd.expression(x), ...
                {'JFNS', 'JFR'}, 'Uniform', false);
            fisherSeparate = cbd.expression( ...
                'FISHERPRICE(%d, FNS, %d, FR)', dataSeparate{:});
            tc.verifyEqual(fisherTogether, fisherSeparate);
        end % function
        
    end % methods
end % classdef
