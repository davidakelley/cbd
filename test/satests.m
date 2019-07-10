%% Test suite for the sa function in cbd
%
% These tests check that the we can pass optional inputs to cbd.sa and get meaninful
% errors in the stack trace. 
%
% Note that we're not testing that X13 actually does seasonal adjustment correctly.
% Assuming that Census has done that. 
%
% TODO: Add meaningful errors to the stack trace. 
%
% See also: execTests.m

% David Kelley, 2019

classdef satests < matlab.unittest.TestCase
  properties
    pcun
  end
  
  methods(TestMethodSetup)
    function setupOnce(testCase)
      testCase.pcun = cbd.data('DIFAL(PCUN)', 'startDate', '1/1/1970');
    end
  end
  
  methods (Test)
    %% Optional inputs
    % Test that a default call still works 
    function testDefault(testCase)
      testVal = cbd.sa(testCase.pcun);      
      testCase.verifyTrue(isa(testVal, 'table'));
    end
    
    % Test that we don't need to specifiy saving d11
    function testNoSpecd11(testCase)
      testVal = cbd.sa(testCase.pcun, ...
        'transform:function:auto', ...
        'automdl:maxorder:(2 1)', ...
        'automdl:maxdiff:(2 1)');
      
      testCase.verifyTrue(isa(testVal, 'table'));
    end
    
    % Test that we can specifiy saving d11
    function testSaved11(testCase)
      testVal = cbd.sa(testCase.pcun, ...
        'transform:function:auto', ...
        'automdl:maxorder:(2 1)', ...
        'automdl:maxdiff:(2 1)', ...
        'x11:save:d11');
      
      testCase.verifyTrue(isa(testVal, 'table'));
    end
    
    % Test that we can use shortucts 
    function testShortcutSimple(testCase)
      testVal = cbd.sa(testCase.pcun, 'ADDITIVE');
      
      testCase.verifyTrue(isa(testVal, 'table'));
    end
    
    % Test that we can use shortucts with other inputs
    function testShortcutAdditional(testCase)
      testVal = cbd.sa(testCase.pcun, 'FLOW', 'transform:function:auto');
      
      testCase.verifyTrue(isa(testVal, 'table'));
    end
  end
end
