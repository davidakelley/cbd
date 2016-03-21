%% Test suite for cbd.data function
%
% See also: execTests.m

% David Kelley, 2015

classdef datatest < matlab.unittest.TestCase
  methods (Test)
    %% Haver data
    function testHaverseries(testCase)
      dataseries = cbd.private.haverseries('C02');
      testCase.verifyGreaterThan(size(dataseries, 1), 100);
      testCase.verifyEqual(size(dataseries, 2), 1);
      testCase.verifyTrue(all(dataseries.C02==2));
    end
    
    function testSeries(testCase)
      % Pull one series
      dataset = cbd.data('GDPH');
      testCase.verifyGreaterThan(size(dataset, 1), 100);
      testCase.verifyEqual(size(dataset,2), 1);
    end
    
    function testTwoSeries(testCase)
      % Pull two series
      dataset = cbd.data({'GDPH', 'CH'});
      testCase.verifyEqual(size(dataset,2), 2);
    end
    
    function testDatabase(testCase)
      % Pull from database (explicitly)
      dataset = cbd.data('GDPH@USECON');
      testCase.verifyGreaterThan(size(dataset, 1), 100);
      
      dataset = cbd.data('FRBCNAIM', 'dbID', 'SURVEYS');
      testCase.verifyGreaterThan(size(dataset, 1), 100);
      
      dataset = cbd.data('FRBCNAIM@SURVEYS');
      testCase.verifyGreaterThan(size(dataset, 1), 100);
      
      dataset = cbd.data('GDPH0001@ASREPGDP');
      testCase.verifyEqual(size(dataset, 1), 164);
    end
    
    function testBadSeries(testCase)
      % Bad data series
      dataErr = @() cbd.data('ASDFQWERTY');
      testCase.verifyError(dataErr, 'haverseries:noPull');
    end
    
    function testEmptySeries(testCase)
      dataset = cbd.data('JX0001@ASREPGDP', 'startDate', '01/01/2000');
      testCase.verifyEmpty(dataset);
    end
    
    %% FRED data
    function testFredseries(testCase)
      opts = struct; opts.startDate = []; opts.endDate = [];
      opts.asOf = []; opts.asOfStart = []; opts.asOfEnd = [];
      dataseries = cbd.private.fredseries('UNRATE', opts);
      testseries = cbd.private.haverseries('LR');
      testCase.verifyEqual(size(dataseries, 2), 1);
      testCase.verifyGreaterThan(size(dataseries, 1), 100);
      testCase.verifyTrue(all(dataseries.UNRATE == testseries.LR));
    end
    
    function testFredOneSeries(testCase)
      % Pull one series
      dataset = cbd.data('INDPRO@FRED');
      testCase.verifyGreaterThan(size(dataset, 1), 100);
      testCase.verifyEqual(size(dataset,2), 1);
    end
    
    function testFredMultiSeries(testCase)
      % Pull multiple series
      dataset = cbd.data({'INDPRO', 'UNRATE'}, 'dbID', 'FRED');
      testCase.verifyGreaterThan(size(dataset, 1), 100);
      testCase.verifyEqual(size(dataset, 2), 2);
    end
    
    function testHaverFred(testCase)
      % Both Haver and FRED data
      dataset = cbd.data({'LR', 'UNRATE@FRED'});
      testCase.verifyEqual(dataset.LR, dataset.UNRATE);
    end
    
    function testFredBadSeries(testCase)
      % Bad data series
      dataErr = @() cbd.data('ASDFQWERTY@FRED');
      testCase.verifyError(dataErr, 'fredseries:fredError');
    end
    
    function testDates(testCase)
      % Haver
      dataset = cbd.data('GDPH', 'startDate', '01/01/2000');
      dates = datenum(dataset.Properties.RowNames);
      testCase.verifyGreaterThan(dates(1), datenum('12/31/1999'));
      
      dataset = cbd.data('GDPH', 'endDate', '12/31/1999');
      dates = datenum(dataset.Properties.RowNames);
      testCase.verifyLessThan(dates(end), datenum('01/01/2000'));
    end
    
    function testFredDates(testCase)
      dataset = cbd.data('UNRATE@FRED', 'startDate', '01/01/2000');
      dates = datenum(dataset.Properties.RowNames);
      testCase.verifyGreaterThan(dates(1), datenum('12/31/1999'));
      
      dataset = cbd.data('UNRATE@FRED', 'endDate', '12/31/1999');
      dates = datenum(dataset.Properties.RowNames);
      testCase.verifyLessThan(dates(end), datenum('01/01/2000'));
    end
    
    function testFredRealtime(testCase)
      testset = cbd.data('UNRATE@FRED');
      
      dataset = cbd.data('UNRATE@FRED', 'asOf', '12/31/1999');
      testCase.verifyNotEqual(size(dataset, 1), size(testset, 1));
      
      dataset = cbd.data('UNRATE@FRED', 'asOfStart', '6/30/2014', 'asOfEnd', today());
      testCase.verifyGreaterThan(size(dataset, 2), 1);
      testCase.verifyEqual(dataset{:,end}, testset{:,end});
    end
    
    function testBadTransformation(testCase)
      dataErr = @() cbd.data('notFn(GDPH)');
      testCase.verifyError(dataErr, 'expression_eval:function');
    end
    
    %% CHIDATA
    
    %% Statement parsing
    function testOperator(testCase)
      testset = cbd.data('FRACW + FRBW');
      dataset = cbd.addition(cbd.data('FRACW'), cbd.data('FRBW'));
      testCase.verifyEqual(testset{end, 1}, dataset{end,1});
    end
    
    function testSubtractionParse(testCase)
      % There used to be an issue where multiple subtraction was evaluated
      % backwards. Check for regression. 
      testset = cbd.data('C07 - C05 - C01');
      testCase.verifyEqual(testset{end, 1}, 1);
    end
    
    function testOrderOfOperations(testCase)
      % Test that the order of operations is followed. 
      testset = cbd.data('C07 * C05 - C01');
      testCase.verifyEqual(testset{end, 1}, 34);
      
      testset = cbd.data('C10 / C05 - C01');
      testCase.verifyEqual(testset{end, 1}, 1);
      
      testset = cbd.data('C02 + C10 / C05 - C01');
      testCase.verifyEqual(testset{end, 1}, 3);
      
      testset = cbd.data('C02 + C10 / (C05 - C01)');
      testCase.verifyEqual(testset{end, 1}, 4.5);
    end
    
    function testGrouping(testCase)
      testset = cbd.data('(FRACW + FRBW) / 1000');
      dataset = cbd.division(cbd.addition(cbd.data('FRACW'), cbd.data('FRBW')), 1000);
      testCase.verifyEqual(testset{end, 1}, dataset{end,1});
    end
    
    function testOption(testCase)
      % Discontinued series come back as nan unless explicitly stated
      testset = cbd.data('FRSBTAW + FRACW');
      testCase.verifyTrue(isnan(testset{end,1}));
      
      testset = cbd.data('(FRSBTAW + FRACW)#ignoreNan');
      testCase.verifyFalse(isnan(testset{end,1}));
      
      % Should only apply to argument its attached to, not later
      testset = cbd.data('FRSBTAW + FRACW#ignoreNan');
      testCase.verifyTrue(isnan(testset{end,1}));
      
      % Both arguments should be taken into account
      testset = cbd.data('FFED@DAILY#startDate:"12/31/2014"#endDate:"12/31/2014"');
      testCase.verifyEqual(size(testset), ones(1, 2));
      
      testset = cbd.data('FFED@DAILY#startDate:"1/1/2015"#endDate:"1/1/2014"');
      testCase.verifyEmpty(testset);
      
    end
  end
end