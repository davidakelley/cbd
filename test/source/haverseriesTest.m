classdef (Sealed) haverseriesTest < sourceTest
    %HAVERSERIESTEST is the test suite for cbd.source.haverseries
    %
    % USAGE
    %   >> runtests('haverseriesTest')
    %
    % Santiago Sordo-Palacios, 2019

    properties
        % The abstract properties from the parent class
        source = 'haverseries';
        seriesID = 'GDPH';
        dbID = 'USECON';
        testfun = @(x, y) cbd.source.haverseries(x, y);
        benchmark = 0.31258; %v1.2.0
    end % properties

    methods (TestClassSetup)

        function haverOpts(tc)
            % Set the haverseries-specific opts
            tc.opts.dbID = tc.dbID;
        end % function

        function checkConnectHaver(tc)
            c = cbd.source.connectHaver(tc.dbID);
            tc.fatalAssertTrue(isequal(isconnection(c), 1))
        end % function

    end % methods

    methods (Test)

        function otherDB(tc)
            % Test a pull to a different dbID
            tc.seriesID = 'FRBCNAIM';
            tc.opts.dbID = 'SURVEYS';
            [data, prop] = tc.testfun(tc.seriesID, tc.opts);
            tc.verifyGreaterThan(size(data, 1), 100);
            tc.verifyEqual(size(data, 2), 1);
            actualdbID = erase(prop.ID, [tc.seriesID, '@']);
            tc.verifyEqual(actualdbID, tc.opts.dbID);
        end % function

    end % methods

end % classdef