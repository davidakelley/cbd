classdef promptTest < matlab.unittest.TestCase
    %PROMPTTEST is the test suite for cbd.chidata.prompt
    %
    % Santiago Sordo-Palacios, 2019
    
    properties (Constant)
        id = 'chidata:testID';
        msg = 'Test Message';
    end % properties
    
    methods (TestMethodSetup)
        function setupOnce(tc)
            warning('off', tc.id);
        end % function
    end % methods-TestClassSetup
    
    methods (TestMethodTeardown)
        function teardownOnce(tc)
            warning('on', tc.id);
        end % function
    end % methods-TestClassSetup
    
    methods (Test)
        
        function promptBreak(tc)
            % Test that the prompt can be broken
            expectedErr = 'chidata:prompt:userBreak';
            actualErr = @() cbd.chidata.prompt(tc.id, tc.msg, 'n');
            tc.verifyError(actualErr, expectedErr);
        end % function
        
        function promptContinue(tc)
            % Test that the prompt can be continued
            cbd.chidata.prompt(tc.id, tc.msg, 'y');
        end % function
        
        function promptWarning(tc)
            % Test that the prompt issues the correct warning;
            warning('on', tc.id);
            actualWarn = @() cbd.chidata.prompt(tc.id, tc.msg, 'y');
            tc.verifyWarning(actualWarn, tc.id);
        end % function
        
    end % methods
    
end % classdef