classdef (Sealed) haverseries < sourceseries
    %HAVERSERIES is the test suite for cbd.private.haverseries()
    %
    % USAGE
    %   >> runtests('haverseries')
    %
    % SEE ALSO: SOURCESERIES
    %
    % Santiago I. Sordo Palacios, 2019
    
    properties
        % The abstract properties from the parent class
        source      = 'haverseries';
        seriesID    = 'GDPH';
        dbID        = 'USECON';
        testfun     = @(x,y) cbd.source.haverseries(x,y);
        benchmark   = 0.31258; %v1.2.0
    end % properties
    
    properties (Constant)
        % The constant properties for the haverseries tests
        haverPath       = 'R:\_appl\Haver\DATA\'; % Path to the Haver files
        haverExt        = '.dat';                 % Extension of Haver data
        otherSeriesID   = 'FRBCNAIM';   % A second seriesID to pull
        otherdbID       = 'SURVEYS';    % A second datavase to test
    end % properties
    
    methods (TestClassSetup)
        
        function haverOpts(tc)
            % Set the haverseries-specific opts
            tc.opts.dbID = tc.dbID;
        end % function
        
        function checkHaverPath(tc)
            % Check the path to the Haver data
            [~, fmsg] = fileattrib(tc.haverPath);
            foundDrive = ~ischar(fmsg);
            tc.fatalAssertTrue(foundDrive);
            tc.fatalAssertTrue(fmsg.directory);
        end % function
        
        function checkHaverConn(tc)
            % Check access and connection to tc.dbID
            thisFile = fullfile(tc.haverPath, ...
                [tc.dbID tc.haverExt]);
            [~, fmsg] = fileattrib(thisFile);
            foundFile = ~ischar(fmsg);
            tc.fatalAssertTrue(foundFile);
            tc.fatalAssertTrue(fmsg.UserRead);
            thisDB = ishaver(thisFile);
            tc.fatalAssertEqual(thisDB, thisFile);
        end % function
        
    end % methods
    
    methods (Test)
        
        function otherDB(tc)
            % Test a pull to tc.otherdbID
            tc.seriesID = tc.otherSeriesID;
            tc.opts.dbID = tc.otherdbID;
            [data, prop] = tc.testfun(tc.seriesID, tc.opts);
            tc.verifyGreaterThan(size(data, 1), 100);
            tc.verifyEqual(size(data, 2), 1);
            actualdbID = erase(prop.ID, [tc.seriesID '@']);
            tc.verifyEqual(actualdbID, tc.opts.dbID);
        end % function
        
        function allDB(tc)
            % Attempt to establish haver() to all db's in haverPath
            haverFileList = cellstr(ls(tc.haverPath));
            idx = contains(lower(haverFileList), lower(tc.haverExt));
            datFileList = haverFileList(idx);
            nDat = length(datFileList);
            for iDat = 1:nDat
                thisFile = fullfile(tc.haverPath, datFileList{iDat});
                thisConn = ishaver(thisFile);
                tc.verifyEqual(thisConn, thisFile);
            end % for-iDat
        end % function
        
    end % methods
    
end % classdef

function dbname = ishaver(fname)
%ISHAVER checks the connection to a haver database
%
% INPUTS:
%   fname   ~ char, the name of the attempted database
% OUTPUTS:
%   dbname  ~ char, the name of the resulting database
%           empty if the haver() call fails

try
    c = haver(fname);
    assert(isequal(isconnection(c), 1));
    dbname = c.DatabaseName;
catch
    dbname = '';
end % try-catch

end % function
