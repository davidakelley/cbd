classdef saTest < matlab.unittest.TestCase
    %SATEST is the test sutie cbd.sa()
    %
    % These tests check that the we can pass optional inputs to cbd.sa 
    % and get meaninful errors in the stack trace.
    %
    % Note that we're not testing that Census X13 actually does seasonal 
    % adjustment correctly.
    %
    % TODO: Add meaningful errors to the stack trace.
    %
    % David Kelley, 2019
    
    properties
        pcun
    end

    methods (TestClassSetup)
        function setupOnce(tc)
            tc.pcun = cbd.expression('DIFAL(PCUN)', ...
                'startDate', '1/1/1970');
        end
    end

    methods (Test)
        %% Optional inputs
        % Test that a default call still works
        function testDefault(tc)
            testVal = cbd.sa(tc.pcun);
            tc.verifyTrue(isa(testVal, 'table'));
        end

        % Test that we don't need to specifiy saving d11
        function testNoSpecd11(tc)
            testVal = cbd.sa(tc.pcun, ...
                'transform:function:auto', ...
                'automdl:maxorder:(2 1)', ...
                'automdl:maxdiff:(2 1)');

            tc.verifyTrue(isa(testVal, 'table'));
        end

        % Test that we can specifiy saving d11
        function testSaved11(tc)
            testVal = cbd.sa(tc.pcun, ...
                'transform:function:auto', ...
                'automdl:maxorder:(2 1)', ...
                'automdl:maxdiff:(2 1)', ...
                'x11:save:d11');
            tc.verifyTrue(isa(testVal, 'table'));
        end

        % Test that we can use shortucts
        function testShortcutSimple(tc)
            testVal = cbd.sa(tc.pcun, 'ADDITIVE');
            tc.verifyTrue(isa(testVal, 'table'));
        end

        % Test that we can use shortucts with other inputs
        function testShortcutAdditional(tc)
            testVal = cbd.sa(tc.pcun, 'FLOW', 'transform:function:auto');
            tc.verifyTrue(isa(testVal, 'table'));
        end
    end
end
