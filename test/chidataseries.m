classdef chidataseries < sourceseries
    %CHIDATASERIES is the test suite for cbd.private.chidataseries()
    %
    % USAGE
    %   >> runtests('chidataseries')
    %
    % Santiago I. Sordo Palacios, 2019
    
    properties
        % The abstract properties from the parent class
        source      = 'chidataseries';
        seriesID    = 'SERIES'
        dbID        = 'CHIDATA';
        testfun     = @(x,y) cbd.source.chidataseries(x,y);
        benchmark   = 0.24087; %v1.2.0
    end % properties
    
    properties (Constant)
        % The constant properties for the chidataseries tests
        testDir = tempname;
        indexName = 'index.csv'
        propsName = 'prop.csv';
        testName = 'test';
    end % properties
    
    methods (TestClassSetup)
        
        function chidataOpts(tc)
            % Set the chidataseries-specific options
            tc.opts.dbID = tc.dbID;
        end % function
        
        function createTestDir(tc)
            % Initialize a chidata directory and check its access
            mkdir(tc.testDir);
            cbd.private.chidatadir(tc.testDir);
            thisFile = fullfile(tc.testDir, tc.indexName);
            [~, fmsg] = fileattrib(thisFile);
            foundFile = ~ischar(fmsg);
            tc.fatalAssertTrue(foundFile);
            tc.fatalAssertTrue(fmsg.UserRead);
            tc.fatalAssertTrue(fmsg.UserWrite);
        end % function
        
        function createTestData(tc)
            % create an array of dates
            inFmt = 'MM/dd/yyyy';
            firstDate = datetime( ...
                tc.startDate, 'InputFormat', inFmt) - calyears(4);
            lastDate = datetime( ...
                tc.endDate, 'InputFormat', inFmt) + calyears(4);
            DATES = transpose(firstDate:calmonths(1):lastDate);
            
            % create an array of data
            nDates = length(DATES);
            rng(1, 'twister');
            SERIES = randi(10, nDates, 1);
            
            % create a table with dates and data
            testTable = table(SERIES);
            testTable.Properties.RowNames = cellstr(datestr(DATES));
            
            % get the chidata properties
            testProps = cbd.chidata_prop(1);
            warning('off', 'chidata_save:newFile');
            cbd.chidata_save(tc.testName, testTable, testProps);
            warning('on', 'chidata_save:newFile');
            
            % check that the data file exiss
            thisFile = fullfile(tc.testDir, [tc.testName '_data.csv']);
            [~, fmsg] = fileattrib(thisFile);
            foundFile = ~ischar(fmsg);
            tc.fatalAssertTrue(foundFile);
            tc.fatalAssertTrue(fmsg.UserRead);
            tc.fatalAssertTrue(fmsg.UserWrite);
        end % function
        
    end % method-TestMethodSetup
    
    methods (TestClassTeardown)
        function teardownOnce(tc)
            % Remove the chidata directory
            rmdir(tc.testDir, 's')
        end % function
    end % methods
    
    methods (Test)
        
        % Test the chidata-specific properties
        function aggTypeProp(tc)
            [~, props] = tc.testfun(tc.seriesID, tc.opts);
            tc.verifyTrue(isfield(props.dbInfo, 'AggType'));
        end % function
        
        function dataTypeProp(tc)
            [~, props] = tc.testfun(tc.seriesID, tc.opts);
            tc.verifyTrue(isfield(props.dbInfo, 'DataType'));
        end % function
        
        function frequencyProp(tc)
            [~, props] = tc.testfun(tc.seriesID, tc.opts);
            tc.verifyTrue(isfield(props.dbInfo, 'Frequency'));
        end % function
        
        function magnitudeProp(tc)
            [~, props] = tc.testfun(tc.seriesID, tc.opts);
            tc.verifyTrue(isfield(props.dbInfo, 'Magnitude'));
        end % function
        
        function sourceProp(tc)
            [~, props] = tc.testfun(tc.seriesID, tc.opts);
            tc.verifyTrue(isfield(props.dbInfo, 'Source'));
        end % function
        
        function dateTimeModProp(tc)
            [~, props] = tc.testfun(tc.seriesID, tc.opts);
            tc.verifyTrue(isfield(props.dbInfo, 'DateTimeMod'));
        end % function
        
        function usernameModProp(tc)
            [~, props] = tc.testfun(tc.seriesID, tc.opts);
            tc.verifyTrue(isfield(props.dbInfo, 'UsernameMod'));
        end % function
        
        function fileModProp(tc)
            [~, props] = tc.testfun(tc.seriesID, tc.opts);
            tc.verifyTrue(isfield(props.dbInfo, 'FileMod'));
        end % function        
    end % methods

end % classdef


