%% Test suite for cbd.data function
% 
% See also: execTests.m

% David Kelley, 2015

classdef expressiontest < matlab.unittest.TestCase
    methods (Test)
        %% Haver data
        function testSeries(testCase)
            % Pull one series
            dataset = cbd.expression('GDPH');
            testCase.verifyGreaterThan(size(dataset, 1), 100);
            testCase.verifyEqual(size(dataset,2), 1);
        end
        
        function testTwoSeries(testCase)
            % Pull two series
            dataset = cbd.expression({'GDPH', 'CH'});
            testCase.verifyEqual(size(dataset,2), 2);
        end
           
        function testDatabase(testCase)
            % Pull from database (explicitly)
            dataset = cbd.expression('GDPH@USECON');
            testCase.verifyGreaterThan(size(dataset, 1), 100);
            
            dataset = cbd.expression('FRBCNAIM', 'dbID', 'SURVEYS');
            testCase.verifyGreaterThan(size(dataset, 1), 100);
            
            dataset = cbd.expression('FRBCNAIM@SURVEYS');
            testCase.verifyGreaterThan(size(dataset, 1), 100);
            
            dataset = cbd.expression('GDPH0001@ASREPGDP');
            testCase.verifyEqual(size(dataset, 1), 164);
        end
        
        function testBadSeries(testCase)
            % Bad data series
            dataErr = @() cbd.expression('ASDFQWERTY');
            testCase.verifyError(dataErr, 'haverseries:noPull');
        end
        
        function testEmptySeries(testCase)
            dataset = cbd.expression('JX0001@ASREPGDP', 'startDate', '01/01/2000');
            testCase.verifyEmpty(dataset);
        end
        
        %% FRED data
        function testFredOneSeries(testCase)    
            % Pull one series
            dataset = cbd.expression('INDPRO@FRED');
            testCase.verifyGreaterThan(size(dataset, 1), 100);
            testCase.verifyEqual(size(dataset,2), 1);
        end
        
        function testFredMultiSeries(testCase)            
            % Pull multiple series
            dataset = cbd.expression({'INDPRO', 'UNRATE'}, 'dbID', 'FRED');
            testCase.verifyGreaterThan(size(dataset, 1), 100);
            testCase.verifyEqual(size(dataset, 2), 2);
        end
        
        function testHaverFred(testCase)
            % Both Haver and FRED data
            dataset = cbd.expression({'LR', 'UNRATE@FRED'});
            testCase.verifyEqual(dataset.LR, dataset.UNRATE);
        end
        
        function testFredBadSeries(testCase)
            % Bad data series
            dataErr = @() cbd.expression('ASDFQWERTY@FRED');
            testCase.verifyError(dataErr, 'fredseries:fredError');
        end
        
        function testDates(testCase)
            % Haver 
            dataset = cbd.expression('GDPH', 'startDate', '01/01/2000');
            dates = datenum(dataset.Properties.RowNames);
            testCase.verifyGreaterThan(dates(1), datenum('12/31/1999'));
            
            dataset = cbd.expression('GDPH', 'endDate', '12/31/1999');
            dates = datenum(dataset.Properties.RowNames);
            testCase.verifyLessThan(dates(end), datenum('01/01/2000'));
        end
        
        function testFredDates(testCase)
            dataset = cbd.expression('UNRATE@FRED', 'startDate', '01/01/2000');
            dates = datenum(dataset.Properties.RowNames);
            testCase.verifyGreaterThan(dates(1), datenum('12/31/1999'));
            
            dataset = cbd.expression('UNRATE@FRED', 'endDate', '12/31/1999');
            dates = datenum(dataset.Properties.RowNames);
            testCase.verifyLessThan(dates(end), datenum('01/01/2000'));
        end
           
        function testFredRealtime(testCase)
            testset = cbd.expression('UNRATE@FRED');
            
            dataset = cbd.expression('UNRATE@FRED', 'asOf', '12/31/1999');
            testCase.verifyNotEqual(size(dataset, 1), size(testset, 1));
            
            dataset = cbd.expression('UNRATE@FRED', 'asOfStart', '6/30/2014', 'asOfEnd', today());
            testCase.verifyGreaterThan(size(dataset, 2), 1);
            testCase.verifyEqual(dataset{:,end}, testset{:,end});
        end
            
        function testBadTransformation(testCase)
            dataErr = @() cbd.expression('notFn(GDPH)');
            testCase.verifyError(dataErr, 'expression_eval:function');
        end
        
        %% CHIDATA
        
        %% Statement parsing
        function testOperator(testCase)
            testset = cbd.expression('FRACW + FRBW');
            dataset = cbd.addition(cbd.data('FRACW'), cbd.data('FRBW'));
            testCase.verifyEqual(testset{end, 1}, dataset{end,1});
        end
        
        function testGrouping(testCase)
            testset = cbd.expression('(FRACW + FRBW) / 1000');
            dataset = cbd.division(cbd.addition(cbd.data('FRACW'), cbd.data('FRBW')), 1000);
            testCase.verifyEqual(testset{end, 1}, dataset{end,1});
        end
        
        function testOption(testCase)
            % Discontinued series come back as nan unless explicitly stated
            testset = cbd.expression('FRSBTAW + FRACW'); 
            testCase.verifyTrue(isnan(testset{end,1}));
            
            testset = cbd.expression('(FRSBTAW + FRACW)#ignoreNan');
            testCase.verifyFalse(isnan(testset{end,1}));
            
            % Should only apply to argument its attached to, not later 
            testset = cbd.expression('FRSBTAW + FRACW#ignoreNan'); 
            testCase.verifyTrue(isnan(testset{end,1}));
            
            % Both arguments should be taken into account
            testset = cbd.expression('FFED@DAILY#startDate:"12/31/2014"#endDate:"12/31/2014"');
            testCase.verifyEqual(size(testset), ones(1, 2));
            
            testset = cbd.expression('FFED@DAILY#startDate:"1/1/2015"#endDate:"1/1/2014"');
            testCase.verifyEmpty(testset);
        end        
        
        function testOperator1(testCase)
            testset = cbd.data('FRACW+FRBW');
            fracw = cbd.data('FRACW');
            dataset = cbd.expression('%d + FRBW', fracw);
            testCase.verifyEqual(testset{end,1}, dataset{end,1});
        end
        
        function testGrouping1(testCase)
            testset = cbd.data('(FRACW+FRBW)/1000');
            fracw = cbd.data('FRACW');
            dataset = cbd.expression('(%d + FRBW)/1000', fracw);
            testCase.verifyEqual(testset{end, 1}, dataset{end,1});
        end
        
        function testFunction(testCase)
            testset = cbd.data('DIFA%(GDPH)');
            gdph = cbd.data('GDPH');
            dataset = cbd.expression('DIFA%(%d)', gdph);
            testCase.verifyEqual(testset{end, 1}, dataset{end,1});
        end
        
        function testOperatorMulti(testCase)
            testset = cbd.data('FRACW+FRBW');
            fracw = cbd.data('FRACW');
            frbw = cbd.data('FRBW');
            dataset = cbd.expression('%d + %d', fracw, frbw);
            testCase.verifyEqual(testset{end,1}, dataset{end,1});
        end
        
        function testGroupingMulti(testCase)
            testset = cbd.data('(FRACW+FRBW)/1000');
            fracw = cbd.data('FRACW');
            frbw = cbd.data('FRBW');
            dataset = cbd.expression('(%d + %d)/1000', fracw, frbw);
            testCase.verifyEqual(testset{end, 1}, dataset{end,1});
        end
        
        function testFunctionMulti(testCase)
            testset = cbd.data('DIFF%(AGG(IP,"Q","AVG"))');
            ip = cbd.data('IP');
            ipDiffQ = cbd.expression('DIFF%(AGG(%d,"Q","AVG"))', ip);
            testCase.verifyEqual(testset{end, 1}, ipDiffQ{end,1});
        end
        
    end
end
