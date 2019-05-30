%% Test suite for cbd.data function
%
% See also: execTests.m

% David Kelley, 2015

classdef loadDataset_test < matlab.unittest.TestCase
  methods (Test)
    %% Haver data
    function testLoad(testCase)
      dataset = cbd.loadDataset({'LR', 'GDPH', 'C02'});
      
      testCase.verifyGreaterThan(size(dataset, 1), 100);
      testCase.verifyEqual(size(dataset, 2), 3);
      
      testCase.verifyEqual(dataset{'31-Jan-1948',1}, 3.4);
      testCase.verifyTrue(all(dataset{:,3}==2));
    end
    
    function testMany(testCase)
      
      specs = {'GDPH', 'GDYH@USNA', 'CBHM', 'LIPRIVA', 'CUT', 'HST', ...
        'EXTEND_LAST(EXTEND(FFGR(DISAGG(JG,"M","GROWTH"),PA49401),"endCount",1))', ...
        'SA( FTO) / GOVPRICE@LOCAL', 'BFGR(BGSB/10000,TMBCA)', ...
        '((NARI+NAWIH)/EXTEND_LAST(EXTEND((NWIH+NRI)/(NWIH+NMI+NRI),"endCount",1)))/PB9411', ...
        'FFGR(SPLICE(TITH, TITH2),ADVINV@LOCAL)', 'IGTP', 'YPMH', ...
        'UMINFE1@CHIDATA'};
      names = {'GDP', 'GDI', 'PCE', 'HOURS', 'CU', 'HOUST', 'GOVPRICE', 'RFTO', ...
        'TRADE', 'ADVINV', 'RMTI', 'IP', 'PI', 'INFE'};

      dataset = cbd.loadDataset(specs, 'Names', names);
      
      testCase.verifyGreaterThan(size(dataset, 1), 100);
      testCase.verifyEqual(size(dataset, 2), 13);
    end
    
    function testNames(testCase)
      % If there's no computation to a series, we want to use the name of the series
      % (minus any database name).
      
      dataset = cbd.loadDataset({'LR', 'C02'});      
      testCase.verifyTrue(all(dataset.C02==2));
    end
  end
end
