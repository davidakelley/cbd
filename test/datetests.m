%% Test suite for the date methods in cbd
%
% See also: execTests.m

% David Kelley, 2019

classdef datetests < matlab.unittest.TestCase
  methods (Test)
    %% endOfPer function
    function testWeeklyEndOfPer(testCase)
      % Test that Saturday is the last day in a week
      
      saturdayDate = datenum('02-Jun-2018');    
      prevSat = saturdayDate - 7;
      nextSat = saturdayDate + 7;
      
      dates = prevSat:1:nextSat;
      cbdDates = cbd.private.endOfPer(dates', 'W');
      
      testDates = [prevSat; repmat(saturdayDate, [7 1]); repmat(nextSat, [7 1])];
      
      testCase.verifyEqual(cbdDates, testDates);
    end
  end
end
