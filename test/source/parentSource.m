classdef (Abstract) parentSource < matlab.unittest.TestCase
    %PARENTSOURCE is the parent class for the cbd.source tests
    %
    % DESCRIPTION
    %   The parentSource class is the parent class for all tests of the
    %   cbd.source functions, which are in the test/ folder
    %   This class contains the properties (options) and methods (tests)
    %   that all cbd.source functions must pass
    %
    % USAGE
    %   >> runtests('haverseries') % execute haverseries tests which inherits
    %
    % SEE ALSO: HAVERSERIESTEST, BLOOMBERGSERIESTEST,
    %           FREDSERIESTEST, CHIDATASERIESTEST
    %
    % Santiago I. Sordo Palacios, 2019

    properties (Abstract)
        % The properties set in the child classes
        source      char                % the name of the child class
        seriesID    char                % the main series tested
        dbID        char                % the main database tested
        testfun     function_handle     % the private function to test
        benchmark   double              % the benchmarked time for speed
    end % properties

    properties (Constant)
        % The properties that are not modified in any tests
        XinvalidParen   = {'(x', 'x)', '(x)'}; % invalid parentheses
        XinvalidAtSign  = {'x@', '@x'}; % invalid at signs
        floorDate       = '12/31/1999'; % the floor for startDate
        startDate       = '01/01/2000'; % the tested startDate
        endDate         = '12/31/2000'; % the tested endDate
        ceilingDate     = '01/01/2001'; % the ceiling for endDate
        inputFmt        = 'MM/dd/yyyy'; % the input datestr format
        relativeTol     = 0.05;         % the relative tolerance of speed tests
    end % properties

    properties
        % The properties that can be modified in the tests
        opts = struct(); % the second input to testfun
    end % properties

    methods (TestClassSetup)
        function baseOpts(tc)
            % Set the expected options for all child functions
            tc.opts.startDate = [];
            tc.opts.endDate = [];
        end % function
    end % methods

    methods (Test)
        %% Tests for seriesID
        function nullSeries(tc)
            % Tests a null seriesID
            tc.seriesID = '';
            actualErr = @() tc.testfun(tc.seriesID, tc.opts);
            expectedErr = [tc.source, ':nullSeries'];
            tc.verifyError(actualErr, expectedErr);
        end % function

        function invalidParen(tc)
            % Test a list of invalid parentheses
            nInv = length(tc.XinvalidParen);
            expectedErr = [tc.source, ':invalidParen'];
            for iInv = 1:nInv
                tc.seriesID = tc.XinvalidParen{iInv};
                actualErr = @() tc.testfun(tc.seriesID, tc.opts);
                tc.verifyError(actualErr, expectedErr);
            end % for-iChar
        end % function

        function invalidAtSign(tc)
            % Test a list of invalid @ signs
            nInv = length(tc.XinvalidAtSign);
            expectedErr = [tc.source, ':invalidAtSign'];
            for iInv = 1:nInv
                tc.seriesID = tc.XinvalidAtSign{iInv};
                actualErr = @() tc.testfun(tc.seriesID, tc.opts);
                tc.verifyError(actualErr, expectedErr);
            end % for-iChar
        end % function

        function noPull(tc)
            % Test a series that does not exist in the DB
            tc.seriesID = 'VALIDBUTBADSERIES';
            actualErr = @() tc.testfun(tc.seriesID, tc.opts);
            expectedErr = [tc.source, ':noPull'];
            tc.verifyError(actualErr, expectedErr);
        end % function

        function goodSeries(tc)
            % Test a good series in the DB
            % Covers the range of tests that goodDB() would
            data = tc.testfun(tc.seriesID, tc.opts);
            tc.verifyGreaterThan(size(data, 1), 100);
            tc.verifyEqual(size(data, 2), 1);
            tc.verifyEqual(data.Properties.VariableNames{1}, tc.seriesID)
        end % function
        
        function caseInsensitive(tc)
            % Test case-insensitive call
            changeCase = @(x) ...
                regexprep(lower(x),'(\<[a-z])','${upper($1)}');
            tc.seriesID = changeCase(tc.seriesID);
            tc.dbID = changeCase(tc.dbID);
            data = tc.testfun(tc.seriesID, tc.opts);
            tc.verifyTrue(~isempty(data));
        end % function

        %% Tests for dbID
        function missDB(tc)
            % Test a pull with a missing dbID field
            tc.opts = rmfield(tc.opts, 'dbID');
            actualErr = @() tc.testfun(tc.seriesID, tc.opts);
            expectedErr = [tc.source, ':missdbID'];
            tc.verifyError(actualErr, expectedErr);
        end % function

        function nullDB(tc)
            % Test a pull with a null dbID
            tc.opts.dbID = '';
            actualErr = @() tc.testfun(tc.seriesID, tc.opts);
            expectedErr = [tc.source, ':nulldbID'];
            tc.verifyError(actualErr, expectedErr);
        end % function

        function invalidDB(tc)
            % Test a pull with an invalid dbID
            tc.opts.dbID = 'INVALIDDBID';
            actualErr = @() tc.testfun(tc.seriesID, tc.opts);
            expectedErr = [tc.source, ':invaliddbID'];
            tc.verifyError(actualErr, expectedErr);
        end % function

        %% Tests for startDate
        function missStartDate(tc)
            % Test pull with missing startDate field
            tc.opts = rmfield(tc.opts, 'startDate');
            actualErr = @() tc.testfun(tc.seriesID, tc.opts);
            expectedErr = [tc.source, ':missstartDate'];
            tc.verifyError(actualErr, expectedErr);
        end % function

        function nullStartDate(tc)
            % Test pull with null startDate
            tc.opts.startDate = [];
            data = tc.testfun(tc.seriesID, tc.opts);
            tc.verifyGreaterThan(size(data, 1), 100);
            tc.verifyEqual(size(data, 2), 1);
        end % function

        function invalidStartDate(tc)
            % Test pull with invalid startDate
            tc.opts.startDate = 'INVALID';
            actualErr = @() tc.testfun(tc.seriesID, tc.opts);
            expectedErr = 'parseDates:invalidDate';
            tc.verifyError(actualErr, expectedErr);
        end % function

        function datestrStartDate(tc)
            % Test pull with a dateStr startDate
            tc.opts.startDate = tc.startDate;
            data = tc.testfun(tc.seriesID, tc.opts);
            dateNums = datenum(data.Properties.RowNames);
            tc.verifyGreaterThan(dateNums(1), datenum(tc.floorDate));
        end % function

        function datenumStartDate(tc)
            % Test pull with datenum startDate
            tc.opts.startDate = datenum(tc.startDate);
            data = tc.testfun(tc.seriesID, tc.opts);
            dateNums = datenum(data.Properties.RowNames);
            tc.verifyGreaterThan(dateNums(1), datenum(tc.floorDate));
        end % function

        function datetimeStartDate(tc)
            % Test pull with datenum startDate
            tc.opts.startDate = datetime(tc.startDate, ...
                'InputFormat', tc.inputFmt);
            data = tc.testfun(tc.seriesID, tc.opts);
            dateNums = datenum(data.Properties.RowNames);
            tc.verifyGreaterThan(dateNums(1), datenum(tc.floorDate));
        end % function

        %% Test for endDate
        function missEndDate(tc)
            % Test pull with missing endDate field
            tc.opts = rmfield(tc.opts, 'endDate');
            actualErr = @() tc.testfun(tc.seriesID, tc.opts);
            expectedErr = [tc.source, ':missendDate'];
            tc.verifyError(actualErr, expectedErr);
        end % function

        function nullEndDate(tc)
            % Test pull with null endDate
            tc.opts.endDate = [];
            data = tc.testfun(tc.seriesID, tc.opts);
            tc.verifyGreaterThan(size(data, 1), 100);
            tc.verifyEqual(size(data, 2), 1);
        end % function

        function invalidEndDate(tc)
            % Test pull with invalid endDate
            tc.opts.endDate = 'INVALID';
            actualErr = @() tc.testfun(tc.seriesID, tc.opts);
            expectedErr = 'parseDates:invalidDate';
            tc.verifyError(actualErr, expectedErr);
        end % function

        function datestrEndDate(tc)
            % Test pull with datestr startDate
            tc.opts.endDate = tc.endDate;
            data = tc.testfun(tc.seriesID, tc.opts);
            dateNums = datenum(data.Properties.RowNames);
            tc.verifyLessThan(dateNums(1), datenum(tc.ceilingDate));
        end % function

        function datenumEndDate(tc)
            % Test pull with datenum startDate
            tc.opts.endDate = datenum(tc.endDate);
            data = tc.testfun(tc.seriesID, tc.opts);
            dateNums = datenum(data.Properties.RowNames);
            tc.verifyLessThan(dateNums(1), datenum(tc.ceilingDate));
        end % function

        function datetimeEndtDate(tc)
            % Test pull with datenum startDate
            tc.opts.endDate = datetime(tc.endDate, ...
                'InputFormat', tc.inputFmt);
            data = tc.testfun(tc.seriesID, tc.opts);
            dateNums = datenum(data.Properties.RowNames);
            tc.verifyLessThan(dateNums(1), datenum(tc.ceilingDate));
        end % function

        %% Test for both start and end date
        function bothDates(tc)
            % Test pull with both startDate and endDate
            tc.opts.startDate = tc.startDate;
            tc.opts.endDate = tc.endDate;
            data = tc.testfun(tc.seriesID, tc.opts);
            dateNums = datenum(data.Properties.RowNames);
            tc.verifyGreaterThan(dateNums(1), datenum(tc.floorDate));
            tc.verifyLessThan(dateNums(end), datenum(tc.ceilingDate));
        end % function

        %% Tests for props
        function idProp(tc)
            % Test the props.ID field
            [~, props] = tc.testfun(tc.seriesID, tc.opts);
            actualdbID = split(props.ID, '@');
            tc.verifyEqual(actualdbID{2}, tc.opts.dbID);
        end % function

        function infoProp(tc)
            % Test the props.dbInfo field
            [~, props] = tc.testfun(tc.seriesID, tc.opts);
            tc.verifyTrue(isfield(props, 'dbInfo'));
        end % function

        function valueProp(tc)
            % Test the props.value field
            [data, props] = tc.testfun(tc.seriesID, tc.opts);
            expectedVal = data;
            tc.verifyEqual(props.value, expectedVal);
        end % function

        function providerProp(tc)
            % Test the props.provider field
            [~, props] = tc.testfun(tc.seriesID, tc.opts);
            expectedProv = erase(tc.source, 'series');
            tc.verifyEqual(props.provider, expectedProv);
        end % function

        %% Tests for speed of functions
        function speedTest(tc)
            % Check that changes to cbd have not impacted performance
            import matlab.unittest.constraints.IsEqualTo
            import matlab.unittest.constraints.RelativeTolerance
            speedFun = @() tc.testfun(tc.seriesID, tc.opts);
            thisTime = timeit(speedFun);
            tc.verifyThat(thisTime, ...
                IsEqualTo(tc.benchmark, ...
                'Within', RelativeTolerance(tc.relativeTol)))
        end % function

    end % methods-test

end % classdef