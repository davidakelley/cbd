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

classdef disaggregationtests < matlab.unittest.TestCase
    properties
        AgdpVal
        gdpVal
        bbIndexVal
        lrVal
        nfciVal
    end
    
    methods(TestMethodSetup)
        function setupAll(testCase)
            testCase.AgdpVal = cbd.data('GDPCA@FRED', 'asOf', '1/1/2015', 'startDate', '1/1/2000');
            testCase.gdpVal = cbd.data('GDPH0001@ASREPGDP');
            testCase.bbIndexVal = cbd.data('BBSOUTLOOK@CHIDATA', 'endDate', '8/31/2015');
            testCase.lrVal = cbd.data('UNRATE@FRED', 'asOf', '1/1/2015', 'startDate', '1/1/2000');
            testCase.nfciVal = cbd.data('NFCI@FRED', 'asOf', '7/1/2015');
        end
    end
    
    methods (Test)
        %% Nan
        function testQuarterDisaggNan(testCase)
            % Annual => monthly
            testVal = cbd.disagg(testCase.AgdpVal, 'Q', 'NAN');
            testCase.verifyEqual(sum(isnan(testVal{:,:})), 42);
        end
        
        function testMonthlyDisaggNan(testCase)
            % Quarter => monthly
            testVal = cbd.disagg(testCase.gdpVal, 'M', 'NAN');
            testCase.verifyEqual(sum(isnan(testVal{:,:})), 328);
                        
            % Annual => monthly
            testVal = cbd.disagg(testCase.AgdpVal, 'M', 'NAN');
            testCase.verifyEqual(sum(isnan(testVal{:,:})), 154);
        end
       
        function testWeekDisaggNan(testCase)
            % Month => Weekly
            testVal = cbd.disagg(testCase.lrVal, 'W', 'NAN');
            testCase.verifyEqual(sum(isnan(testVal{:,:})), 600);
            dates = datenum(testVal.Properties.RowNames);
            dateDiff = dates(2:end)- dates(1:end-1);
            testCase.verifyEqual(size(unique(dateDiff), 1), 1); % All 7s
                  
            % Quarter => Weekly
            testVal = cbd.disagg(testCase.gdpVal, 'W', 'NAN');
            testCase.verifyEqual(sum(isnan(testVal{:,:})), 1976);
            dates = datenum(testVal.Properties.RowNames);
            dateDiff = dates(2:end)- dates(1:end-1);
            testCase.verifyEqual(size(unique(dateDiff), 1), 1);
                        
            % Annual => Weekly
            testVal = cbd.disagg(testCase.AgdpVal, 'W', 'NAN');
            testCase.verifyEqual(sum(isnan(testVal{:,:})), 717);
            dates = datenum(testVal.Properties.RowNames);
            dateDiff = dates(2:end)- dates(1:end-1);
            testCase.verifyEqual(size(unique(dateDiff), 1), 1);
        end
        
        function testDailyDisaggNan(testCase)
            % Weekly => Daily
            testVal = cbd.disagg(testCase.nfciVal, 'D', 'NAN');
            testCase.verifyEqual(sum(isnan(testVal{:,:})), 8860);
            dates = datenum(testVal.Properties.RowNames);
            dateDiff = dates(2:end)- dates(1:end-1);
            testCase.verifyEqual(size(unique(dateDiff), 1), 2); % Weekend and day-to-day
            
            % Month => Daily
            testVal = cbd.disagg(testCase.lrVal, 'D', 'NAN');
            testCase.verifyEqual(sum(isnan(testVal{:,:})), 3711);
            dates = datenum(testVal.Properties.RowNames);
            dateDiff = dates(2:end)- dates(1:end-1);
            testCase.verifyEqual(size(unique(dateDiff), 1), 2);
                  
            % Quarter => Daily
            testVal = cbd.disagg(testCase.gdpVal, 'D', 'NAN');
            testCase.verifyEqual(sum(isnan(testVal{:,:})), 10533);
            dates = datenum(testVal.Properties.RowNames);
            dateDiff = dates(2:end)- dates(1:end-1);
            testCase.verifyEqual(size(unique(dateDiff), 1), 2);
                        
            % Annual => Daily
            testVal = cbd.disagg(testCase.AgdpVal, 'D', 'NAN');
            testCase.verifyEqual(sum(isnan(testVal{:,:})), 3638);
            dates = datenum(testVal.Properties.RowNames);
            dateDiff = dates(2:end)- dates(1:end-1);
            testCase.verifyEqual(size(unique(dateDiff), 1), 2);
        end
        
        %% Fill
        function testQuarterDisaggFill(testCase)
            % Annual => monthly
            testVal = cbd.disagg(testCase.AgdpVal, 'Q', 'FILL');
            testCase.verifyLessThanOrEqual(size(unique(testVal{:,:}), 1), ...
                size(testCase.AgdpVal, 1));
            
            testCase.verifyEqual(sum(isnan(testVal{:,:})), 0);
        end
        
        function testMonthlyDisaggFill(testCase)
            % Quarter => monthly
            testVal = cbd.disagg(testCase.gdpVal, 'M', 'FILL');
            testCase.verifyLessThanOrEqual(size(unique(testVal{:,:}), 1), ...
                size(testCase.gdpVal, 1));   
            
            testCase.verifyEqual(sum(isnan(testVal{:,:})), 0);
            
            % Annual => monthly
            testVal = cbd.disagg(testCase.AgdpVal, 'M', 'FILL');
            testCase.verifyLessThanOrEqual(size(unique(testVal{:,:}), 1), ...
                size(testCase.AgdpVal, 1)); 

            testCase.verifyEqual(sum(isnan(testVal{:,:})), 0);
        end
       
        function testWeekDisaggFill(testCase)
            % Month => Weekly
            testVal = cbd.disagg(testCase.lrVal, 'W', 'FILL');
            testCase.verifyLessThanOrEqual(size(unique(testVal{:,:}), 1), ...
                size(testCase.lrVal, 1));
            
            dates = datenum(testVal.Properties.RowNames);
            dateDiff = dates(2:end)- dates(1:end-1);
            testCase.verifyEqual(size(unique(dateDiff), 1), 1);
            
            testCase.verifyEqual(sum(isnan(testVal{:,:})), 1);
                  
            % Quarter => Weekly
            testVal = cbd.disagg(testCase.gdpVal, 'W', 'FILL');
            testCase.verifyLessThanOrEqual(size(unique(testVal{:,:}), 1), ...
                size(testCase.gdpVal, 1)); 
            
            dates = datenum(testVal.Properties.RowNames);
            dateDiff = dates(2:end)- dates(1:end-1);
            testCase.verifyEqual(size(unique(dateDiff), 1), 1);
            
            testCase.verifyEqual(sum(isnan(testVal{:,:})), 0);
                        
            % Annual => Weekly
            testVal = cbd.disagg(testCase.AgdpVal, 'W', 'FILL');
            testCase.verifyLessThanOrEqual(size(unique(testVal{~isnan(testVal{:,:}),:}), 1), ...
                size(testCase.AgdpVal, 1)); 
            
            dates = datenum(testVal.Properties.RowNames);
            dateDiff = dates(2:end)- dates(1:end-1);
            testCase.verifyEqual(size(unique(dateDiff), 1), 1);
            
            testCase.verifyEqual(sum(isnan(testVal{:,:})), 1);
        end
        
        function testDailyDisaggFill(testCase)
            % Weekly => Daily
            testVal = cbd.disagg(testCase.nfciVal, 'D', 'FILL');
            testCase.verifyLessThanOrEqual(size(unique(testVal{:,:}), 1), ...
                size(testCase.nfciVal, 1));
            testCase.verifyGreaterThan(size(unique(testVal{:,:}), 1), 1);
            
            dates = datenum(testVal.Properties.RowNames);
            dateDiff = dates(2:end)- dates(1:end-1);
            testCase.verifyEqual(size(unique(dateDiff), 1), 2); % Weekend and day-to-day
            
            testCase.verifyEqual(sum(isnan(testVal{:,:})), 4);
            
            % Month => Daily
            testVal = cbd.disagg(testCase.lrVal, 'D', 'FILL');
            testCase.verifyLessThanOrEqual(size(unique(testVal{:,:}), 1), ...
                size(testCase.lrVal, 1));
            testCase.verifyGreaterThan(size(unique(testVal{:,:}), 1), 1);
            
            dates = datenum(testVal.Properties.RowNames);
            dateDiff = dates(2:end)- dates(1:end-1);
            testCase.verifyEqual(size(unique(dateDiff), 1), 2);
            
            testCase.verifyEqual(sum(isnan(testVal{:,:})), 0);
            
            % Quarter => Daily
            testVal = cbd.disagg(testCase.gdpVal, 'D', 'FILL');
            testCase.verifyLessThanOrEqual(size(unique(testVal{:,:}), 1), ...
                size(testCase.gdpVal, 1)); 
            testCase.verifyGreaterThan(size(unique(testVal{:,:}), 1), 1);
            
            dates = datenum(testVal.Properties.RowNames);
            dateDiff = dates(2:end)- dates(1:end-1);
            testCase.verifyEqual(size(unique(dateDiff), 1), 2);
            
            testCase.verifyEqual(sum(isnan(testVal{:,:})), 0);
            
            % Annual => Daily
            testVal = cbd.disagg(testCase.AgdpVal, 'D', 'FILL');
            testCase.verifyLessThanOrEqual(size(unique(testVal{:,:}), 1), ...
                size(testCase.AgdpVal, 1)); 
            testCase.verifyGreaterThan(size(unique(testVal{:,:}), 1), 1);
            
            dates = datenum(testVal.Properties.RowNames);
            dateDiff = dates(2:end)- dates(1:end-1);
            testCase.verifyEqual(size(unique(dateDiff), 1), 2);
            
            testCase.verifyEqual(sum(isnan(testVal{:,:})), 0);
        end
        
        %% Interp
        function testQuarterDisaggInterp(testCase)
            % Annual => monthly
            testVal = cbd.disagg(testCase.AgdpVal, 'Q', 'INTERP');
            testCase.verifyGreaterThan(size(unique(testVal{:,:}), 1), ...
                size(testCase.AgdpVal, 1));
            
            testCase.verifyEqual(sum(isnan(testVal{:,:})), 3);
        end
        
        function testMonthlyDisaggInterp(testCase)
            % Quarter => monthly
            testVal = cbd.disagg(testCase.gdpVal, 'M', 'INTERP');
            testCase.verifyGreaterThan(size(unique(testVal{:,:}), 1), ...
                size(testCase.gdpVal, 1));   
            
            testCase.verifyEqual(sum(isnan(testVal{:,:})), 2);
            
            % Annual => monthly
            testVal = cbd.disagg(testCase.AgdpVal, 'M', 'INTERP');
            testCase.verifyGreaterThan(size(unique(testVal{:,:}), 1), ...
                size(testCase.AgdpVal, 1)); 

            testCase.verifyEqual(sum(isnan(testVal{:,:})), 11);
        end
       
        function testWeekDisaggInterp(testCase)
            % Month => Weekly
            testVal = cbd.disagg(testCase.lrVal, 'W', 'INTERP');
            testCase.verifyGreaterThan(size(unique(testVal{:,:}), 1), ...
                size(testCase.lrVal, 1));
            
            dates = datenum(testVal.Properties.RowNames);
            dateDiff = dates(2:end)- dates(1:end-1);
            testCase.verifyEqual(size(unique(dateDiff), 1), 1);
            
            testCase.verifyEqual(sum(isnan(testVal{:,:})), 4);
                  
            % Quarter => Weekly
            testVal = cbd.disagg(testCase.gdpVal, 'W', 'INTERP');
            testCase.verifyGreaterThan(size(unique(testVal{:,:}), 1), ...
                size(testCase.gdpVal, 1)); 
            
            dates = datenum(testVal.Properties.RowNames);
            dateDiff = dates(2:end)- dates(1:end-1);
            testCase.verifyEqual(size(unique(dateDiff), 1), 1);
            
            testCase.verifyEqual(sum(isnan(testVal{:,:})), 12);
                        
            % Annual => Weekly
            testVal = cbd.disagg(testCase.AgdpVal, 'W', 'INTERP');
            testCase.verifyGreaterThan(size(unique(testVal{:,:}), 1), ...
                size(testCase.AgdpVal, 1)); 
            
            dates = datenum(testVal.Properties.RowNames);
            dateDiff = dates(2:end)- dates(1:end-1);
            testCase.verifyEqual(size(unique(dateDiff), 1), 1);
            
            testCase.verifyEqual(sum(isnan(testVal{:,:})), 52);
        end
        
        function testDailyDisaggInterp(testCase)
            % Weekly => Daily
            testVal = cbd.disagg(testCase.nfciVal, 'D', 'INTERP');
            testCase.verifyGreaterThan(size(unique(testVal{:,:}), 1), ...
                size(testCase.nfciVal, 1));
            
            dates = datenum(testVal.Properties.RowNames);
            dateDiff = dates(2:end)- dates(1:end-1);
            testCase.verifyEqual(size(unique(dateDiff), 1), 2); % Weekend and day-to-day
            
            testCase.verifyEqual(sum(isnan(testVal{:,:})), 4);
            
            % Month => Daily
            testVal = cbd.disagg(testCase.lrVal, 'D', 'INTERP');
            testCase.verifyGreaterThan(size(unique(testVal{:,:}), 1), ...
                size(testCase.lrVal, 1));
            
            dates = datenum(testVal.Properties.RowNames);
            dateDiff = dates(2:end)- dates(1:end-1);
            testCase.verifyEqual(size(unique(dateDiff), 1), 2);
            
            testCase.verifyEqual(sum(isnan(testVal{:,:})), 20);
            
            % Quarter => Daily
            testVal = cbd.disagg(testCase.gdpVal, 'D', 'INTERP');
            testCase.verifyGreaterThan(size(unique(testVal{:,:}), 1), ...
                size(testCase.gdpVal, 1)); 
            
            dates = datenum(testVal.Properties.RowNames);
            dateDiff = dates(2:end)- dates(1:end-1);
            testCase.verifyEqual(size(unique(dateDiff), 1), 2);
            
            testCase.verifyEqual(sum(isnan(testVal{:,:})), 63);
            
            % Annual => Daily
            testVal = cbd.disagg(testCase.AgdpVal, 'D', 'INTERP');
            testCase.verifyGreaterThan(size(unique(testVal{:,:}), 1), ...
                size(testCase.AgdpVal, 1)); 
            
            dates = datenum(testVal.Properties.RowNames);
            dateDiff = dates(2:end)- dates(1:end-1);
            testCase.verifyEqual(size(unique(dateDiff), 1), 2);
            
            testCase.verifyEqual(sum(isnan(testVal{:,:})), 259);
        end
                
        %% Growth
        function testQuarterDisaggGrowth(testCase)
            % Annual => monthly
            testVal = cbd.disagg(testCase.AgdpVal, 'Q', 'GROWTH');
            testCase.verifyGreaterThan(size(unique(testVal{:,:}), 1), ...
                size(testCase.AgdpVal, 1));
            
            testCase.verifyLessThan(abs(testVal{end, 1} - testCase.AgdpVal{end,1}), 1e9);
            
            testCase.verifyEqual(sum(isnan(testVal{:,:})), 3); % 1st 3 quarters of A1
        end
        
        function testMonthlyDisaggGrowth(testCase)
            % Quarter => monthly
            testVal = cbd.disagg(testCase.gdpVal, 'M', 'GROWTH');
            testCase.verifyGreaterThan(size(unique(testVal{:,:}), 1), ...
                size(testCase.gdpVal, 1));   

            testCase.verifyLessThan(abs(testVal{end, 1} - testCase.gdpVal{end,1}), 1e9);

            testCase.verifyEqual(sum(isnan(testVal{:,:})), 2); % 1st 2 months of Q1
            
            % Annual => monthly
            testVal = cbd.disagg(testCase.AgdpVal, 'M', 'GROWTH');
            testCase.verifyGreaterThan(size(unique(testVal{:,:}), 1), ...
                size(testCase.AgdpVal, 1)); 

            testCase.verifyLessThan(abs(testVal{end, 1} - testCase.AgdpVal{end,1}), 1e9);
            
            testCase.verifyEqual(sum(isnan(testVal{:,:})), 11); % 1st 11 months of A1
        end
       
        function testWeekDisaggGrowth(testCase)
            % Month => Weekly
            testVal = cbd.disagg(testCase.lrVal, 'W', 'GROWTH');
            testCase.verifyGreaterThan(size(unique(testVal{:,:}), 1), ...
                size(testCase.lrVal, 1));
            
            dates = datenum(testVal.Properties.RowNames);
            dateDiff = dates(2:end)- dates(1:end-1);
            testCase.verifyEqual(size(unique(dateDiff), 1), 1);
            
            testCase.verifyLessThan(abs(testVal{end-1, 1} - testCase.lrVal{end,1}), 1e-9);

            % 1st 3 weeks of M1, 
            % last week missing too? No its not
            testCase.verifyEqual(sum(isnan(testVal{:,:})), 3); 
                  
            % Quarter => Weekly
            testVal = cbd.disagg(testCase.gdpVal, 'W', 'GROWTH');
            testCase.verifyGreaterThan(size(unique(testVal{:,:}), 1), ...
                size(testCase.gdpVal, 1)); 
            
            dates = datenum(testVal.Properties.RowNames);
            dateDiff = dates(2:end)- dates(1:end-1);
            testCase.verifyEqual(size(unique(dateDiff), 1), 1);
            
            testCase.verifyLessThan(abs(testVal{end, 1} - testCase.gdpVal{end,1}), 1e9);

            % 1st 12 weeks of Q1
            testCase.verifyEqual(sum(isnan(testVal{:,:})), 12); 
                        
            % Annual => Weekly
            testVal = cbd.disagg(testCase.AgdpVal, 'W', 'GROWTH');
            testCase.verifyGreaterThan(size(unique(testVal{:,:}), 1), ...
                size(testCase.AgdpVal, 1)); 
            
            dates = datenum(testVal.Properties.RowNames);
            dateDiff = dates(2:end)- dates(1:end-1);
            testCase.verifyEqual(size(unique(dateDiff), 1), 1);

            testCase.verifyLessThan(abs(testVal{end-1, 1} - testCase.AgdpVal{end,1}), 1e9);
            
            % 1st 51 weeks of A1, first week of A(end)
            testCase.verifyEqual(sum(isnan(testVal{:,:})), 51); 
        end
        
        function testDailyDisaggGrowth(testCase)
            % Weekly => Daily
            %{
            testVal = cbd.disagg(testCase.nfciVal, 'D', 'GROWTH');
            testCase.verifyGreaterThan(size(unique(testVal{:,:}), 1), ...
                size(testCase.nfciVal, 1));
            
            dates = datenum(testVal.Properties.RowNames);
            dateDiff = dates(2:end)- dates(1:end-1);
            testCase.verifyEqual(size(unique(dateDiff), 1), 2); % Weekend and day-to-day
            
            testCase.verifyEqual(sum(isnan(testVal{:,:})), 4); % First 4 days 
            %}
            
            % Month => Daily
            testVal = cbd.disagg(testCase.lrVal, 'D', 'GROWTH');
            testCase.verifyGreaterThan(size(unique(testVal{:,:}), 1), ...
                size(testCase.lrVal, 1));
            
            dates = datenum(testVal.Properties.RowNames);
            dateDiff = dates(2:end)- dates(1:end-1);
            testCase.verifyEqual(size(unique(dateDiff), 1), 2);
            
            testCase.verifyLessThan(abs(testVal{end, 1} - testCase.lrVal{end,1}), 1e9);

            testCase.verifyEqual(sum(isnan(testVal{:,:})), 20); % First 20 days
            
            % Quarter => Daily
            testVal = cbd.disagg(testCase.gdpVal, 'D', 'GROWTH');
            testCase.verifyGreaterThan(size(unique(testVal{:,:}), 1), ...
                size(testCase.gdpVal, 1)); 
            
            dates = datenum(testVal.Properties.RowNames);
            dateDiff = dates(2:end)- dates(1:end-1);
            testCase.verifyEqual(size(unique(dateDiff), 1), 2);

            testCase.verifyLessThan(abs(testVal{end, 1} - testCase.gdpVal{end,1}), 1e9);
            
            testCase.verifyEqual(sum(isnan(testVal{:,:})), 63); % Not sure on this one
            
            % Annual => Daily
            testVal = cbd.disagg(testCase.AgdpVal, 'D', 'GROWTH');
            testCase.verifyGreaterThan(size(unique(testVal{:,:}), 1), ...
                size(testCase.AgdpVal, 1)); 
            
            dates = datenum(testVal.Properties.RowNames);
            dateDiff = dates(2:end)- dates(1:end-1);
            testCase.verifyEqual(size(unique(dateDiff), 1), 2);
            
            testCase.verifyLessThan(abs(testVal{end, 1} - testCase.AgdpVal{end,1}), 1e9);

            testCase.verifyEqual(sum(isnan(testVal{:,:})), 259); % Again, not sure
        end
        
        %% 2 inputs
        function testThreeInput(testCase)
            % Annual => annual
            testVal = cbd.disagg(testCase.AgdpVal, 'A');
            trueVal = cbd.disagg(testCase.AgdpVal, 'A', 'NAN');
            testCase.verifyEqual(testVal, trueVal);
        end
        
        %% IRREGULAR
        function testDisaggToIrregular(testCase)
            testVal = cbd.disagg(testCase.AgdpVal, 'IRREGULAR', 'NAN');
            testCase.verifyEqual(testVal, testCase.AgdpVal);
        end
        
        function testDisaggFromIrregular(testCase)
            % Irregular => monthly
            warning('off', 'cbd:getFreq:oddDates');
            testVal = cbd.disagg(testCase.bbIndexVal, 'M', 'NAN');
            warning('on', 'cbd:getFreq:oddDates');
            testCase.verifyEqual(sum(isnan(testVal{:,:})), 11);
        end
        
        %% Disagg to current frequency
        function testSameFreq(testCase)
            % Annual => annual
            testVal = cbd.disagg(testCase.AgdpVal, 'A', 'NAN');
            testCase.verifyEqual(size(testVal, 1), size(testCase.AgdpVal, 1));    
        end
        
        
    end
end
