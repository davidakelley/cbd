classdef propsTest < chidataSuiteTest
    % Test cbd.chidata.props
    
    methods (Test)
        
        function chidataProps(tc)
            % Tests the props loading works correctly
            nSer = 5;
            Source = 'Haver';
            Frequency = 'W';
            Magnitude = 7;
            AggType = 'Average';
            DataType = 'USD';

            testProps = cbd.chidata.prop(nSer, ...
                'Source', Source, ...
                'Frequency', Frequency, ...
                'Magnitude', Magnitude, ...
                'AggType', AggType, ...
                'DataType', DataType);

            for iSer = 1:nSer
                tc.verifyEqual(testProps(iSer).Source, Source);
                tc.verifyEqual(testProps(iSer).Frequency, Frequency);
                tc.verifyEqual(testProps(iSer).Magnitude, Magnitude);
                tc.verifyEqual(testProps(iSer).AggType, AggType);
                tc.verifyEqual(testProps(iSer).DataType, DataType);
            end % for-iSer
        end % function
        
    end % methods
        
end % classdef