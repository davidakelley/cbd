classdef HaverSeries < handle
%HAVERSERIES Primitive Haver object
    % Represents a Haver series. This is the simple level data as pulled
    % directly from the Haver API or viewed in DLX with Series@db. Any
    % functions that are to be applied will be applied later through the
    % use of HaverFunction objects, interpreted by the haver function.
    
    % David Kelley, 2015
    
    properties
        seriesID
        dbID
    end
    properties(Hidden=true)
        startDate
        endDate
        data
        dataProp
    end
    
    methods
        function obj = HaverSeries(varargin)
            % Parse and assign inputs, call fetch function
            
            % Check for illegal charactars
            illegalChar = '()@,';
            for testcase = varargin
                regexOut = regexpi(testcase, illegalChar);
                assert(isscalar(regexOut) && isempty(regexOut{1}), 'haver:HaverSeries:invalidInput', 'HaverSeries takes only clean inputs.');
            end
            
            % Separate and assign series and database
            if nargin == 1
                split = strsplit(varargin{1},'@');
                ser = split{1};
                if length(split) == 2
                    db = split{2};
                else
                    error('haver:HaverSeries:invalidInput', 'Multiple @ signs in input.');
                end
            elseif nargin == 2
                ser = varargin{1};
                db = varargin{2};
            else
                error('haver:HaverSeries:invalidConstructor', 'Constructor only takes 2 input arguments');
            end
            
            assert(~isempty(ser), 'haver:HaverSeries:nullSeries', 'Series input empty');
            if isempty(db)
                db = 'USECON';
            end
            
            % Start/end dates
            if nargin > 2 && ~isempty(varargin{3})
                validateattributes(varargin{3}, {'numeric'}, {'scalar'});
                obj.startDate = varargin{3};
            else
                obj.startDate = [];
            end
            if nargin > 3 && ~isempty(varargin{4})
                validateattributes(varargin{4}, {'numeric'}, {'scalar'});
                obj.endDate = varargin{4};
            else
                obj.endDate = [];
            end
            
            % Assign and get data
            obj.seriesID = ser;
            obj.dbID = db;
            
            obj.fetch;
        end
        
        function fetch(obj)
            % Get data from Haver database
            
            % Create Connection
            try
                lisc = true;
                hav = haver(['R:\_appl\Haver\DATA\' obj.dbID '.dat']);
            catch ex
                if strcmpi(ex.identifier, 'datafeed:haver')
                    lisc = false;
                else
                    display('If license error, fix HaverSeries.fetch function!');
                    rethrow(ex);
                end
            end
            
            if ~isconnection(hav)
                error('haverpull:invalidDB', 'Invalid database name or network error.');
            end
            
            % Get the series info and data
            if lisc
                try
                    seriesInfo = info(hav, obj.seriesID);
                catch
                    error('haverpull:noPull', ['Cannot pull ' upper(obj.seriesID) ' from the ' upper(obj.dbID) ' database.']);
                end
                if isempty(obj.startDate)
                    obj.startDate = datenum(seriesInfo.StartDate);
                end
                if isempty(obj.endDate)
                    obj.endDate = datenum(seriesInfo.EndDate);
                end
                
                fetch_data = fetch(hav, obj.seriesID, datestr(obj.startDate), datestr(obj.endDate));
%             else
%                 data = cbd.private.haverpull_stata(seriesID, startDate, endDate);
%                 % Convert Stata dates to Matlab dates
%                 freq = cbd.getFreq(data(:,1));
%                 data(:,1) = cbd.endOfPer(data(:,1), freq);
            end
            
            % Transform to Table
            obj.data = array2table(fetch_data(:,2), 'VariableNames', {upper(obj.seriesID)}, 'RowNames', cellstr(datestr(fetch_data(:,1))));
            
            obj.dataProp = struct;
            obj.dataProp.ID = [obj.seriesID '@' obj.dbID];
            if lisc
                obj.dataProp.HaverInfo = seriesInfo;
            end
        end
    end
    
    
end