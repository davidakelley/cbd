classdef propsTest < matlab.unittest.TestCase
    %PROPSTEST is the test suite for cbd.chidata.props()
    %
    % Santiago Sordo-Palacios, 2019
    
    properties
        testProps
        nSer = randi(15);
        Source = 'Haver';
        Frequency = 'W';
        Magnitude = randi(15);
        AggType = 'Average';
        DataType = 'USD';
    end % properties
    
    methods (TestClassSetup)
        
        function loadActualProps(tc)
            tc.testProps = cbd.chidata.prop(tc.nSer, ...
                'Source', tc.Source, ...
                'Frequency', tc.Frequency, ...
                'Magnitude', tc.Magnitude, ...
                'AggType', tc.AggType, ...
                'DataType', tc.DataType);
        end % function
        
    end % methods
    
    methods (Test)
        
        function chidataProps(tc)
            for iSer = 1:tc.nSer
                tc.verifyEqual(tc.testProps(iSer).Source, tc.Source);
                tc.verifyEqual(tc.testProps(iSer).Frequency, tc.Frequency);
                tc.verifyEqual(tc.testProps(iSer).Magnitude, tc.Magnitude);
                tc.verifyEqual(tc.testProps(iSer).AggType, tc.AggType);
                tc.verifyEqual(tc.testProps(iSer).DataType, tc.DataType);
            end % for-iSer
        end % function
        
    end % methods
        
end % classdef