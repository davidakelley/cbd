% X13SERIES is the class definition for x13series objects.
% Such an object is the home of the input to and the output of the US
% Bureau of the Census X13ARIMA-SEATS program as applied to a single time
% series.
%
% Properties:
% - name             string             name of the series
% - filename         string             name of the files associated with
%                                       the series
% - fileloc          string             path to location of data files
% - graphicsloc      string             path to location of files for the
%                                       x13graph program; if this is an
%                                       empty string (''), the graphics
%                                       files are created in a subdirectory
%                                       of the temporary files directory;
%                                       if this property is empty ([]), no
%                                       graphics files are produced by the
%                                       .Run method.
% - flags            string             flags to be used in the x13as
%                                       run. Do not set the -g or the -m
%                                       flags here; they are taken care
%                                       of automatically. You could, for
%                                       instance, set the -r or the -n
%                                       flags to affect the .out
%                                       property, and set the -s switch to
%                                       generate the diagnostics summary
%                                       file.
% - specgiven        x13spec            specification provided when calling the
%                                       x13 function
% - spec             x13spec            specgiven is adapted by the program to
%                                       remove inconsistencies. Also, some
%                                       entries are added automatically.
%                                       obj.spec the the final specification
%                                       that is used for the estimation by
%                                       x13as.
% - isLog            boolean            True is decomposition is
%                                       multiplicative, false if additive,
%                                       empty if something else or unclear.
% - period           int                periodicity (typically 4 or 12)
% - span             string             dates spanned by variable
% - arima            string             specification of seasonal ARIMA
%                                       model
% - coef             struct             stuct with one to three elements.
%                                       obj.coef.arma contains the
%                                       coefficients, standard errors, and
%                                       t-values of the estimated ARMA
%                                       process, obj.coef.regr contains the
%                                       same for the preadjustment
%                                       regression (if present). The two
%                                       elements are Matlab tables and are
%                                       available only with R2013a or
%                                       later. obj.coef.lks contains the quality
%                                       statistics (likelihood and the like) of
%                                       the regression in a struct for easy
%                                       access.
% - regression       string             result of regression as text
%   (removed, use .table('regression')  (extracted from .out)
% - prog             string             name of executable used for the
%                                       computation
% - progloc          string             path to the x13as/x12a program
% - ishtml           boolean            false if text version of executable
%                                       is used, true if html version is
%                                       used (in that case, obj.tbl is
%                                       empty)
% - progversion      string             version and build number of the
%                                       Census program used
% - timeofrun        1x2 array          time of running of program,
%                                       duration of run 
% - con              string             console output of x13as.exe
% - msg              string             errors, warnings, and notes during
%                                       run 
% - listofitems      array              names of variables, ACF/PACF,
%                                       spectra, and text items in the
%                                       object (the items themselves are
%                                       not hard-wired, but are dynamic
%                                       properties)
% - requesteditems   array              list of items that are requested in
%                                       the specification file (with some
%                                       'save' key)
% - hitem            cells              array of handles to the dynamic
%                                       properties
% - tbl              struct             content of tables stored in the
%                                       .out property
% - version          double             version of the toolbox
%
% .spec, .prog, .progloc, .ishtml, .fileloc, .graphicsloc, .flags, and
% .timeofrun are freely accessible properties (they can be read and set
% from anywhere). The other properties are either protected or dependent,
% which means that you cannot easily set them (e.g., setting
% obj.period = 12 throws an error).
%
% Important methods:
% - disp and display    Show the content of the object (extensive and
%                       compact versions).
% - dispstring          Same as disp, but does not print to the console.
%                       Instead, the disp output is returned as a string
%                       variable.
% - plot                An overloaded method for this object class.
% - table               Returns a particular table. table(obj,'F2A')
%                       returns table F2.A. table(obj,'F2') returns all
%                       tables starting with 'F2' (i.e. F2 and F2.A to
%                       F2.I) as one string. If no argument is given, a
%                       list of all tables in the object is returned.
% - showmsg             Returns the content of the .msg property (which is
%                       a cell array) as a string.
%
% Rarely used methods: The following methods are normally not useful for
% regular users. They are used by x13.m to perform its work. Be careful if
% you employ these methods. It is possible to create unusable x13series
% objects if you don't know what you are doing.
% - additem             Used to add a general item to the object, obj =
%                       obj.additem(name,content), where name is a string with
%                       at most three letters.
% - addvariable         Adds a time series to the object. Note, however,
%                       that time series must have names with at most three
%                       characters. Syntax: obj = obj.addvariable(vname, ...
%                       dates,data,header,type), where vname is the name of
%                       the new item (at most three characters), dates is a
%                       (nx1) column vector containing datecodes, data is
%                       an (nxm) array containing the data, header is a
%                       (1xm) cell array containing the titles of the
%                       individual series (if there is only one variable,
%                       m = 1, it is a good idea to use the name of the
%                       variable as the single header), and type is an
%                       integer with this meaning: type = 1 is a time
%                       series, type = 2 is an ACF/PACF object, type = 3 is
%                       a spectrum. type = 0 would be a text objects but
%                       you should use additem to add such contents.
% - rmitem              Removes an item or a list of items (or variables) from
%                       the object.

% - PrepareFiles        Takes four arguments: dates, data, spec, and a
%                       boolean called isComposite which determines if the
%                       series is supposed to contain the composite series
%                       of a composite run (the members of a composite have
%                       isComposite set to false). It adds the items .dat
%                       and .spc to the object and prepares all the files
%                       on disk so that the x13as program can process them.
% - Run                 Runs the x13as program using the files created by
%                       PrepareFiles.
% - CollectFiles        Imports the files produced by the x13as program
%                       into the Matlab object.
% - RunFixedSeas        Runs the fixedseas function and packs the result
%                       into an x13series object.
% - clean               Removes all the information that was added by
%                       CollectFiles.
% - runX12diag          Runs the X-12 diagnostic utility on the files
%                       created with the -s flag.
% - updatemsg           Extracts all ERRORS, WARNINGS and NOTES from the
%                       .err property and places them in the .msg property.
%                       Also adds a list of variables that were requested
%                       in the specification (with some 'save' key) but
%                       that are not available (because the x13 program did
%                       not produce them, or because they were later
%                       deleted).
% - updatetables        Attempts to parse .out and puts the result into
%                       .tbl
% - ExtractSection      Returns the content of a section in the .spc
%                       property.
% - ExtractValue        Returns the value of a certain key in a certain
%                       section of the .spc property.
%
% NOTE: This file is part of the X-13 toolbox.
%
% see also guix, x13, makespec, x13spec, x13series, x13composite, 
% x13series.plot,x13composite.plot, x13series.seasbreaks,
% x13composite.seasbreaks, fixedseas, camplet, spr, InstallMissingCensusProgram
%
% Author  : Yvan Lengwiler
% Version : 1.32
%
% If you use this software for your publications, please reference it as
%   Yvan Lengwiler, 'X-13 Toolbox for Matlab, Version 1.32', Mathworks File
%   Exchange, 2017.

% History:
% 2017-03-26    Version 1.32    Support for datetime class variable for the
%                               dates. Make sure 'metadata' section is put first
%                               in .SPC file.
% 2017-02-28    Version 1.30.1  Bug in RunCamplet that prevented correct
%                               identification of multiplicative vs additive
%                               filtering.
% 2017-01-09    Version 1.30    First release featuring camplet.
% 2016-11-24    Version 1.20.1  Fixed a bug discovered by Carlos (a FEX
%                               user). The error message that is generated
%                               when the program cannot automatically
%                               download x13as.exe was crippled. In
%                               addition, a warning is now generated when
%                               the automatic download of x12diag03.exe
%                               fails.
% 2016-11-11    Version 1.20    Double precision in reading from and writing to
%                               data files. Better support for user-defined
%                               variables to be used in regression.
% 2016-09-06    Version 1.18.4  date handling for fixedseas and detrend method
%                               is now done in fixedseas.m
% 2016-09-05    Version 1.18.3  Fixed bug in fixedseas-typearg-(dates) when
%                               specifying break dates for 'detrend'. Addapted
%                               to change in fixedseas concerning multiple
%                               periods. Bugfix of .clean
% 2016-08-22    Version 1.18.2  Fixed bug in CollectFiles when importing annual
%                               data.
% 2016-08-19    Version 1.18    Better support for user-definied variables in
%                               'regression' and 'x11regression'.
% 2016-08-16    Version 1.17.6  Made .quiet propery public to be accessible to
%                               guix.
% 2016-07-27    Version 1.17.5  Added .specgiven and improved .span property.
%                               Improved table separation for regressions (added
%                               possible 'ARIMA Model: (0,0,0)' header). Added
%                               .coef.lks
% 2016-07-17    Version 1.17.3  Bug fix related to compatibility with guix.
% 2016-07-12    Version 1.17.2  Bug fix related to compatibility with guix.
% 2016-07-10    Version 1.17.1  Improved guix. Bug fix in x13series relating to
%                               fixedseas.
% 2016-07-06    Version 1.17    First release featuring guix.
% 2016-03-28    Version 1.16.2  Added series-title to .SPC, added 'eval' section
%                               to table extraction
% 2016-03-08    Version 1.16.1  Bugfix in .nobs and in .RunFixedSeas with
%                               composite.
% 2016-03-03    Version 1.16    Adapted to X-13 Version 1.1 Build 26.
% 2015-10-25    Version 1.15.2  Bugfix when dealing with a composite.
% 2015-09-07    Version 1.15.1  Improvement in RunFixedSeas: automatically
%                               chosen typearg is written to
%                               obj.spec.fixedseas.typearg for user to see
%                               if required.
% 2015-08-20    Version 1.15    Significant speed improvement. The imported
%                               time series will now be mapped to the first
%                               day of month if this is the case for the
%                               original data as well. Otherwise, they will
%                               be mapped to the last day of the month. Two
%                               new options --- 'spline' and 'polynomial'
%                               --- for fixedseas. Improvement of .arima,
%                               bugfix in .isLog.
% 2015-08-14    Version 1.14.2  Support of x13series for fixedseas's new
%                               'spline' and 'polynomial' options.
% 2015-07-28    Version 1.14.1  Bugfix in .isLog, improvement of .arima.
%                               Significant speed improvement by avoiding
%                               verLessThan in LegalVariableName function.
% 2015-07-25    Version 1.14    Improved backward compatibility. Overloaded
%                               version of seasbreaks for x13composite. New
%                               x13series.isLog property. Several smaller
%                               bugfixes and improvements.
% 2015-07-24    Version 1.13.3  Resolved some backward compatibility
%                               issues (thank you, Carlos). Among other
%                               things, using new program yqmd to ensure
%                               compatibility before R2014a. Also added
%                               .isLog property.
% 2015-07-19    Version 1.13.2  Added .coef property.
% 2015-07-07    Version 1.13    seasma removed, replaced by fixedseas.
%                               Complete integration of fixedseas into
%                               x13spec, with fore-/backcast extension
%                               before computing trend for simple seasonal
%                               adjustment. Various improvemnts to
%                               x13series.plot (including 'separate' 
%                               option). seasbreaks program to identify
%                               seasonal breaks. Better support for PICKMDL
%                               model list files. Added '-n' to list of
%                               default flags in x13. Select print requests
%                               added as default in makespec.
% 2015-06-22    Version 1.12.5  Better support for PICKMDL model list files
% 2015-06-15    Version 1.12.4  Key 'b' in section 'regression' is placed
%                               last in the .spc file
% 2015-06-01    Version 1.12.3  Added 'quiet' switch.
% 2015-05-29    Version 1.12.1  Added dependent property 'arima'
% 2015-05-21    Version 1.12    Several improvements: Ensuring backward
%                               compatibility back to 2012b (possibly
%                               farther); Added 'seasma' option to x13;
%                               Added RunsSeasma to x13series; other
%                               improvements throughout. Changed numbering
%                               of versions to be in synch with FEX's
%                               numbering.
% 2015-05-19    Version 1.6.1   Added RunSeasma.
% 2015-04-28    Version 1.6     x13as V 1.1 B 19, support for accessible
%                               version
% 2015-04-14    Version 1.5     Extended list of saveable variables (now
%                               includes variables expressed as percentage
%                               as well; also added the new Tukey spoectrum
%                               variables); small improvement in
%                               CollectFiles (now works correctly with
%                               2-character variables, not only 3-char
%                               variables); added table method
% 2015-02-06    Version 1.4     More reliable extraction of tables from the
%                               .out property
% 2015-01-25    Version 1.3     More extensive description of variables in
%                               disp; small bug fixes
% 2015-01-24    Version 1.2     Enforces precedence over graphics class
%                               (thanks to Stephen Watson); Attempts to
%                               parse tables from .out property
% 2015-01-21    Version 1.1     Collaboration with
%                               InstallMissingCensusProgram
% 2015-01-18    Version 1.09    Support for x12a and x12diag
% 2015-01-04    Version 1.05    List of types of all available sections;
%                               Dropping ListOfTables and ListOfVariables
%                               properties
% 2014-12-31    Version 1.0     First Version

%#ok<*AGROW>
%#ok<*TRYNC>

classdef ( InferiorClasses = { ...
                ?matlab.graphics.axis.Axes, ...
                ?matlab.ui.Figure}, ...
           Description = 'interaction with X-13 program', ...
           DetailedDescription = ['Object for interaction with US ', ...
              'Census Bureau X-13 program for seasonal adjustment.'] ...
          ) ...
    x13series < dynamicprops %#ok<ATUNK>

    properties(Constant)
        version = '1.32';       % version of the toolbox
    end

    properties(Dependent)
        listofitems;            % list of items in object
        period;                 % periodicity (typically 4 or 12)
        span;                   % time span of data
        nobs;                   % number of observations in data
        requesteditems;         % list of items requested for saving
        arima;                  % specification of ARIMA model
        coef;                   % results of regression and ARMA as tables
        isLog;                  % true if decomposition is multiplicative
    end
    
    properties
        spec         = cbd.private.sax13.x13spec; % x13spec object containing specification
%        spec         = [];      % x13spec object containing specification
        progversion  = '';      % version of executable
        prog         = '';      % name of executable
        progloc      = [];      % location of executable
        ishtml       = false;   % boolean, true is 'accessible version' used
        fileloc      = [];      % location of generated files
        graphicsloc  = [];      % location of generated graphics files
        flags        = '';      % list of flags passed to executable
        quiet        = false;       % boolean; do not show x13as related warnings
        timeofrun    = cell(1,2);   % time and duration of run
    end
    
    properties(SetAccess = protected, GetAccess = public)
        msg          = cell(0);     % messages generated by Census program
        tbl          = struct();    % extracted tables containg statistics and reports
        hitem        = cell(0);     % vecor of handles to items in object
        con          = '';          % console output of Census program run
        title        = '';          % name of series
        name         = '';          % name of series
        filename     = '';          % filename used for generated files
    end
    
    properties(Hidden)
        warnings     = cell(0);     % warnings issued by the toolbox (not by x13as)
        specgiven    = cbd.private.sax13.x13spec;     % spec given by user, before internally adjusted by the program
    end
    
    properties(Hidden, GetAccess = protected)
        compositePeriod;            % periodicity used if no series section is found (i.e. for the composite series)
        grmode       = false;       % boolean; true if run in graphics mode
        defaultPickmdlFile = 'pure2.pml';   % default selection of models for pickmdl
    end
    
    methods
    
    % --- CONSTRUCTOR, DESTRUCTOR -----------------------------------------
    % (none)
    
%         function delete(obj)
%             % destructor function
%             fprintf('deleting x13series object...\n');
%         end
    
    % --- GET OF DEPENDENTS -----------------------------------------------
    
        function list = get.listofitems(obj)
        % returns list of items in object
            % get all properties
            list = properties(obj);
            % drop the names of the hard-wired properties (except con)
            hardwired = {'listofitems','title','name','period','span', ...
                'nobs','arima','msg','tbl','prog','progloc','progversion', ...
                'ishtml','fileloc','graphicsloc','flags','timeofrun', ...
                'spec','filename','version','compositePeriod','grmode', ...
                'requesteditems','hitem','quiet','defaultPickmdlFile', ...
                'coef','isLog'};
            if isempty(obj.con)     % take con out if it is empty
                hardwired = [hardwired,{'con'}];
            end
            remove = ismember(list,hardwired);
            list(remove) = [];
            % defined ordering
            listX = list;
            % - filter out 2char items with 2nd char numeric -> insert '0'
            twochar = find(cellfun(@(x) length(x) == 2, listX));
            twonum = cellfun(@(x) x(2)+0>=48 && x(2)+0<=57, list(twochar));
            twochar = twochar(twonum);
            twolist = cellfun(@(x) [x(1),'0',x(2)], list(twochar), ...
                'UniformOutput',false);
            listX(twochar) = twolist;
            % - sort letters before numbers
            for x = 1:numel(listX)
                pos = listX{x}+0 < 'A';
                listX{x}(pos) = listX{x}(pos) + 'z' + 1;
            end
            % now get sorting order of 'listX' and impose it on 'list'
            [~,ord] = sort(listX);
            list = list(ord)';
        end
        
        function S = get.period(obj)
        % returns frequency of data
            try
                S = obj.spec.series.period;
            catch
                S = ExtractValue(obj,'series','period');
                if isempty(S)
                    S = obj.compositePeriod;
                else
                    S = str2double(S);
                end
                if isempty(S)
                    S = NaN;
                end
            end
        end
    
        function S = get.span(obj)
        % returns time span of data
            isComposite = false;
            try
                isComposite = ismember('composite',fieldnames(obj.spec));
            end
            try
                if ~isComposite
                    fromDate = obj.dat.dates(1);
                    toDate   = obj.dat.dates(end);
                else
                    fromDate = obj.cms.dates(1);
                    toDate   = obj.cms.dates(end);
                end
            catch
                S = '(no span)';
                return;
            end
            reg = '(?<from>\d{4}.\d{1,2})?\s*,\s*(?<to>\d{4}.\d{1,2})?';
            if obj.period <= 12
                % span covered by .dat or .cms
                fromDate = sprintf('%i.%i',cbd.private.sax13.yqmd(fromDate,'y'),cbd.private.sax13.yqmd(fromDate,'m'));
                toDate   = sprintf('%i.%i',cbd.private.sax13.yqmd(toDate,'y')  ,cbd.private.sax13.yqmd(toDate,'m'));
%                     else
%                         y = yqmd(fromDate,'y');
%                         m = obj.period * (fromDate-datenum(y,1,1)) / ...
%                             (datenum(y,12,31)-datenum(y,1,1));
%                         m = floor(m);
%                         fromDate = sprintf('%i.%i',y,m);
%                         y = yqmd(toDate,'y');
%                         m = obj.period * (toDate-datenum(y,1,1)) / ...
%                             (datenum(y,12,31)-datenum(y,1,1));
%                         m = floor(m);
%                         toDate = sprintf('%i.%i',y,m);
%                     end
%                 else
%                     fromDate = ''; toDate = '';
%                 end
                % modelspan
                try
                    if ~isComposite
                        modelspan = obj.spec.series.modelspan;
                    else
                        modelspan = obj.spec.composite.modelspan;
                    end
                catch
                    modelspan = '';
                end
                modelspan = regexp(modelspan,reg,'names');
                % span in spc
                try
                    if ~isComposite
                        spcspan = obj.spec.series.span;
                    else
                        spcspan = obj.spec.composite.span;
                    end
                catch
                    spcspan = '';
                end
                spcspan = regexp(spcspan,reg,'names');
                % select
                if numel(modelspan) > 0
                    if ~isempty(modelspan.from)
                        fromDate = modelspan.from;
                    end
                    if ~isempty(modelspan.to)
                        toDate = modelspan.to;
                    end
                end
                if numel(spcspan) > 0
                    if ~isempty(spcspan.from)
                        fromDate = spcspan.from;
                    end
                    if ~isempty(spcspan.to)
                        toDate = spcspan.to;
                    end
                end
            else
                fromDate = datestr(fromDate);
                toDate   = datestr(toDate);
            end
            % result in a string
            S = sprintf('(%s, %s)',fromDate,toDate);
        end
        
        function N = get.nobs(obj)
        % returns number of observations of data
            try
                N = numel(obj.dat.dates);
            catch
                try
                    N = numel(obj.cms.dates);
                catch
                    N = NaN;
                end
            end
        end
        
        function V = get.requesteditems(obj)
        % returns list of items requested for saving
            V = cell(0);
            sections = fieldnames(obj.spec);
            for sec = 1:numel(sections)     % parfor
                if isstruct(obj.spec.(sections{sec}))
                    keys = fieldnames(obj.spec.(sections{sec}));
                    if ismember('save',keys)
                        values = obj.spec.(sections{sec}).save;
                        values = [' ',values,' '];
                        values = strrep(values,'(','');
                        values = strrep(values,')','');
                        values_keep = [values,'make it longer'];
                        while length(values_keep) > length(values)
                            values_keep = values;
                            values = strrep(values,'  ',' ');
                        end
                        pos = find((values == ' '));
                        for p = 2:numel(pos)
                            V = [V, {values(pos(p-1)+1:pos(p)-1)}];
                        end
                    end
                end
            end
        end
        
        function M = get.arima(obj)
        % return ARIMA/SARIMA model that was estimated
            M = '';
            if ~isa(obj.spec,'cbd.private.sax13.x13spec')
                return
            end
            fn = fieldnames(obj.spec);
            if ismember('arima',fn)
                try
                    M = obj.spec.arima.model;
                end
            else
                idText = { ...
                    'Final automatic model choice : ' ...
                    'The model chosen is ', ...
                    'A default model specified by the user, ', ...
                    'None of the models were chosen.'};
                try
                    out = obj.cleanHTML(obj.out);
                catch
                    out = '';
                end
                loc = cell(1,4);
                for id = 1:4
                    loc{id} = strfind(out,idText{id});
                end
                found = find(~cellfun('isempty',loc));
                if ~isempty(found)
                    found = found(1);
                    loc = loc{found} + length(idText{found});
                    eolloc = strfind(out(loc(1):end),char(10));
                    M = out(loc(1):loc(1)+eolloc(1)-2);
                    switch found
                        case 3
                            M = ['No good model found, using default: ', ...
                                M(1:end-1)];
                        case 4
                            M = 'No good model found, no default available.';
                    end
                end
            end
        end
        
        function tbl = get.coef(obj)
        % return coefficients of regARMA as tables
            
            tbl = [];
        
            if verLessThan('matlab', '8.2')    % tables exist since R2013a
                warning('X13TBX:x13series:coef:NoTables', ...
                    ['This property is not available because ', ...
                     'your installation of Matlab does not support ', ...
                     'tables. Tables became available with Matlab 2013a.']);
                return;
            end
            
            if ~ismember('est',obj.listofitems)
                warning('X13TBX:x13series:coef:ESTnotsaved', ...
                	['You need to have the triplet ''estimate'',',...
                     '''save'',''est'' in your x13spec for this ', ...
                     'property to work.']);
                return;
            end
            
            tbl = struct;
                
            str = obj.est;
            str = strrep(str,'Leap Year','Leap-Year');
            fstr1 = '$regression:';
            fstr2 = '$arima:';
            fstr3 = '$variance:';
            locREGR = strfind(str,fstr1);
            locARMA = strfind(str,fstr2);
            locEND  = strfind(str,fstr3);

            if ~isempty(locARMA)
                str(locARMA:end) = [];
            else
                str(locEND:end)  = [];
            end
            if ~isempty(locREGR)
                str(1:locREGR) = [];
                lines = strsplit(str,'\n');
                lines(1:4) = [];    % head
                remove = cellfun('isempty',lines);
                lines(remove) = []; nlines = numel(lines);
                variable    = cell(nlines,1);
                coefficient = nan(nlines,1);
                stderr      = nan(nlines,1);
                tvalue      = nan(nlines,1);
                for l = 1:numel(lines)
                    comp = strsplit(lines{l});
                    variable{l}    = comp{end-3};
                    coefficient(l) = str2double(comp{end-2});
                    stderr(l)      = str2double(comp{end-1});
                    tvalue(l)      = coefficient(l)/stderr(l);
                end
                tbl.regr = table(coefficient,stderr,tvalue,'RowNames',variable);
            end

            str = obj.est;
            str(locEND:end) = [];
            if ~isempty(locARMA)
                str(1:locARMA) = [];
                lines = strsplit(str,'\n');
                lines(1:4) = [];    % head
                remove = cellfun('isempty',lines);
                lines(remove) = []; nlines = numel(lines);
                variable    = cell(nlines,1);
                coefficient = nan(nlines,1);
                stderr      = nan(nlines,1);
                tvalue      = nan(nlines,1);
                for l = 1:numel(lines)
                    comp = strsplit(lines{l});
                    type = '?';
                    switch [comp{1},' ',comp{2}]
                        case 'AR Nonseasonal'
                            type = 'AR';
                        case 'MA Nonseasonal'
                            type = 'MA';
                        case 'AR Seasonal'
                            type = 'SAR';
                        case 'MA Seasonal'
                            type = 'SMA';
                    end
                    if ~strcmp(type,'?')
                        lag = str2double(comp{4})/str2double(comp{3});
                        variable{l} = [type,'(',num2str(lag),')'];
                        coefficient(l) = str2double(comp{end-2});
                        stderr(l)      = str2double(comp{end-1});
                        tvalue(l)      = coefficient(l)/stderr(l);
                    end
                end
                [variable,ord] = sort(variable);
                coefficient    = coefficient(ord);
                stderr         = stderr(ord);
                tvalue         = tvalue(ord);
                tbl.arma       = table(coefficient,stderr,tvalue, ...
                    'RowNames',variable);
            end
            
            if ismember('lks',obj.listofitems)
                q = strsplit(obj.lks);
                for c = 2:2:numel(q)
                    q{c} = str2double(q{c});
                end
                tbl.lks = struct(q{1:end-1});
            end
            
        end
        
%         function R = get.regression(obj)
%             R = '';
%             try
%                 str = obj.out;
%             catch
%                 return;
%             end
%             wordFrom = 'MODEL ESTIMATION/EVALUATION';
%             wordTo   = 'DIAGNOSTIC';
%             posFrom  = strfind(str,wordFrom);
%             if isempty(posFrom)
%                 return;
%             end
%             posTo    = strfind(str(posFrom:end),wordTo);
%             if isempty(posTo)
%                 if obj.ishtml
%                     wordTo = '<h3>'; pos = 2;
%                 else
%                     wordTo = 'X-13ARIMA-SEATS'; pos = 1;
%                 end
%                 posTo = strfind(str(posFrom:end),wordTo);
%                 if numel(posTo) < pos
%                     return;
%                 end
%                 posTo = posTo(pos);
%             end
%             R = str(posFrom:posFrom+posTo-2);
%             R = obj.cleanString(R);
%             if obj.ishtml
%                 R = ['text://',R];
%             end
%         end

        function mult = get.isLog(obj)
        % returns true if logs of data was taken, false if data are used as is, and empty if some other transformation is used
            if isempty(obj.listofitems)
                mult = [];
                return;
            end
            req = obj.spec.ExtractRequests(obj.spec,'x11','mode');
            if ~isempty(req)
                if iscell(req); req = req{1}; end
                switch req
                    case 'add'
                        mult = false;
                    case 'mult'
                        mult = true;
                    otherwise
                        mult = [];
                end
            elseif ~isempty(obj.spec.ExtractRequests(obj.spec,'transform','power'))
                req = obj.spec.transform.power;
                if eval(req) == 1
                    mult = false;
                else
                    mult = [];
                end
            else
                req = obj.spec.ExtractRequests(obj.spec,'transform','function');
                if isempty(req); req = {'auto'}; end
                switch req{1}
                    case 'none'
                        mult = false;
                    case 'log'
                        mult = true;
                    case 'auto'
                        loc = strfind(obj.out, ...
                            'prefers no transformation   *****');
                        if isempty(loc)
                            loc = strfind(obj.out, ...
                                ['*****   Additive seasonal ', ...
                                 'adjustment will be performed.   ****']);
                        end
                        if ~isempty(loc)
                            mult = false;
                        else
                            loc = strfind(obj.out, ...
                                'prefers log transformation   *****');
                            if isempty(loc)
% CHECK IF THIS IDENTIFIER IS CORRECT !
                                loc = strfind(obj.out, ...
                                    ['*****   Multiplicative seasonal ', ...
                                     'adjustment will be performed.   ****']);
                            end
                            if ~isempty(loc)
                                mult = true;
                            else
                                mult = [];
                            end
                        end
                    otherwise
                        mult = [];
                end
            end
        end
                
    end     % end of gets of dependent properties
        
    % --- ADD TEXT ITEMS AND VARIABLES, REMOVE ITEMS ----------------------
    
    methods
        
        function obj = additem(obj,tname,content)
        % add a new textitem as a property
            tname = obj.LegalVariableName(tname);
            if ~ismember(tname,properties(obj))
                h = obj.addprop(tname);
                descr = obj.descrvariable(tname);
                h.Description = descr;
                obj.hitem{end+1} = h;
                obj.(tname) = content;
            else
                warning('X13TBX:x13series:additem:ItemExists', ...
                    ['Item ''%s'' already exists. Remove it first ', ...
                    'with obj.rmitem(''%s'').'], tname, tname);
            end
        end
        
        function obj = addvariable(obj,vname,dates,data,header,type,varargin)
        % add a new variable as a property
            if ~ismember(vname,properties(obj))
                % check args
                vname = obj.LegalVariableName(vname);
                [descr,pretype] = obj.descrvariable(vname);
                if ~(pretype == -99)
                    type = pretype;
                end
                if strcmp(descr,'---') && ~isempty(varargin)
                    descr = varargin{1};
                end
                h = obj.addprop(vname);
                h.Description = descr;
                obj.hitem{end+1} = h;
                assert(isnumeric(dates) || isa(dates,'datetime'), ...
                    'X13TBX:X13SERIES:WrongType', ...
                    'Dates argument must be numerical.');
                dates = dates(:);
                assert(isnumeric(data),'X13TBX:x13series:addvariable:WrongType', ...
                    'Data argument must be a numerical.');
                if ~size(data,1) == numel(dates)
                    data = data';
                end
                assert(size(data,1) == numel(dates), ...
                    'X13TBX:x13series:addvariable:DimensionMismatch', ...
                    'Number of dates is not equal to number of rows in data.');
                if ~iscell(header)
                    header = {header};
                end
                assert(size(data,2) == numel(header), ...
                    'X13TBX:x13series:addvariable:DimensionMismatch', ...
                    'Number of headers is not equal to number of columns in data.');
                % make sure dates are increasing
                [dates,ord] = sort(dates,'ascend');
                data = data(ord,:);
                % pack into struct
                s = struct('descr',descr,'type',type,'dates',dates);
                for h = 1:numel(header)
                    s.(obj.LegalVariableName(header{h})) = data(:,h);
                end
                % add item to object
                obj.(vname) = s;
            else
                warning('X13TBX:x13series:addvariable:VariableExists', ...
                    ['Variable ''%s'' already exists. Remove it first ', ...
                    'with obj.rmitem(''%s'').'], vname, vname);
            end
        end
        
        function obj = rmitem(obj,varargin)
        % remove an item that was added earlier with additem or addvariable
            dynprop = cell(1,numel(obj.hitem));
            for d = 1:numel(obj.hitem)      % parfor
                dynprop{d} = obj.hitem{d}.Name;
            end
            for v = 1:numel(varargin)
                hit = find(ismember(dynprop,varargin{v}));
                if ~isempty(hit)
                    delete(obj.hitem{hit}); % delete dynamic property
                    obj.hitem(hit) = [];    % remove handle
                    dynprop(hit) = [];      % remove name from list
                else
                    warning('X13TBX:x13series:rmitem:PropUnknown', ...
                        'Item ''%s'' does not exist.', varargin{v});
                end
            end
            obj = obj.updatemsg;
        end
        
        function obj = clean(obj)
        % remove all dynamic props except .dat and .spc; set object into defined state before calling .CollectFiles
            keephandle = cell(0);
            for d = 1:numel(obj.hitem)
                if ismember(obj.hitem{d}.Name,{'dat','spec'})
                    keephandle{end+1} = obj.hitem{d};
                else
                    delete(obj.hitem{d});
                end
            end
            obj.hitem = keephandle;
            % reset some other properties
            obj.timeofrun = cell(1,2);
            obj.con       = '';
            obj.msg       = cell(0);
            obj.tbl       = struct();
        end
    end     % end of adding and deleting items
    
    % --- DISP AND DISPLAY ------------------------------------------------
    
    methods
        
        function display(obj)
        % short form display of x13series object
            [nrow,ncol] = size(obj);
            if nrow*ncol == 1
                sline = [repmat('.',1,78),char(10)];
                str = sprintf(' X-13ARIMA-SEATS series object\n');
                allprop = obj.listofitems;
                if numel(allprop) == 0
                    str = [str, ' The object is empty.'];
                else
                    str = [str,sline];
                    str = [str, sprintf(' Name: %s\n', obj.name)];
                    txt = strrep(obj.span,'(','');
                    txt = strrep(txt,')','');
                    txt = strrep(txt,', ',' to ');
                    switch obj.period
                        case 1
                            f = 'annual data';
                        case 2
                            f = 'semi-annual data';
                        case 4
                            f = 'quarterly data';
                        case 6
                            f = 'bi-monthly data';
                        case 12
                            f = 'monthly data';
                        otherwise
                            f = ['frequency = ', int2str(obj.period)];
                    end
                    str = [str, sprintf(' Span: %s, %s\n', ...
                        txt, f)];
                    str = [str, sprintf(' Data: %i observations\n', obj.nobs)];
                    str = [str,sline];
                    % separate properties according to type
                    types = NaN(1,numel(allprop));
                    uservariable = NaN(1,numel(allprop));
                    for t = 1:numel(types)
                        [~,types(t),uservariable(t)] = ...
                            obj.descrvariable(allprop{t});
                    end
                    % list items grouped by types
                    typeList = [1,2,3,0,99];   % order of types
                    typeName = {'time series','ACF and PACF','spectra', ...
                        'text items','other items'};
                    typeNameSing = {'variable','ACF and PACF','spectrum', ...
                        'text item','other item'};
                    % show count of each type
                    for t = 1:numel(typeList)       % parfor
                        count = sum(abs(types)==typeList(t));
                        if count == 1
                            str = [str,sprintf(' contains %i %s\n', ...
                                count, typeNameSing{t})];
                        elseif count > 1
                            str = [str,sprintf(' contains %i %s\n', ...
                                count, typeName{t})];
                        end
                    end
                    count = numel(fieldnames(obj.tbl));
                    if count == 1
                        str = [str,sprintf(' contains 1 table\n')];
                    elseif count > 1
                        str = [str,sprintf(' contains %i tables\n', ...
                            numel(fieldnames(obj.tbl)))];
                    end
                    count = numel(obj.msg);
                    if count == 1
                        str = [str,sprintf(' contains 1 message\n')];
                    elseif count > 1
                        str = [str,sprintf(' contains %i messages\n', ...
                            numel(obj.msg))];
                    end
                    str = [str,sline,' Use disp(obj) to see details.'];
                end
            else
                str = sprintf(['%ix%i <a href="matlab:helpPopup x13series">', ...
                    'x13series</a> array.\n'], nrow, ncol);
            end
            disp(str);
        end
        
        function disp(obj)
        % long form display of x13series object
            if isempty(obj.listofitems);
                display(obj);
            else
                display(dispstring(obj));
            end
        end
        
        function str = dispstring(obj)
        % long form display of x13series object, return as string
            [nrow,ncol] = size(obj);
            if nrow*ncol == 1
                allprop = obj.listofitems;
                dline   = repmat('=',1,78);
                sline   = repmat('.',1,78);
                str     = dline;
                str     = [str, sprintf(' X-13ARIMA-SEATS series object\n')];
                temp    = '';
                if ~isempty(obj.progversion)
                    temp = [obj.progversion, ' '];
                end
                if ~isempty(obj.prog)
                    temp = [temp,'(',obj.prog,')'];
                end
                if ~isempty(temp)
                    str = [str, sprintf(' %s\n',temp)];
                end
                str = [str, sline];
                str = [str, sprintf('  Name : %s\n', obj.name)];
                txt = strrep(obj.span,'(','');
                txt = strrep(txt,')','');
                txt = strrep(txt,', ',' to ');
                switch obj.period
                    case 1
                        f = 'annual data';
                    case 2
                        f = 'semi-annual data';
                    case 4
                        f = 'quarterly data';
                    case 6
                        f = 'bi-monthly data';
                    case 12
                        f = 'monthly data';
                    otherwise
                        f = ['frequency = ', int2str(obj.period)];
                end
                str = [str, sprintf('  Span : %s, %s\n', ...
                    txt, f)];
                str = [str, sprintf('  Data : %i observations\n', obj.nobs)];
                txt = obj.arima;
                if ~isempty(txt)
                    str = [str, sprintf(' Model : %s\n', txt)];
                end
                % separate properties according to type
                types = NaN(1,numel(allprop));
                for t = 1:numel(types)      % parfor
                    [~,types(t)] = ...
                        obj.descrvariable(allprop{t});
                end
                % list items grouped by types
                typeList = [1,2,3,0,99];   % order of types
                typeName = {'Time Series','ACF and PACF','Spectra', ...
                    'Text Items','Other Items'};
                for t = 1:numel(typeList)
                    hit = find(abs(types) == typeList(t));
                    if ~isempty(hit)
                        str = [str, sline];
                        str = [str, sprintf(' %s\n',typeName{t})];
                        thisstr = '';
                        for f = 1:numel(hit)
                            [descr,~,user] = obj.descrvariable(allprop{hit(f)});
                            if user
                                newstr  = sprintf(' = %s      ',allprop{hit(f)});
                            else
                                newstr  = sprintf(' - %s      ',allprop{hit(f)});
                            end
                            newstr  = [newstr(1:6), ' : ', descr];
                            thisstr = [thisstr, newstr, char(10)];
                        end
                        thisstr = obj.wrapLines(thisstr,'         ');
                        str = [str, thisstr];
                    end
                end
                % footline
                if numel(fieldnames(obj.tbl)) > 0
                    str = [str,sline,sprintf(' Tables\n')];
                    str = [str, obj.listoftables];
                end
                if ~isempty(obj.timeofrun{2}) || ~isempty(obj.msg)
                    str = [str, sline];
                end
                str = [str, obj.showmsg];
                if ~isempty(obj.timeofrun{2})
                    str = [str, sprintf(' Time of run: %s (%3.1f sec)\n', ...
                        datestr(obj.timeofrun{1}), obj.timeofrun{2})];
                end
                str = [str, dline];
                str = obj.wrapLines(str);
            else
                str = sprintf(['%ix%i <a href="matlab:helpPopup x13series">', ...
                    'x13series</a> array.\n'], nrow, ncol);
                if nargout == 0
                    disp(str);
                end
            end
        end
        
    end
    
    methods (Hidden)
        
        function str = listoftables(obj)
        % show list of tables contained in object
            str = '';
            alltbl = fieldnames(obj.tbl);
            ntbl = numel(alltbl);
            lhead = max(cellfun('length',alltbl))+1;
            sline = [repmat('.',1,78),char(10)];
            if ntbl > 0
                str = '';
                for t = 1:ntbl
                    oneline = [repmat(' ',1,lhead),alltbl{t}];
                    oneline = [oneline(end-lhead+1:end), ' : '];
                    cnt = obj.tbl.(alltbl{t});
                    loc = strfind(cnt,char(10));
                    if ~isempty(loc)
                        cnt = cnt(1:loc-1);
                    end
                    cnt = cnt(1:min(length(cnt),78-3-lhead));
                    oneline = [oneline, cnt];
                    str = [str, oneline, char(10)];
                end
                str = [str, sline, sprintf([' NOTE: Use ', ...
                    'obj.table(''name'') to see content of a ', ...
                    'table, where ''name'' can be\n', ...
                    ' abbreviated.\n'])];
            end
        end
        
%         function closeFile(varargin)
%             for v = varargin
%                 try
%                     fclose(v{1});
%                 end
%             end
%         end

    end
    
    methods
        
    % --- DESCRVARIABLE ---------------------------------------------------
        
        function [descr,type,uservariable] = descrvariable(obj,v)
        % get type and short description of x13-defined items
        
            % 0 : text item
            % 1 : variable
            % 2 : ACF or PACF
            % 3 : spectrum

            t = { ...
                'sa' , 1, 'fixedseas.sa', 'seasonally adjusted series (FIXEDSEAS)'; ...
                'sf' , 1, 'fixedseas.sf', 'seasonal factors (FIXEDSEAS)'; ...
                'tr' , 1, 'fixedseas.tr', 'trend (FIXEDSEAS)'; ...
                'ir' , 1, 'fixedseas.ir', 'irregular (FIXEDSEAS)'; ...
                'si' , 1, 'fixedseas.sf+fixedseas.ir', 'SI ratios (FIXEDSEAS), si = sf+ir or si = sf*ir'; ...
                'csa', 1, 'camplet.sa', 'seasonally adjusted series (CAMPLET)'; ...
                'csf', 1, 'camplet.sf', 'seasonal factors (CAMPLET)'; ...
                'crp', 1, 'camplet', 'running parameters (CAMPLET)'; ...
                'pml', 0, 'pickmdl.pml', 'list of models for PICKMDL'; ... 
                'con', 0, 'console_output', 'console output'; ...
                'msg', 0, 'notes_and_warnings', 'notes and warnings'; ...
                'udg', 0, 'diagnostics_summary_file', ...
                            'diagnostics summary file'; ...
                'x2d', 0, 'seasonal_adjustment_diagnostics', ...
                            'seasonal adjustment diagnostics'; ...
                'spc', 0, 'spec_file', 'specification file'; ...
                'dat', 1, 'unfiltered_data', 'unfiltered data'; ...
                'log', 0, 'log_file', 'program log file'; ...
                'err', 0, 'error_file', 'program error file'; ...
                'out', 0, 'collected_output', 'program output file'; ...
                'mta', 0, 'metafile', 'metafile (for composite)'; ...
                'acf', 2, 'acf', 'residual autocorrelations'; ...
                'ac2', 2, 'acfsquared', 'squared residual autocorrelations'; ...
                'pcf', 2, 'pacf', 'residual partial autocorrelation'; ...
                'b1' , 1, 'adjcompositesrs', 'aggregated time series data, prior adjusted, with associated dates'; ...
                'cac', 1, 'calendaradjcomposite', 'aggregated time series data, adjusted for regARIMA calendar effects'; ...
                'cms', 1, 'compositesrs', 'composite time series data (for the span analyzed)'; ...
                'iaa', 1, 'indadjsatot', 'average absolute revision of the indirect seasonally adjusted series'; ...
                'iaf', 1, 'indadjustfac', 'indirect combined adjustment factors'; ...
                'i18', 1, 'indadjustmentratio', 'indirect total adjustment factors'; ...
                'iao', 1, 'indaoutlier', 'final irregular component, adjusted for additive outliers'; ...
                'ica', 1, 'indcalendar', 'final calendar factors for the indirect seasonal adjustment'; ...
                'ie8', 1, 'indcalendaradjchanges', 'indcalendaradjchanges'; ...
                'cri', 1, 'indcratio', ''; ...
                'iff', 1, 'indforcefactor', ''; ...
                'iir', 1, 'indirregular', 'indirect irregular component'; ...
                'ils', 1, 'indlevelshift', 'final indirect LS outliers'; ...
                'if1', 1, 'indmcdmovavg', 'MCD moving average of the final indirect seasonally adjusted series'; ...
                'ie3', 1, 'indmodirr', 'irregular component modified for extreme values from the indirect seasonal adjustment'; ...
                'ie1', 1, 'indmodoriginal', 'original series modified for extreme values from the indirect seasonal adjustment'; ...
                'ie2', 1, 'indmodsadj', 'seasonally adjusted series modified for extreme values from the indirect seasonal adjustment'; ...
                'i6a', 1, 'indrevsachanges', 'percent changes for indirect seasonally adjusted series with revised yearly totals'; ...
                'i6r', 1, 'indrndsachanges', 'percent changes (differences) in the indirect seasonallyadjusted series'; ...
                'iee', 1, 'indrobustsa', 'final indirect seasonally adjusted series modified for extreme values'; ...
                'rri', 1, 'indrratio', ''; ...
                'ie6', 1, 'indsachanges', 'percent changes (differences) in the indirect seasonally adjusted series'; ...
                'irn', 1, 'indsadjround', 'percent changes for rounded indirect seasonally adjusted series'; ...
                'isa', 1, 'indseasadj', 'indirect seasonally adjusted data'; ...
                'isf', 1, 'indseasonal', 'final seasonal factors for the indirect seasonal adjustment'; ...
                'isd', 1, 'indseasonaldiff', 'final seasonal difference for the indirect seasonal adjustment (only for pseudo-additive seasonal adjustment)'; ...
                'ita', 1, 'indtotaladjustment', 'total indirect adjustment factors (only produced if the original series contains values that are <= 0)'; ...
                'itn', 1, 'indtrend', 'indirect trend cycle'; ...
                'ie7', 1, 'indtrendchanges', 'percent changes (differences) in the indirect final trend component'; ...
                'id8', 1, 'indunmodsi', 'final unmodified SI-ratios (differences) for the indirect adjustment'; ...
                'ie4', 1, 'indyrtotals', 'ratio of yearly totals of the original series and the indirect seasonally adjusted series'; ...
                'ie5', 1, 'origchanges', 'percent changes (differences) in the original series'; ...
                'oac', 1, 'outlieradjcomposite', 'aggregated time series data, adjusted for outliers'; ...
                'ia3', 1, 'prioradjcomposite', 'composite series adjusted for user-defined prior adjustments applied at the component level'; ...
                'acm', 0, 'armacmatrix', 'correlation matrix of ARMA parameter estimates if used with the print argument; covariance matrix of same if used with the save argument'; ...
                'est', 0, 'estimates', 'regression and ARMA parameter estimates, with standard errors'; ...
                'itr', 0, 'iterations', 'detailed output for estimation iterations, including log-likelihood values and parameters, and counts of function evaluations and iterations'; ...
                'lks', 0, 'lkstats', 'log-likelihood at final parameter estimates and, if exact = arma is used (default option), corresponding model selection criteria (AIC, AICC, Hannan-Quinn, BIC)'; ...
                'mdl', 0, 'model', 'regression and arima specs corresponding to the model, with the estimation results used to specify initial values for the ARMA parameters'; ...
                'rcm', 0, 'regcmatrix', 'correlation matrix of regression parameter estimates if used with the print argument; covariance matrix of same if used with the save argument'; ...
                'ref', 1, 'regressioneffects', 'estimated regression effects (X''beta)'; ...
                'rsd', 1, 'residuals', 'residuals from the estimated model'; ...
                'rts', 0, 'roots', 'roots of the AR and MA operators'; ...
                'ffc', 1, 'forcefactor', ''; ...
                'e6a', 1, 'revsachanges', 'percent changes (differences) in seasonally adjusted series with revised yearly totals'; ...
                'e6r', 1, 'rndsachanges', 'percent changes (differences) in rounded seasonally adjusted series'; ...
                'rnd', 1, 'saround', 'rounded final seasonally adjusted series (if round = yes) or the rounded final seasonally adjusted series with constrained yearly totals (if type = regress or type = denton)'; ...
                'saa', 1, 'seasadjtot', 'final seasonally adjusted series with constrained yearly totals (if type = regress or type = denton)'; ...
                'bct', 1, 'backcasts', 'point backcasts on the original scale, along with upper and lower prediction interval limits'; ...
                'fct', 1, 'forecasts', 'point forecasts on the original scale, along with upper and lower prediction interval limits'; ...
                'ftr', 1, 'transformed', 'forecasts on the transformed scale, with corresponding forecast standard errors'; ...
                'btr', 1, 'transformedbcst', 'backcasts on the transformed scale, with corresponding forecast standard errors'; ...
                'fvr', 1, 'variances', ['forecast error variances on the transformed scale, showing the contributions of the error assuming the model is completely known (stochastic variance) and the error ', ...
                            'due to estimating any regression parameters (error in estimating AR and MA parameters is ignored)']; ...
                'amh', 1, 'armahistory', 'history of estimated AR and MA coefficients from the regARIMA model'; ...
                'che', 1, 'chngestimates', 'concurrent and most recent estimate of the month-to-month (or quarter-to-quarter) changes in the seasonally adjusted data'; ...
                'chr', 1, 'chngrevisions', 'percent revisions of the month-to-month differences of the adjustments'; ...
                'fce', 1, 'fcsterrors', 'revision history of the out-of-sample forecasts'; ...
                'fch', 1, 'fcsthistory', 'forecast and forecast error history'; ...
                'iae', 1, 'indsaestimates', 'concurrent and most recent estimate of the indirect seasonally adjusted data'; ...
                'iar', 1, 'indsarevisions', 'revision from concurrent to most recent estimate of the indirect seasonally adjusted series'; ...
                'lkh', 1, 'lkhdhistory', 'revision history of the likelihood statistics'; ...
                'rot', 0, 'outlierhistory', 'revision history of the outliers identified'; ...
                'sae', 1, 'saestimates', 'concurrent and revised seasonal adjustments and revisions'; ...
                'sar', 1, 'sarevisions', 'percent revisions of the concurrent seasonal adjustments'; ...
                'smh', 0, 'seatsmdlhistory', 'SEATS ARIMA model history'; ...
                'sfe', 1, 'sfestimates', 'concurrent and projected seasonal component and their percent revisions'; ...
                'sfh', 1, 'sfilterhistory', 'revision history of the Moving Seasonality Ratio'; ...
                'sfr', 1, 'sfrevisions', 'revisions of the concurrent and projected seasonal component'; ...
                'tdh', 1, 'tdhistory', 'history of estimated trading day regression coeffcientsfrom the regARIMA model'; ...
                'tce', 1, 'trendchngestimates', 'history of the month-to-month differences of the trend-cycle values'; ...
                'tcr', 1, 'trendchngrevisions', 'percent revisions of the month-to-month differences of the trend-cycle values'; ...
                'tre', 1, 'trendestimates', 'concurrent and revised Henderson trend-cycle values and revisions'; ...
                'trr', 1, 'trendrevisions', 'percent revision of the concurrent Henderson trend-cycle values'; ...
                'iac', 2, 'acf', 'sample autocorrelation function(s), with standard errors and Ljung-Box Q-statistics for each lag'; ...
                'ipc', 2, 'pacf', 'sample partial autocorrelation function(s) with standard errors for each lag'; ...
                'fts', 1, 'finaltests', 't-statistics for every time point and outlier type generated during the final outlier detection iteration'; ...
                'oit', 0, 'iterations', ['detailed results for each iteration of outlier detection including outliers detected, ', ...
                            'outliers deleted, model parameter estimates, and robust and non-robust estimates of the residual standard deviation']; ...
                'ao' , 1, 'aoutlier', 'regARIMA additive (or point) outlier factors (table A8.AO)'; ...
                'hol', 1, 'holiday', 'regARIMA holiday factors (table A7)'; ...
                'ls' , 1, 'levelshift', 'regARIMA level change outlier component'; ...
                'otl', 1, 'outlier', 'combined regARIMA outlier factors (table A8)'; ...
                'rmx', 1, 'regressionmatrix', 'values of regression variables with associated dates'; ...
                'a10', 1, 'regseasonal', 'regARIMA user-defined seasonal factors (table A10)'; ...
                'so' , 1, 'seasonaloutlier', 'regARIMA seasonal outlier factors (table A8.SO)'; ...
                'tc' , 1, 'temporarychange', 'regARIMA temporary change outlier factors (table A8.TC)'; ...
                'td' , 1, 'tradingday', 'regARIMA trading day component'; ...
                'a13', 1, 'transitory', 'regARIMA transitory component factors from user-defined regressors (table A13)'; ...
                'usr', 1, 'userdef', 'factors from user-defined regression variables (table A9)'; ...
                's16', 1, 'adjustfac', 'final combined adjustment factors (SEATS)'; ...
                's18', 1, 'adjustmentratio', 'final adjustment ratios (SEATS)'; ...
                'cyc', 1, 'cycle', 'cycle'; ...
                'dsa', 1, 'diffseasonaladj', 'differenced final seasonally adjusted series (SEATS)'; ...
                'dtr', 1, 'difftrend', 'differenced final trend (SEATS)'; ...
                's13', 1, 'irregular', 'final irregular component (SEATS)'; ...
                'ltt', 1, 'longtermtrend', 'long term trend'; ...
                'sec', 1, 'seasadjconst', 'final seasonally adjusted series with constant value added (SEATS)'; ...
                's10', 1, 'seasonal', 'final seasonal component (SEATS)'; ...
                's11', 1, 'seasonaladj', 'final seasonally adjusted series (SEATS)'; ...
                'afd', 1, 'seasonaladjfcstdecomp', 'final seasonally adjusted series forecast decomposition (SEATS)'; ...
                'sfd', 1, 'seasonalfcstdecomp', 'final seasonal component forecast decomposition (SEATS)'; ...
                'ssm', 1, 'seasonalsum', 'sum of final seasonal component (SEATS)'; ...
                'ofd', 1, 'seriesfcstdecomp', 'series forecast decomposition (SEATS)'; ...
                'sta', 1, 'totaladjustment', 'total adjustment factors (SEATS)'; ...
                's14', 1, 'transitory', 'final transitory component (SEATS)'; ...
                'yfd', 1, 'transitoryfcstdecomp', 'final transitory component forecast decomposition (SEATS)'; ...
                's12', 1, 'trend', 'final trend component (SEATS)'; ...
                'stc', 1, 'trendconst', 'final trend cycle with constant value added (SEATS)'; ...
                'tfd', 1, 'trendfcstdecomp', 'final trend component forecast decomposition (SEATS)'; ...
                'b1' , 1, 'adjoriginal', 'aggregated time series data, prior adjusted, with associated dates'; ...
                'a18', 1, 'calendaradjorig', 'original series adjusted for regARIMA calendar effects'; ...
                'a19', 1, 'outlieradjorig', 'original series adjusted for regARIMA outliers'; ...
                'mv' , 1, 'seriesmvadj', 'original series with missing values replaced by regARIMA estimates'; ...
                'mva', 1, 'missingvaladj', 'original series with missing values replaced by regARIMA estimates'; ...
                'a1' , 1, 'span', 'time series data, with associated dates (if the span argument is present, data are printed and/or saved only for the specified span)'; ...
                'chs',-1, 'chngspans', 'sliding spans of the changes in the seasonally adjusted series'; ...
                'cis',-1, 'indchngspans', 'indirect month-to-month (or quarter-to-quarter) changes from all sliding spans'; ...
                'ais',-1, 'indsaspans', 'indirect seasonally adjusted series from all sliding spans'; ...
                'sis',-1, 'indsfspans', 'indirect seasonal factors from all sliding spans'; ...
                'yis',-1, 'indychngspans', 'indirect year-to-year changes from all sliding spans'; ...
                'sas',-1, 'saspans', 'seasonally adjusted series from all sliding spans'; ...
                'sfs',-1, 'sfspans', 'sliding spans of the seasonal factors'; ...
                'tds',-1, 'tdspans', 'sliding spans of the trading day factors'; ...
                'ycs',-1, 'ychngspans', 'sliding spans of the year-to-year changes in the seasonally adjusted series'; ...
                'is0', 3, 'speccomposite', 'spectrum of first-differenced aggregate series'; ...
                'is1', 3, 'specindirr', 'spectrum of the first-differenced indirect seasonally adjusted series'; ...
                'is2', 3, 'specindsa', 'spectral plot of outlier-modified irregular series from the indirect seasonal adjustment'; ...
                'sp2', 3, 'specirr', 'spectrum of modified irregular series'; ...
                'sp0', 3, 'specorig', 'spectrum of the first-differenced original series'; ...
                'spr', 3, 'specresidual', 'spectrum of the regARIMA model residuals'; ...
                'sp1', 3, 'specsa', 'spectrum of differenced seasonally adjusted series'; ...
                'ser', 3, 'specseatsextresiduals', 'spectrum of the extended residuals (SEATS)'; ...
                's2s', 3, 'specseatsirr', 'spectrum of the irregular component (SEATS)'; ...
                's1s', 3, 'specseatssa', 'spectrum of the seasonally adjusted series (SEATS)'; ...
                'a2p', 1, 'permprior', 'permanent prior-adjustment factors, with associated dates'; ...
                'a3p', 1, 'permprioradjusted', 'prior-adjusted series using only permanent prior factors, with associated dates'; ...
                'a4p', 1, 'permprioradjustedptd', 'prior-adjusted series using only permanent prior factors and prior trading day adjustments, with associated dates'; ...
                'a2' , 1, 'prior', 'prior-adjustment factors, with associated dates'; ...
                'a3' , 1, 'prioradjusted', 'prior-adjusted series, with associated dates'; ...
                'a4d', 1, 'prioradjustedptd', 'prior-adjusted series (including prior trading day adjustments), with associated dates'; ...
                'a1c', 1, 'seriesconstant', 'original series with value from the constant argument added to the series'; ...
                'a2t', 1, 'tempprior', 'temporary prior-adjustment factors, with associated dates'; ...
                'trn', 1, 'transformed', 'final trend cycle'; ...
                'c1' , 1, 'adjoriginalc', 'modified original data, C iteration'; ...
                'd1' , 1, 'adjoriginald', 'modified original data, D iteration'; ...
                'fad', 1, 'adjustdiff', 'final adjustment differences'; ...
                'd16', 1, 'adjustfac', 'combined adjustment factors'; ...
                'e18', 1, 'adjustmentratio', 'final adjustment ratios'; ...
                'bcf', 1, 'biasfactor', 'bias correction factors'; ...
                'd18', 1, 'calendar', 'combined calendar adjustment factors'; ...
                'e8' , 1, 'calendaradjchanges', 'month-to-month differences in original series adjusted for calendar factors (A18)'; ...
                'chl', 1, 'combholiday', 'combined holiday component'; ...
                'c20', 1, 'extreme', 'final extreme value adjustment factors'; ...
                'b20', 1, 'extremeb', 'preliminary extreme value adjustment factors'; ...
                'ira', 1, 'irregularadjao', 'final irregular component adjusted for point outliers'; ...
                'd13', 1, 'irregular', 'final irregular component'; ...
                'iao', 1, 'irregularadjao', 'final irregular component, adjusted for additive outliers'; ...
                'b13', 1, 'irregularb', 'irregular component, B iteration'; ...
                'c13', 1, 'irregularc', 'irregular component, C iteration'; ...
                'c17', 1, 'irrwt', 'final weights for irregular component'; ...
                'b17', 1, 'irrwtb', 'preliminary weights for irregular component'; ...
                'f1' , 1, 'mcdmovavg', 'MCD moving average'; ...
                'e3' , 1, 'modirregular', 'modified irregular series'; ...
                'e1' , 1, 'modoriginal', 'original data modified for extremes'; ...
                'e2' , 1, 'modseasadj', 'modified seasonally adjusted series'; ...
                'c4' , 1, 'modsic4', 'modified SI ratios, C iteration'; ...
                'd4' , 1, 'modsid4', 'modified SI ratios, D iteration'; ...
                'e5' , 1, 'origchanges', 'month-to-month differences in the original series'; ...
                'd9' , 1, 'replacsi', 'final replacement values for extreme SI ratios, D iteration'; ...
                'c9' , 1, 'replacsic9', 'modified SI ratios'; ...
                'e11', 1, 'robustsa', 'seasonally adjusted series with alternative extreme value modification'; ...
                'e6' , 1, 'sachanges', 'month-to-month differences in seasonally adjusted series (D11)'; ...
                'd11', 1, 'seasadj', 'final seasonally adjusted data'; ...
                'b11', 1, 'seasadjb11', 'seasonally adjusted data, B iteration'; ...
                'b6' , 1, 'seasadjb6', 'preliminary seasonally adjusted series, B iteration'; ...
                'c11', 1, 'seasadjc11', 'seasonally adjusted data, C iteration'; ...
                'c6' , 1, 'seasadjc6', 'preliminary seasonally adjusted series, C iteration'; ...
                'sac', 1, 'seasadjconst', 'final seasonally adjusted series with constant value added'; ...
                'd6' , 1, 'seasadjd6', 'preliminary seasonally adjusted series, D iteration'; ...
                'd10', 1, 'seasonal', 'final seasonal factors'; ...
                'ars', 1, 'seasonaladjregsea', 'seasonal factors, adjusted for user-defined seasonal regARIMA component'; ...
                'b10', 1, 'seasonalb10', 'seasonal factors, B iteration'; ...
                'b5' , 1, 'seasonalb5', 'preliminary seasonal factors, B iteration'; ...
                'c10', 1, 'seasonalc10', 'seasonal factors, C iteration'; ...
                'c5' , 1, 'seasonalc5', 'preliminary seasonal factors, C iteration'; ...
                'd5' , 1, 'seasonald5', 'preliminary seasonal factors, D iteration'; ...
                'fsd', 1, 'seasonaldiff', 'final seasonal difference (only for pseudo-additive seasonal adjustment)'; ...
                'b3' , 1, 'sib3', 'preliminary unmodified SI ratios, B iteration'; ...
                'b8' , 1, 'sib8', 'unmodified SI ratios, B iteration'; ...
                'c19', 1, 'tdadjorig', 'original series adjusted by final irregular regression factors'; ...
                'b19', 1, 'tdadjorigb', 'original series adjusted by preliminary irregular regression factors'; ...
                'tad', 1, 'totaladjustment', 'total adjustment factors'; ...
                'd12', 1, 'trend', 'final trend-cycle'; ...
                'tal', 1, 'trendadjls', 'final trend cycle, adjusted for level change outliers'; ...
                'b2' , 1, 'trendb2', 'preliminary trend cycle, B iteration'; ...
                'b7' , 1, 'trendb7', 'preliminary trend cycle, B iteration'; ...
                'c2' , 1, 'trendc2', 'preliminary trend cycle, C iteration'; ...
                'c7' , 1, 'trendc7', 'preliminary trend cycle, C iteration'; ...
                'd2' , 1, 'trendd2', 'preliminary trend cycle, D iteration'; ...
                'd7' , 1, 'trendd7', 'preliminary trend cycle, D iteration'; ...
                'd8' , 1, 'unmodsi', 'final unmodified SI ratios (differences)'; ...
                'd8b', 0, 'unmodsiox', 'final unmodified SI ratios, with labels for outliers and extreme values'; ...
                'e4' , 1, 'yrtotals', 'differences of annual totals'; ...
                'e7' , 1, 'trendchanges', 'month-to-month differences in final trend cycle (D12)'; ...
                'tac', 1, 'trendconst', 'final trend cycle with constant value added'; ...
                'xca', 1, 'calendar', 'final calendar factors (trading day and holiday)'; ...
                'bxc', 1, 'calendarb', 'preliminary calendar factors'; ...
                'xcc', 1, 'combcalendar', 'final calendar factors from combined daily weights'; ...
                'bcc', 1, 'combcalendarb', 'preliminary calendar factors from combined daily weights'; ...
                'c18', 1, 'combtradingday', 'final trading day factors from combined daily weights'; ...
                'b18', 1, 'combtradingdayb', 'preliminary trading day factors from combined daily weights'; ...
                'c14', 1, 'extremeval', 'irregulars excluded from the irregular regression, C iteration'; ...
                'b14', 1, 'extremevalb', 'irregulars excluded from the irregular regression, B iteration'; ...
                'xhl', 1, 'holiday', 'final holiday factors'; ...
                'bxh', 1, 'holidayb', 'preliminary holiday factors'; ...
                'xoi', 0, 'outlieriter', ['detailed results for each iteration of outlier detection including outliers detected, outliers deleted, model parameter ', ...
                            'estimates, and robust and non-robust estimates of the residual standard deviation']; ...
                'a4' , 1, 'priortd', 'prior trading day weights and factors'; ...
                'c16', 1, 'tradingday', 'final trading day factors and weights'; ...
                'b16', 1, 'tradingdayb', 'preliminary trading day factors and weights'; ...
                'c15', 0, 'x11reg', 'final irregular regression coefficients and diagnostics'; ...
                'xrc', 1, 'xregressioncmatrix', 'covariance matrix of irregular regression parameter estimates'; ...
                'xrm', 1, 'xregressionmatrix', 'values of irregular regression variables with associated dates'; ...
                'mdc', 0, 'componentmodels', 'component models'; ...
                'fac', 0, 'filtersaconc', 'concurrent seasonal adjustment filter'; ...
                'faf', 0, 'filtersasym', 'symmetric seasonal adjustment filter'; ...
                'ftc', 0, 'filtertrendconc', 'concurrent trend filter'; ...
                'ftf', 0, 'filtertrendsym', 'symmetric trend filter'; ...
                'pic', 0, 'pseudoinnovtrend', 'pseudo innovations in trend-cycle'; ...
                'pis', 0, 'pseudoinnovseasonal', 'pseudo innovations in seasonal'; ...
                'pit', 0, 'pseudoinnovtransitory', 'pseudo innovations in transitory component'; ...
                'pia', 0, 'psuedoinnovsadj', 'pseudo innovations in seasonally adjusted series'; ...
                'gac', 0, 'squaredgainsaconc', 'squared gain of the concurrent seasonal adjustment filter'; ...
                'gaf', 0, 'squaredgainsasym', 'squared gain of the symmetric seasonal adjustment filter'; ...
                'gtc', 0, 'squaredgaintrendconc', 'squared gain of the concurrent trend filter'; ...
                'gtf', 0, 'squaredgaintrendsym', 'squared gain of the symmetric trend filter'; ...
                'tac', 0, 'timeshiftsaconc', 'final trend cycle with constant value added'; ...
                'ttc', 0, 'timeshifttrendconc', 'time shift of the concurrent trend filter'; ...
                'wkf', 0, 'wkendfilter', 'Wiener-Kolmogorov end filter'; ...
                'ipa', 1, 'indadjustfacpct', 'composite indirect combined adjustment factors in percent'; ...
                'ip8', 1, 'indcalendaradjchangespct', 'composite percent changes in original series adjusted for calendar effects'; ...
                'ipi', 1, 'indirregularpct', 'indirregularpct ipi composite indirect irregular component expressed in percent'; ...
                'ipf', 1, 'indrevsachangespct', 'composite percent changes for indirect seasonally adjusted series with forced yearly totals'; ...
                'ipr', 1, 'indrndsachangespct', 'composite percent changes for rounded indirect seasonally adjusted series'; ...
                'ip6', 1, 'indsachangespct', 'composite percent changes for indirect seasonally adjusted series'; ...
                'ips', 1, 'indseasonalpct', 'xomposite indirect seasonal component expressed in percent'; ...
                'ip7', 1, 'indtrendchangespct', 'composite percent changes for indirect trend component'; ...
                'ip5', 1, 'origchangespct', 'composite percent changes for composite series'; ...
                'p6a', 1, 'revsachangespct', 'force percent changes in seasonally adjusted series with forced yearly totals'; ...
                'p6r', 1, 'rndsachangespct', 'force percent changes in rounded seasonally adjusted series'; ...
                'psa', 1, 'adjustfacpct', 'seats combined adjustment factors in percent'; ...
                'psi', 1, 'irregularpct', 'seats final irregular component in percent'; ...
                'psc', 1, 'transitorypct', 'seats final transitory component in percent'; ...
                'pss', 1, 'seasonalpct', 'seats final seasonal factors in percent'; ...
                'paf', 1, 'adjustfacpct', 'x11 combined adjustment factors in percent'; ...
                'pe8', 1, 'calendaradjchangespct', 'x11 percent changes in original series adjusted for calendar factors'; ...
                'pir', 1, 'irregularpct', 'x11 final irregular component in percent'; ...
                'pe5', 1, 'origchangespct', 'x11 percent changes in the original series'; ...
                'pe6', 1, 'sachangespct', 'x11 percent changes in seasonally adjusted series'; ...
                'psf', 1, 'seasonalpct', 'x11 final seasonal factors in percent'; ...
                'pe7', 1, 'trendchangespct', 'x11 percent changes in final trend cycle'; ...
                'st0', 3, 'tukeyspecorig','Tukey spectral estimates of first-differenced original series'; ...
                'st1', 3, 'tukeyspecsa','Tukey spectral estimates of differenced seasonally adjusted series'; ...
                'st2', 3, 'tukeyspecirr','Tukey spectral estimates of irregular series'; ...
                't1s', 3, 'tukeyspecseatssa','Tukey spectral estimates of differenced seasonally adjusted series (SEATS)'; ...
                't2s', 3, 'tukeyspecseatsirr','Tukey spectral estimates of irregular series (SEATS)'; ...
                'ter', 3, 'tukeyspecextresiduals','Tukey spectral estimates of extended residuals'; ...
                'str', 3, 'tukeyspecresidual','Tukey spectral estimates of regARIMA model residuals'; ...
                'it0', 3, 'tukeyspeccomposite','Tukey spectral estimates of first-differenced aggregate series'; ...
                'it1', 3, 'tukeyspecindirr','Tukey spectral estimates of first-differenced indirect seasonally adjusted series'; ...
                'it2', 3, 'tukeyspecindsa','Tukey spectral estimates of outlier-modified irregular series from indirect seasonal adjustment'; ...
                'rog', 0, 'rogtable.out', 'selected statistics from the growth rate output (SEATS)'; ...
                'sum', 0, 'summarys.txt', 'summary information and diagnostics (SEATS)'; ...
                'tbs', 0, 'table-s.out','annotated listing of the series, the seasonally adjusted series, and model-based seasonal adjustment components (SEATS)'; ...
                'udv', 1, 'uservariable','user-defined variables in regression'; ...
                'udx', 1, 'uservariablex11','user-defined variables in x11regression'};

            match = ismember(t(:,1),v);

            if ~any(match)
                uservariable = true;
                try
                    descr = obj.(v).descr;
                    type  = obj.(v).type;
                catch
                    descr = '---';
                    type = -99;
                end
            else
                uservariable = false;
                type  = t{match,2};
                descr = t{match,4};
                if isempty(descr)
                    descr = t{match,3};
                end
            end

        end
            
    end
    
    % --- HIDDEN STATIC METHODS -------------------------------------------
    % --- HANDLING STRINGS ------------------------------------------------
    
    methods (Static, Hidden, Access = private)
        
        % transform date string as used by x13as into ML date code
        function d = parseDate(str,freq,firstofmonth)
            try
                parts = strsplit(str,'.');
                y = str2double(parts{1});
                m = str2double(parts{2});
                if isnan(m)
                    m = find(ismember({'jan','feb','mar','apr','may','jun', ...
                        'jul','aug','sep','oct','nov','dec'},lower(parts{2})));
                    if isempty(m)
                        error;
                    end
                else
                    m = ceil(m*12/freq);
                end
                if numel(parts) > 2
                    d = str2double(parts{3});
                else
                    if firstofmonth
                        d = 1;
                    else
                        d = eomday(y,m);
                    end
                end
                d = datenum(y,m,d);
            catch e
                err = MException('X13TBX:x13series:parseDate:ParseError', ...
                    [e.message, '\nCannot interpret ''start = %s''.\n', ...
                    'Specify the start date as ''year.month'', e.g. ''2001.Mar''.'], ...
                    str);
                throw(err);
            end
        end
        
        % ensure that the variable name is legal
        function str = LegalVariableName(str)
            if isnumeric(str)
                str = mat2str(str);
            end
            try
                str = matlab.lang.makeValidName(str);
            catch
                str = genvarname(str);
            end
        end

        % wrap string so that no line is longer than 78 character;
        % preappend a space
        function str = wrapLines(str,leadText)
            if nargin < 2
                leadText = ' ';
            end
            l = 78;
            if ~strcmp(str(end),char(10))
                str = [str,char(10)];
            end
            posLF    = [0,strfind(str,char(10)),length(str)];
            startpos = posLF(find(diff(posLF) > l)); %#ok<*FNDSB>
            while ~isempty(startpos)
                posSP = find(ismember(str(startpos(1)+1:startpos(1)+1+l),' '), ...
                    1, 'last') + startpos(1);
                if isempty(posSP)
                    % no space available; cut in the middle of a word
                    str = [str(1:startpos(1)+l), char(10), ...
                        leadText, str(startpos(1)+l+1:end)];
                else
                    % replace last available space with lf
                    str = [str(1:posSP-1), char(10), ...
                        leadText, str(posSP+1:end)];
                end
                posLF    = [1,strfind(str,char(10)),length(str)];
                startpos = posLF(find(diff(posLF) > l+1));
            end
        end
        
        % remove empty double lines etc.
        function str = cleanString(str)
            if isempty(str)
                return;
            end
            space = char(32); eol = char(10); ff = char(12);
            str_keep = [str,'not equal'];
            while ~strcmp(str_keep,str)
                str_keep = str;
                % remove end of string spaces and form feeds
                if strcmp(str(end),space); str(end) = []; end
                if strcmp(str(end),ff);    str(end) = []; end
                % remove end of line spaces
                pos = strfind(str, [space,eol]);
                str(pos) = [];
                pos = strfind(str, [space,ff]);
                str(pos) = [];
                % remove double empty lines
                pos = strfind(str, [eol,eol,eol]);
                str(pos) = [];
                % remove double form feeds
                pos = strfind(str, [ff,ff]);
                str(pos) = [];
            end
            % remove beginning and end of string empty line
            while length(str) >= 1 && strcmp(str(1),eol)
                str(1) = [];
            end
            while length(str) >= 2 && ...
                    strcmp(str(end-1:end),[eol,eol])
                str(end) = [];
            end
        end
        
        % remove HTML tags, return content in plain text
        function str = cleanHTML(str)
            loc = strfind(str,'<body>');
            if ~isempty(loc)    % it's html allright
                str = regexprep(str(loc:end),'<.*?>','');
                str = regexprep(str,['&nbsp;',char(10)],' ');
                str = regexprep(str,'&nbsp;',' ');
            end
        end
        
        % add double quotes if missing
        function str = addquotes(str)
            if ~isempty(str) && ~strcmp(str(1),'"')
                str = ['"',str,'"'];
            end
        end

        % export content of x13spec into .spc file
        function [success,ME] = writeSection(hFile,strSection,thisSpec)
            exclude = {'fixedseas','camplet'};	% these are not specs understood by x13as
            lastkey = {'b'};            % these keys will be placed last within a section
            success = true; ME = [];
            if ~ismember(strSection,exclude)
                try
                    if ~isstruct(thisSpec.(strSection))
                        fprintf(hFile, '%s{ }\n',strSection);
                    else
                        fprintf(hFile, '%s{\n',strSection);
                        thekeys = fieldnames(thisSpec.(strSection));
                        loc = ismember(thekeys,lastkey);
                        thekeys = [thekeys(~loc);thekeys(loc)];
                        for k = 1:numel(thekeys)
                            % extract value
                            thevalue = thisSpec.(strSection).(thekeys{k});
                            % numeric values need to be cast as strings
                            if isnumeric(thevalue)
                                thevalue = num2str(thevalue);
                            end
                            % add quotes around some values if missing
                            if ismember(thekeys{k},{'title','file','name'})
                                thevalue = cbd.private.sax13.x13series.addquotes(thevalue);
                            end
            %                 % special treatment for 'metadata' section
            %                 if strcmp(strSection,'metadata')
            %                     if ~iscell(thevalue)
            %                         thevalue = {thevalue};
            %                     end
            %                     if numel(thevalue) == 1
            %                         thevalue = addquotes(thevalue{1});
            %                     else
            %                         thevalue = cellfun(@(x) obj.addquotes(x), ...
            %                             thevalue, 'UniformOutput',false);
            %                         str = ['(',char(10)];
            %                         for v = 1:numel(thevalue)
            %                             str = [str, char(9),char(9), ...
            %                                 thevalue{v}, char(10)];
            %                         end
            %                         thevalue = [str,char(9),char(9),')'];
            %                     end
            %                 end
                            % this is the line that will be placed into the .spc file
                            str = sprintf('%s%s = %s',char(9),thekeys{k},thevalue);
                            % wrapping too long lines
                            while length(str) > 132
                                pos = strfind(str, ' ');
                                if ~isempty(pos)
                                    pick = find(ceil(pos/132)==1,1,'last');
                                    thisstr = str(1:pos(pick)-1);
                                else
                                    thisstr = str;
                                end
                                fprintf(hFile, '%s\n', thisstr);
                                str = str(pos(pick):end);
                            end
                            % now send it off into the file
                            fprintf(hFile, '%s\n', str);
                        end
                        fprintf(hFile, '}\n');
                    end
                catch ME
                    success = false;
                end
            end
        end

    end     % -- end hidden static methods
    
    % --- INTERACTION WITH SPC, MSG, TABLE, AND OUT -----------------------
    
    methods
    
        function obj = updatemsg(obj)
        % search through .err property and place relevant content into .msg property; also report requested but missing variables
            doNotStore = ['NOTE: The X-13ARIMA-SEATS diagnostic file ', ...
                '(.udg) has been stored'];
            S = obj.warnings;
            keyword = {'ERROR:','WARNING:','NOTE:'};
            for k = 1:3
                try
                    s = obj.ExtractParagraph('err',keyword{k});
                    for p = 1:numel(s)
                        if ~strncmp(strtrim(s{p}),doNotStore,length(doNotStore))
                            S{end+1} = obj.cleanString(s{p});
                        end
                    end
                end
            end
            p = obj.listofitems;
            r = obj.requesteditems;
            missing = ~ismember(r,p);
            if any(missing)
                if sum(missing) == 1
                    S{end+1} = sprintf([' MISSING VARIABLES: ''%s'' '...
                        'was requested but is not available.'], ...
                        r{missing});
                elseif sum(missing) == 2
                    S{end+1} = sprintf([' MISSING VARIABLES: ''%s'' '...
                        'and ''%s'' were requested but are not ', ...
                        'available.'], r{missing});
                else
                    S{end+1} = sprintf([' MISSING VARIABLES: ', ...
                        repmat('''%s'', ',1,sum(missing)-1), ...
                        'and ''%s'' were requested but are not ', ...
                        'available.'], r{missing});
                end
            end
            obj.msg = S;
            % obj.msg = unique(S);
        end
    
        function str = showmsg(obj)
        % show all messages as one string
        % msg is a list of cells; this function formats the content as one
        % string, ready to be displayed
            str = '';
            for m = 1:numel(obj.msg)
                str = [str, obj.msg{m}, char(10)];
            end
        end
        
        function obj = updatetables(obj)
        % search through .out property and extract all tables
            
            ff = char(12);
            lf = char(10);
            % eol = [char(13)]; %,char(10)];
            
            if ~ismember('out',obj.listofitems) || obj.ishtml
                return;
            end
            str = obj.out;
            
            if isempty(str)
                obj.tbl = struct();
                return;
            end
            
            % remove all page headlines
            str = [str,ff];
            p = strsplit(str,ff);
            for pp = 1:numel(p)-1
                loclf = strfind(p{pp},lf);
                p{pp} = [obj.cleanString(p{pp}(loclf(1):end)),lf];
            end
            locp = numel(p{1});
            for pp = 2:numel(p)
                locp(pp) = locp(pp-1) + numel(p{pp});
            end
            str = strjoin(p);

            % find special tables or sections
            strID = { ...
                'U. S. Department of Commerce, U. S. Census Bureau', ...
                    'HEADING'; ...
                ['X-13ARIMA-SEATS',lf,lf,'                ', ...
                    'Indirect Seasonal Adjustment of Composite Series'], ...
                    'COMPOSITE'; ...
                'Contents of spc file', 'SPC'; ...
                'ARIMA MODEL SELECTED BY regARIMA:', 'SEATS'; ...
                'PROGRAM SEATS+', 'SEATS'; ...
                'Automatic ARIMA Model Selection', 'TRAMO'; ...
                'Likelihood statistics for model fit to untransformed series.', ...
                    'TRANSFORM'; ...
                'Reading model file for automatic model selection', 'PICKMDL'; ...
                'MODEL ESTIMATION/EVALUATION','EVAL'; ...
                'DIAGNOSTIC CHECKING', 'DIAGNOSTIC'; ...
                'FORECASTING', 'FCT'; ...
                'Test for the presence of residual seasonality.','RESIDSEAS'; ...
                'Peak probabilities for Tukey spectrum estimator', 'TUKEY'; ...
                'Forward addition pass  1','OUTLIERPASS1'; ...
                'Forward addition pass  2','OUTLIERPASS2'; ...
                'Forward addition pass  3','OUTLIERPASS3'; ...
                'Forward addition pass  4','OUTLIERPASS4'};
            
            for l = 1:size(strID,1)
                loc = strfind(str,strID{l,1});
                for ll = numel(loc):-1:1
                    str = [str(1:loc(ll)-1), ff, '{', strID{l,2}, '}', ...
                        lf, str(loc(ll):end)];
                end
            end
            
            % special treatment for regression
            strID = { ...
                'ARIMA Model:  (0,0,0)', ...
                'MODEL DEFINITION', ...
                'MODEL ESTIMATION/EVALUATION', ...
                'Regression Model', ...
                'Estimation converged in'};
            loc = cell(1,5);
            for l = 1:5
                loc{l} = strfind(str,strID{l});
            end
            l = find(~cellfun('isempty',loc),1,'last');
            if ~isempty(l)
                str = [str(1:loc{l}-1), ff, '{REGRESSION}', ...
                    lf, str(loc{l}:end)];
            end
                
            % locate all the regular tables
            reg = '\n[ ]{1,3}([A-Z] [ ]?[0-9]{1,2}\.?[A-Z]{0,3}):?[ ]{1,3}([^\n]*)';
            [match,locs,loce] = regexp(str,reg,'tokens','start','end');
            
            m = [match{:}];
            m = reshape(m,2,numel(m)/2);
            if ~isempty(m)
                m(1,:) = strrep(m(1,:),' ','');
                m(1,:) = strrep(m(1,:),'.','');
            end
            
            % place and mark table names
            for l = numel(locs):-1:1
                str = [str(1:locs(l)), ff, '{', m{1,l}, '}', lf, ...
                    str(locs(l)+1:end)];
            end
            
            % separate the tables
            reg = '\f{(\S+)}';
            % get headings of tables
            [head,locs,loce] = regexp(str,reg,'tokens','start','end');
            head = [head{:}];   % remove one layer of 'celling'
            ntbl = numel(head); % # of tables
            % get contents of tables
            cnt = cell(1,ntbl);
            locs(end+1) = length(str);
            for t = 1:ntbl
                cnt{t} = obj.cleanString(str(loce(t)+1:locs(t+1)));
            end

            % some tables are there more than once; we need to distinguish
            % them
            if ~isempty(head)
                [sorthead,ord] = sort(head);
                addId = 'b'; compareTo = sorthead(1);
                for c = 2:numel(head)
                    if strcmp(compareTo,sorthead(c))
                        sorthead{c} = [sorthead{c},'_',addId];
                        addId = addId + 1;
                    else
                        compareTo = sorthead(c);
                        addId = 'b';
                    end
                end
                head(ord) = sorthead;
            end
            
            % make heads low case
            %head = cellfun(@(c) lower(c),head, 'UniformOutput',false);
            for c = 1:numel(head)
                if ischar(head{c})
                    head{c} = lower(head{c});
                end
            end
            
            % place table names and their contents into obj property
            m = [head;cnt];
            obj.tbl = struct(m{:});
            
        end
        
        function str = table(obj,varargin)
        % return all tables with a certain heading; if no arg given, return all tables
            if numel(varargin) == 0
                str = obj.listoftables;
            else
                id = varargin{1};
                try
                    fn = fieldnames(obj.tbl);
                    hit = arrayfun(@(x) strcmpi(id,fn{x}(1:min(end,length(id)))), ...
                        1:numel(fn));
                    xcontent = cellfun(@(x) [obj.tbl.(x),char(10)], fn(hit), ...
                        'UniformOutput',false);
                    xcontent{end}(end) = [];    % remove last char(10)
                    str = strjoin(xcontent');
                catch
                    str = '';
                end
            end
        end
        
        function S = ExtractSection(obj,section)
        % extract content of a section from .spc
            try
                S = obj.spc;
                if ~isempty(S)
                    % remove first line (comment)
                    pos = strfind(S,char(10));
                    S(1:pos(1)) = [];
                    pos = strfind(S,[section,'{']);
                    if ~isempty(pos)
                        try
                            S(1:pos+length(section)+1) = [];
                            pos = strfind(S,'}');
                            S(pos(1):end) = [];
                            if isempty(S)
                                S = '{ }';
                            end
                        catch
                            S = '';
                        end
                    else
                        S = '';
                    end
                end
            catch
                S = '';
            end
        end
        
        function S = ExtractValue(obj,section,key)
        % extract value of a key in a section from .spc
            S = ExtractSection(obj,section);
            if ~isempty(S)
                pos = strfind(S,[key,' =']);
                if ~isempty(pos)
                    try
                        S(1:pos+length(key)+2) = [];
                        pos = strfind(S,char(10)); S(pos(1):end) = [];
                        S = strrep(S,char(9),'');   % remove tabs
                        S = strrep(S,'"','');       % remove quotes
                        spaces = strfind(S,'  ');
                        while ~isempty(spaces)
                            S(spaces) = [];         % remove double spaces
                            spaces = strfind(S,'  ');
                        end
                    catch
                        S = '';
                    end
                else
                    S = '';
                end
            end
        end
        
        function sect = ExtractParagraph(obj,field,word)
        % extract all paragraphs from a string that contain a certain keyword
            str = obj.(field);
            % remove HTML tags in case we are using the 'accessible version'
            str = obj.cleanHTML(str);
            % find occurrences of the word
            posWord = strfind(str,word);
            sect    = cell(numel(posWord),1);
            for s = 1:numel(posWord)
                % find line feeds
                posLF   = [0,strfind(str,[char(10),char(10)]),length(str)];
                % find page feeds
                posPF   = strfind(str,char(12));
                % merge them
                posLF   = sort([posLF,posPF]);
                % now extract the paragraph
                fromPos = find(posLF<posWord(s),1,'last');
                toPos   = find(posLF>posWord(s),1,'first');
                sect{s} = obj.cleanString(str(posLF(fromPos)+1:posLF(toPos)-1));
            end

        end

    end     % --- end methods for interacting with .spc, .msg, and .tbl
    
    % --- METHODS FOR INTERACTING WITH X13AS.EXE --------------------------
    
    methods
        
        % --- PREPARE FILES
        
        function obj = PrepareFiles(obj, seriesDates, seriesData, ...
                seriesSpec, isComposite)
        % generate all files required by x13as.exe to run
            
            if nargin < 5
                isComposite = false;
            end
            
            % PREPARATIONS
            % checking input, add spec object to x13series, declare dat as
            % a variable, deal with the temporary directory
            
            % parameter checking
            assert(isa(seriesSpec,'cbd.private.sax13.x13spec'), ...
                'X13TBX:x13series:PrepareFiles:IllArg', ...
                'Spec must be an x13spec object.');
            
            % sort in case dates are not in ascending order
            [seriesDates,ord] = sort(seriesDates);
            if ~isComposite
                seriesData = seriesData(ord);
            end
            
            % determine name of series (from spec), call it 'no name' if no
            % name if present
            if ~isComposite
                try
                    str = seriesSpec.series.title;
                catch
                    try
                        str = seriesSpec.series.name;
                    catch
                        str = 'no name';
                    end
                end
            else
                try
                    str = seriesSpec.composite.title;
                catch
                    try
                        str = seriesSpec.composite.name;
                    catch
                        str = 'composite';
                    end
                end
            end
            if isnumeric(str); str = mat2str(str); end
            obj.title    = str;
            obj.name     = str;     % for backward compatibility
            obj.filename = obj.LegalVariableName(str);
            obj.filename(31:end) = [];  % filename cannot be longer than 30 chars)
            
            % add dat as a variable to the object
            if ~isComposite
                obj = obj.addvariable('dat',seriesDates,seriesData,'dat',1);
            end

            % make subdirectory in temporary folder, or in place requested
            % by the user
            if isempty(obj.fileloc)
                obj.fileloc = [tempdir,'X13\'];
            elseif ~strcmp(obj.fileloc(end),'\')
                obj.fileloc = [obj.fileloc,'\'];
            end
            if exist(obj.fileloc,'file') ~= 7
                % ... code 7 refers to directory
                mkdir(obj.fileloc);
            end
            
            obj.grmode = (ischar(obj.graphicsloc));
            % ... then make a graphics directory
            if obj.grmode
                if isempty(obj.graphicsloc)
                    % use default ...
                    obj.graphicsloc = [obj.fileloc,'graphics\'];
                elseif ~isempty(obj.graphicsloc) && ...
                        ~strcmp(obj.graphicsloc(end),'\')
                    obj.graphicsloc = [obj.graphicsloc,'\'];
                end
                if exist(obj.graphicsloc,'file') ~= 7
                    mkdir(obj.graphicsloc);
                end
            end
            
            % clean up files from previous runs
            fname = fullfile(obj.fileloc,[obj.filename,'.*']);
            delete(fname);
            
            if obj.grmode
                fname = fullfile(obj.graphicsloc,[obj.filename,'.*']);
                delete(fname);
            end

            specialfile = {'ROGTABLE.OUT','summarys.txt','TABLE-S.OUT', ...
                [obj.filename,'_rog.html'],'summarys.html', ...
                [obj.filename,'_tbs.html'],[obj.filename,'_log.html'], ...
                [obj.filename,'_err.html'],[obj.filename,'.html']};
            for f = 1:numel(specialfile)        % parfor
                fname = fullfile(obj.fileloc,specialfile{f});
                if exist(fname,'file');
                    delete(fname);
                end
            end
            
            % copy .pml file if pickmdl is used
            if ismember('pickmdl',fieldnames(seriesSpec))
                % get name of .pml file
                if isstruct(seriesSpec.pickmdl) && ...
                        ismember('file',fieldnames(seriesSpec.pickmdl))
                    fname = seriesSpec.pickmdl.file;
                else
                    fname = obj.defaultPickmdlFile;
                end
                % locate file on disk
                [loc,fname,ext] = fileparts(fname);
                fname = [fname,ext];
                if ~strcmp(loc,obj.fileloc)
                    if isempty(loc); loc = cd; end
                    if ~exist(fullfile(loc,fname),'file')                       % file not in current directory
                        loc = fileparts(mfilename('fullpath'));                 % directory of this m-file
                        loc = [loc,filesep,'..',filesep,'@x13spec',filesep];    % x13spec-subdirectory
                    end
                    % copy .pml file to fileloc
                    try
                        copyfile(fullfile(loc,fname), ...
                            fullfile(obj.fileloc,[obj.filename,'.pml']),'f');
                    catch ME
                        str = sprintf(['X13TBX Warning: Problem with file ', ...
                            '%s. Maybe it does not exist?'], fname);
                        S = obj.warnings; S{end+1} = str; obj.warnings = S;
                        warning('X13TBX:x13series:PrepareFiles:FileNotFound', ...
                            [ME.message, '\nProblem with file %s. Maybe it does not exist?\nCannot copy the file ''%s'' to ''%s'','], ...
                            fname, fullfile(loc,fname), fullfile(obj.fileloc,[obj.filename,'.pml']));
                    end
                end
                % set pickmdl.file to filename.pml
                seriesSpec = cbd.private.sax13.x13spec(seriesSpec,'pickmdl','file', ...
                    fullfile(obj.fileloc,[obj.filename,'.pml']));
            end
            
            % copy user-defined file if regression.file is specified
            if ismember('regression',fieldnames(seriesSpec))
                if isstruct(seriesSpec.regression) && ...
                        ismember('file',fieldnames(seriesSpec.regression))
                    % get name and location of user file
                    [loc,fname,ext] = fileparts(seriesSpec.regression.file);
                    fname = [fname,ext];
                    if ~strcmp(loc,obj.fileloc)
                        if isempty(loc); loc = cd; end
                        if ~exist(fullfile(loc,fname),'file')         % file not in current directory
                            loc = fileparts(mfilename('fullpath'));   % directory of this m-file
                            loc = [loc,filesep,'..',filesep];         % toolbox folder
                        end
                        % copy file to fileloc
                        try
                            copyfile(fullfile(loc,fname), ...
                                fullfile(obj.fileloc,fname),'f');
                        catch ME
                            str = sprintf(['X13TBX Warning: Problem with file ', ...
                                '%s. Maybe it does not exist?'], fname);
                            S = obj.warnings; S{end+1} = str; obj.warnings = S;
                            warning('X13TBX:x13series:PrepareFiles:FileNotFound', ...
                                [ME.message, '\nProblem with file %s. Maybe it does not exist?\nCannot copy the file ''%s'' to ''%s'','], ...
                                fname, fullfile(loc,fname), fullfile(obj.fileloc,fname));
                        end
                    end
                    % set regression.file to fileloc\fname
                    seriesSpec = cbd.private.sax13.x13spec(seriesSpec,'regression','file', ...
                        fullfile(obj.fileloc,fname));
                end
            end
            
            % DETERMINE FREQUENCY

            try         % maybe the user has specified the frequency?
                theperiod = seriesSpec.series.period;
                seriesSpec.series = rmfield(seriesSpec.series,'period');
                if isempty(fieldnames(seriesSpec.series))
                    seriesSpec = rmfield(seriesSpec,'series');
                end
            catch       % no, user has not
                diffdates = diff(seriesDates);
                if min(diffdates)     >= 28-4 && max(diffdates) <= 31+4
                    theperiod = 12;    % monthly (X-11 and SEATS)
                elseif min(diffdates) >= 90-5 && max(diffdates) <= 92+5
                    theperiod = 4;     % quarterly (X-11 and SEATS)
                elseif min(diffdates) > 180-5 && max(diffdates) < 181+5
                    theperiod = 2;     % semi-annual (SEATS only)
                elseif min(diffdates) > 59-4 && max(diffdates) < 61+4
                    theperiod = 6;     % bi-monthly (SEATS only)
                elseif min(diffdates) > 365-3 && max(diffdates) < 366+3
                    theperiod = 1;     % annual (SEATS only)
                else                   % any other frequency
                    if all(diffdates==1)
                        theperiod = 365;                    % daily
                    elseif max(diffdates) < 6 && mean(diffdates) < 1.5
                        theperiod = round((5/7)*365.25);    % work-daily
                    else
                        theperiod = round(365.25/mean(diffdates));
                        % +-10% tolerance
                        if ~(log(max(diffdates)/mean(diffdates)) < 0.10 && ...
                                log(min(diffdates)/mean(diffdates)) > -0.10)
                            err = MException('X13TBX:x13series:PrepareFiles:InconclusiveFrequency', ...
                                ['Automatic frequency detection failed. ', ...
                                'Please specify the correct frequency of ', ...
                                'the data manually with ', ...
                                'x13spec(''series'',''period'',value).']);
                            throw(err);
                        end
                    end
                end
            end
            
            dv = datevec(seriesDates);
            firstofmonth = (all(dv(:,3) == 1));

            % MAKE .USR FILE
            if ismember('regression',fieldnames(seriesSpec))
                if isstruct(seriesSpec.regression) && ...
                        ismember('user',fieldnames(seriesSpec.regression))
                    if ~ismember('data',fieldnames(seriesSpec.regression)) && ...
                            ~ismember('file',fieldnames(seriesSpec.regression))
                        % make file for x13as.exe to read
                        ucell = seriesSpec.ExtractRequests(seriesSpec,'regression','user');
                        ustr = ['[',strjoin(ucell),']'];
                        userData = evalin('base',ustr);
                        fname = fullfile(obj.fileloc, [obj.filename,'.udv']);
                        save(fname, 'userData', '-ascii', '-double');
                        % refer to file in spec
                        seriesSpec = cbd.private.sax13.x13spec(seriesSpec,'regression','file',fname);
                        % add user-defined variable to x13series object
                        if ismember('start',fieldnames(seriesSpec.regression))
                            startDate = obj.parseDate( ...
                                seriesSpec.regression.start, ...
                                theperiod,firstofmonth);
                        else
                            startDate = seriesDates(1);
                        end
                        n = size(userData,1);
                        userDates = datevec(startDate); userDates(4:end) = [];
                        userDates = repmat(userDates,n,1) + [zeros(n,1), ...
                            (12/theperiod)*(0:n-1)', zeros(n,1)];
                        userDates = datenum(userDates);
                        if ~firstofmonth
                            userDates = datevec(userDates);
                            userDates(:,3) = eomday(userDates(:,1),userDates(:,2));
                            userDates = datenum(userDates);
                        end
                        obj = obj.addvariable('udv',userDates,userData,ucell,1);
                    end
                end
            end
            
            % MAKE .USX FILE
            if ismember('x11regression',fieldnames(seriesSpec))
                if isstruct(seriesSpec.x11regression) && ...
                        ismember('user',fieldnames(seriesSpec.x11regression))
                    if ~ismember('data',fieldnames(seriesSpec.x11regression)) && ...
                            ~ismember('file',fieldnames(seriesSpec.x11regression))
                        % make file for x13as.exe to read
                        ucell = seriesSpec.ExtractRequests(seriesSpec,'x11regression','user');
                        ustr = ['[',strjoin(ucell),']'];
                        userData = evalin('base',ustr);
                        fname = fullfile(obj.fileloc, [obj.filename,'.udx']);
                        save(fname, 'userData', '-ascii', '-double');
                        % refer to file in spec
                        seriesSpec = cbd.private.sax13.x13spec(seriesSpec,'x11regression','file',fname);
                        % add user-defined variable to x13series object
                        if ismember('start',fieldnames(seriesSpec.x11regression))
                            startDate = obj.parseDate( ...
                                seriesSpec.x11regression.start, ...
                                theperiod,firstofmonth);
                        else
                            startDate = seriesDates(1);
                        end
                        n = size(userData,1);
                        userDates = datevec(startDate); userDates(4:end) = [];
                        userDates = repmat(userDates,n,1) + [zeros(n,1), ...
                            (12/theperiod)*(0:n-1)', zeros(n,1)];
                        userDates = datenum(userDates);
                        if ~firstofmonth
                            userDates = datevec(userDates);
                            userDates(:,3) = eomday(userDates(:,1),userDates(:,2));
                            userDates = datenum(userDates);
                        end
                        obj = obj.addvariable('udx',userDates,userData,ucell,1);
                    end
                end
            end
            
            if ~isComposite
            
                % MAKE .DAT FILE

                % deal with NaNs in the data
                okData = ~isnan(seriesData);
                hasNaN = any(~okData);
                okData = seriesData(okData);
                if hasNaN
                    missingval = mean(okData);
                    minval     = min(okData);
                    maxval     = max(okData);
                    if minval == 0 && maxval == 0
                        missingcode = 1;
                    elseif minval * maxval >= 0
                        missingcode = -sign(minval+maxval);
                    else    % maxval > 0 and minval < 0
                        basis       = 2;    % we want missingcode number to
                                            % be exact in the dual system
                        % missingcode will be around basis^expDistance
                        % times bigger than maxval. For the values chosen
                        % here, missingcode will be around 16 (= 2^4) times
                        % bigger than maxval.
                        expDistance = 4;
                        % missingcode is exact in the numerical system with
                        % basis 'basis' (in the dual system if basis = 2)
                        missingcode = basis^(ceil(log(maxval)/log(basis)) + ...
                            expDistance);
                        if missingcode < 1; missingcode = 1; end
                        % In practice, this number might still not be
                        % precise in the dual system because the
                        % computation of missingcode may be plagued by
                        % numerical noise. Can I do something about this?
                    end
                    seriesData(isnan(seriesData)) = missingcode;
                end

                fname = fullfile(obj.fileloc, [obj.filename,'.dat']);
                save(fname, 'seriesData', '-ascii', '-double');
                
                % MAKE .SPC FILE

                % write the 'series' section: make an x13 spec with just
                % the standard entries in the series section

                % - special entries required if there are NaNs
                if hasNaN
                    args = cell(1,21);
                    args(16:21) = { ...
                        'series', 'missingcode', missingcode, ...
                        'series', 'missingval',  missingval};
                else
                    args = cell(1,15);
                end

                % - fill up standard series entries
                args([1,4,7,10,13]) = {'series'};
                args(2) = {'start'};
                args(5) = {'modelspan'};
                if theperiod == 4          % quarterly
                    args(3) = {sprintf('%i.%i', cbd.private.sax13.yqmd(seriesDates(1),'y'), ...
                        cbd.private.sax13.yqmd(seriesDates(1),'q'))};
                    args(6) = {sprintf('(%i.%i, %i.%i)', ...
                        cbd.private.sax13.yqmd(seriesDates(1),'y'), ...
                        cbd.private.sax13.yqmd(seriesDates(1),'q'), ...
                        cbd.private.sax13.yqmd(seriesDates(end),'y'), ...
                        cbd.private.sax13.yqmd(seriesDates(end),'q'))};
                elseif theperiod == 12     % monthly
                    args(3) = {sprintf('%i.%i', cbd.private.sax13.yqmd(seriesDates(1),'y'), ...
                        cbd.private.sax13.yqmd(seriesDates(1),'m'))};
                    args(6) = {sprintf('(%i.%i, %i.%i)', ...
                        cbd.private.sax13.yqmd(seriesDates(1),'y'), cbd.private.sax13.yqmd(seriesDates(1),'m'), ...
                        cbd.private.sax13.yqmd(seriesDates(end),'y'), cbd.private.sax13.yqmd(seriesDates(end),'m'))};
                else                    % neither monthly nor quarterly
                    args(3) = {sprintf('%i.%i', cbd.private.sax13.yqmd(seriesDates(1),'y'), ...
                        floor(cbd.private.sax13.yqmd(seriesDates(1),'m')/12*theperiod))};
                    args(6) = {sprintf('(%i.%i, %i.%i)', ...
                        cbd.private.sax13.yqmd(seriesDates(1),'y'), ...
                        floor(cbd.private.sax13.yqmd(seriesDates(1),'m')/12*theperiod), ...
                        cbd.private.sax13.yqmd(seriesDates(end),'y'), ...
                        floor(cbd.private.sax13.yqmd(seriesDates(end),'m')/12*theperiod))};
                end
                args(8)  = {'period'};
                args(9)  = {theperiod};
                args(11) = {'file'};
                args(12) = {[obj.fileloc,obj.filename,'.dat']};
                d = 0;
                while any(seriesData*10^(d+1)-floor(seriesData*10^(d+1))) > 0 ...
                        && d < 5
                    d = d+1;
                end
                args(14) = {'precision'};
                args(15) = {d};
                
                % add series-print-none if series-print does not exist
                addPrintKey = ~ismember('series',fieldnames(seriesSpec));
                if ~addPrintKey
                    addPrintKey = ~ismember('print', ...
                        fieldnames(seriesSpec.series));
                end
                if addPrintKey
                    args = [args, {'series','print','none'}];
                end

                % - pack all of this into a x13spec
                minimumSpec = cbd.private.sax13.x13spec(args{:});

                % - now merge this x13spec with the one given by the user
                %   (giving user settings precedence)
                seriesSpec = cbd.private.sax13.x13spec(minimumSpec, seriesSpec, ...
                    'series','title',obj.title);
                seriesSpec = cbd.private.sax13.x13spec(minimumSpec, seriesSpec, ...
                    'series','name',obj.filename);
                
                % remove inconsistencies
                seriesSpec = seriesSpec.RemoveInconsistentSpecs;

                % put spec into the spec property of this object
                obj.spec = seriesSpec;

                % create .spc file
                fname = fullfile(obj.fileloc, [obj.filename,'.spc']);
                hFile = fopen(fname, 'w');
                if hFile == -1
                    err = MException('X13TBX:x13series:PrepareFiles:CannotCreateFile', ...
                        ['Cannot create .SPC file for some reason.\n', ...
                        'Attempted filename is %s'],fname);
                    throw(err);
                end
                try
                    fprintf(hFile, ['# specification file created on ', ...
                        '%s by X-13 toolbox for Matlab\n'],datestr(now));
                catch
                    fclose(hFile);
                    err = MException('X13TBX:x13series:PrepareFiles:CannotWriteToFile', ...
                        'Cannot write to .SPC file for some reason.');
                    throw(err);
                end

                % if it exists, write 'metadata' section out to the .spc file
                if ismember('metadata',fieldnames(seriesSpec))
                    [success,ME] = obj.writeSection(hFile,'metadata',seriesSpec);
                    if ~success
                        fclose(hFile);
                        ME = MException('X13TBX:x13series:PrepareFiles:CannotWriteToFile', ...
                            [ME.message,'\nCannot write to .SPC file for ', ...
                            'some reason.']);
                        throw(ME);
                    end
                end
                
                % write 'series' section out to the .spc file
                [success,ME] = obj.writeSection(hFile,'series',seriesSpec);
                if ~success
                    fclose(hFile);
                    ME = MException('X13TBX:x13series:PrepareFiles:CannotWriteToFile', ...
                        [ME.message,'\nCannot write to .SPC file for ', ...
                        'some reason.']);
                    throw(ME);
                end
                
                % now deal with all the other sections

                % do not write 'series' or 'metadata' section again
                sections = fieldnames(seriesSpec);
                remove = ismember(sections,{'metadata','series'});
                sections(remove) = [];
                
            else    % this is a series holding a composite 
                
                % place determined ferquency into .compositePeriod
                obj.compositePeriod = theperiod;
                
                % MAKE .SPC FILE
                
                % create .spc file
                fname = fullfile(obj.fileloc, [obj.filename,'.spc']);
                hFile = fopen(fname, 'w');
                if hFile == -1
                    fclose(hFile);
                    err = MException('X13TBX:x13series:PrepareFiles:CannotCreateFile', ...
                        ['Cannot create .SPC file for some reason.\n', ...
                        'Attempted filename is %s'],fname);
                    throw(err);
                end
                try
                    fprintf(hFile, '# composite specification file created on %s by X-13 toolbox for Matlab\n', ...
                        datestr(now));
                catch ME
                    fclose(hFile);
                    ME = MException('X13TBX:x13series:PrepareFiles:CannotWriteToFile', ...
                        [ME.message,'\nCannot write to .SPC file for ', ...
                        'some reason.']);
                    throw(ME);
                end

                % make sure the composite section is there
                seriesSpec = cbd.private.sax13.x13spec(seriesSpec, ...
                    'composite','name',obj.filename);
                
                % remove inconsistencies
                seriesSpec = seriesSpec.RemoveInconsistentSpecs;

                % put spec into the spec property of this object
                obj.spec = seriesSpec;

                % if it exists, write 'metadata' section out to the .spc file
                if ismember('metadata',fieldnames(seriesSpec))
                    [success,ME] = obj.writeSection(hFile,'metadata',seriesSpec);
                    if ~success
                        fclose(hFile);
                        ME = MException('X13TBX:x13series:PrepareFiles:CannotWriteToFile', ...
                            [ME.message,'\nCannot write to .SPC file for ', ...
                            'some reason.']);
                        throw(ME);
                    end
                end
                
                % write 'composite' section out to the .spc file
                [success,ME] = obj.writeSection(hFile,'composite',seriesSpec);
                if ~success
                    fclose(hFile);
                    ME = MException('X13TBX:x13series:PrepareFiles:CannotWriteToFile', ...
                        [ME.message,'\nCannot write to .SPC file for ', ...
                        'some reason.']);
                    throw(ME);
                end

                % now deal with all the other sections

                % - do not write 'composite' or 'metadata' section again
                sections = fieldnames(seriesSpec);
                remove = ismember(sections,{'metadata','composite'});
                sections(remove) = [];

            end
            
            % - append remaining sections to .spc file
            for s = 1:numel(sections)
                [success,ME] = obj.writeSection(hFile,sections{s},seriesSpec);
                if ~success
                    fclose(hFile);
                    ME = MException('X13TBX:x13series:PrepareFiles:CannotWriteToFile', ...
                        [ME.message,'\nCannot write to .SPC file for ', ...
                        'some reason.']);
                    throw(ME);
                end
            end

            % close .spc file
            fclose(hFile);
            
        end
        
        % --- RUN

        function obj = Run(obj)
            
        % execute the x13as.exe program on the files generated with .PrepareFiles
            
            if ~isempty(obj.progloc) && ~strcmp(obj.progloc(end),'\')
                obj.progloc = [obj.progloc,'\'];
            end
            if ~isempty(obj.fileloc) && ~strcmp(obj.fileloc(end),'\')
                obj.fileloc = [obj.fileloc,'\'];
            end
            
            if obj.grmode
                
                [~,consoleOut] = system( ...
                    sprintf('"%s%s" "%s%s" -g %s %s', ...
                    obj.progloc, obj.prog, obj.fileloc, obj.filename, ...
                    obj.graphicsloc, obj.flags));
                
            else
                
                [~,consoleOut] = system(sprintf('"%s%s" "%s%s" %s', ...
                    obj.progloc, obj.prog, obj.fileloc, obj.filename, ...
                    obj.flags));
                
            end
            
            obj.con = obj.cleanString(consoleOut);
            
        end
        
        % --- RUN X12DIAG
        
        function console = runX12diag(obj)
        % run the X-12 diagnostic utility on the files generated by x13as.exe
            try
                if obj.grmode   % .udg file is in different location
                    fname = fullfile(obj.graphicsloc,obj.filename);
                else
                    fname = fullfile(obj.fileloc,obj.filename);
                end
            catch
                fname = '';
            end
            success = true;
            if exist([fname,'.udg'],'file') == 2  % code 2 refers to files
                if exist([obj.progloc, 'x12diag03.exe'],'file') ~= 2
                    success = InstallMissingCensusProgram('x12diag');
                    if ~success
                        str = ['The program tried to download and ' ...
                            'install x12diag.exe, but failed for some ', ...
                            'reason. Try to do this manually, or remove ', ...
                            'the -s flag when calling x13.'];
                        obj.warnings{end+1} = [' TOOLBOX WARING: ',str];
                        warning('X13TBX:x13series:runX12diag:FailureToInstall', str);
                    end
                end
                if success
                    [~,console] = system(sprintf('"%s%s" "%s"', ...
                        obj.progloc, 'x12diag03.exe', fname));
                end
            else
                console = [];
            end
        end

        % --- COLLECT FILES
        
        function obj = CollectFiles(obj)
        % collect all files generated by x13as.exe and place as items into x13series object
            
            % collect version and build number
            reg = 'Version Number \d+\.?\d+ +Build \d+';
            temp = regexp(obj.con,reg,'match');
            if ~isempty(temp)
                obj.progversion = temp{1};
            end
            
            % is 'dat' first of month or end of month?
            firstofmonth = false;
            try
                if isa(obj,'x13composite')
                    dv = datevec(obj.cms.dates);
                else
                    dv = datevec(obj.dat.dates);
                end
                firstofmonth = (all(dv(:,3) == 1));
            end
            
            % create .x2d if possible
            console = runX12diag(obj);
            if ~isempty(console)
                obj.con = [obj.con,char(10),console];
            end
            
            % get list of file-extensions for this series from disk
            d = dir(fullfile(obj.fileloc,[obj.filename,'.*']));
            ext = cell(1,numel(d));
            for e = 1:numel(d)      % parfor
                [~,~,ext{e}] = fileparts(d(e).name);    % extract extension
                ext{e} = ext{e}(2:end);                 % remove '.'
            end
            
            if obj.grmode   % .udg file is in different location
                fname = fullfile(obj.graphicsloc,[obj.filename,'.udg']);
                if exist(fname,'file') == 2     % code 2 refers to files
                    ext{end+1} = 'udg';
                end
                fname = fullfile(obj.graphicsloc,[obj.filename,'.x2d']);
                if exist(fname,'file') == 2     % code 2 refers to files
                    ext{end+1} = 'x2d';
                end
            end
            
            % Do not import .dat file again. It's are already contained in
            % obj.
            % Also, do not import html (from 'accessible version'). It will
            % be imported later.
            remove = ismember(ext,{'dat','html','udv','udx',''});
            ext(remove) = [];
            
            % read all files (in different ways, depending on their type)
            for f = 1:numel(ext)
                
                % put content of file into string file first, close the
                % file, and work with the string variable only here on
                if obj.grmode && ismember(ext{f},{'udg','x2d'})
                    fname = fullfile(obj.graphicsloc,[obj.filename,'.', ...
                        ext{f}]);
                else
                    fname = fullfile(obj.fileloc,[obj.filename,'.', ...
                        ext{f}]);
                end
%                str = ''; %nlines = 0;
                hFile = fopen(fname,'r');
                % cleanup = onCleanup(@() closeFile(hFile));
                if hFile == -1
                    str = sprintf('X13TBX Warning: Cannot read the file %s', ...
                        fname);
                    S = obj.warnings; S{end+1} = str; obj.warnings = S;
                    warning('X13TBX:x13series:CollectFiles:CannotReadFile', ...
                        'Cannot read the file ''%s'' for some reason.', ...
                        fname);
                else
                    firstline = fgetl(hFile);
                    if ischar(firstline)
                        str = [firstline,char(10)];
%                        nlines = 1;
                        while ~feof(hFile)
                            str = [str,fgetl(hFile),char(10)];
%                            nlines = nlines + 1;
                        end
                    else
                        str = '';
                    end
                    fclose(hFile);
                end
                
%                 % pre-appending 'text://' to the html output (in case the
%                 % user has chosen to use the 'accessible' versions of
%                 % x13as), allows to view the html output in the browser by
%                 % saying 'web(obj.html)'.
%                 if ismember(ext{f},'html')
%                     str = (['text://',str]);
%                 end
                
                % what type is this file?
                [descr,type] = obj.descrvariable(ext{f});

                switch abs(type)

                    case 0      % text item
                        obj = additem(obj,ext{f},obj.cleanString(str));

                    case 1      % time series (-1: sliding spans)
                        try
                            pos = strfind(str,char(10));
                            headline = str(1:pos(1));
                            ncol = sum(headline == char(9)) + 1;
                            headers = textscan(headline,repmat('%s',1,ncol), ...
                                'Delimiter',char(9));
                            content = textscan(str,repmat('%f',1,ncol), ...
                                'HeaderLines',2);
                            if obj.period > 1
                                thisyears = floor(content{1}/100);
                                thismonth = floor(content{1}-100*thisyears);
                                thismonth = (thismonth-1)*(12/obj.period) ...
                                    + (12/obj.period);
                                if firstofmonth
                                    thisdays = ones(numel(thismonth),1);
                                else
                                    thisdays = eomday(thisyears,thismonth);
                                end
                            else    % annual data
                                thisyears = content{1};
                                if firstofmonth
                                    thismonth = ones(numel(thisyears,1));
                                    thisdays  = thismonth;
                                else
                                    thismonth = 12 * ones(numel(thisyears,1));
                                    thisdays  = 31 * ones(numel(thisyears,1));
                                end
                            end
                            thisdates = datenum(thisyears,thismonth, thisdays);
                            if numel(thisdates) ~= size(content{2},1)
                                err = MException('X13TBX:x13series:CollectFiles:BogusTimeSeries', ...
                                    ['This looks like a time series, but it ', ...
                                    'isn''t one. Branching out to ''CATCH''.']);
                                throw(err);
                            end
                            headers(1) = [];    % 'date' header
                            thiscontent = nan(numel(thisdates),numel(headers));
                            hdr = cell(1,numel(headers));
                            for h = 1:numel(headers)
                                hdr{h} = headers{h}{1};
                                try
                                    if length(obj.filename) > 16
                                        truncname = obj.filename(1:16);
                                    else
                                        truncname = obj.filename;
                                    end
                                    if strcmp(strtrim(hdr{h}), ...
                                            strtrim([truncname,'.',ext{f}]))
                                        hdr{h} = ext{f};
                                    end
                                end
                                hdr{h} = obj.LegalVariableName(hdr{h});
                                thiscontent(:,h) = content{h+1};
                            end
                            if type < 0     % sliding spans
                    % !!! is this correct?
                                thiscontent(thiscontent==-999) = NaN;
                            end
                            obj = addvariable(obj, ext{f}, thisdates, ...
                                thiscontent, hdr,type);
                        catch   % it's not a normal table with dates
                            message = ['Item ''%s.%s'' is supposed ', ...
                                'to be a file containing a variable, ', ...
                                'but it is not. It is imported as ', ...
                                'text instead.'];
                            str = sprintf(['X13TBX Warning: ', message], ...
                                obj.filename, ext{f});
                            S = obj.warnings; S{end+1} = str; obj.warnings = S;
                            warning('X13:X13SERIES:WrongType', ...
                                message, obj.filename, ext{f});
                            s = struct('descr', descr, ...
                                'error',['This file should be a variable, ', ...
                                'but it could not be imported properly, so ', ...
                                'it is here as a text file.'], ...
                                'content', str);
                            obj = additem(obj,ext{f},s);
                        end

                    case 2      % ACF and PACF

                        pos = strfind(str,char(10));
                        headline = str(1:pos(1));
                        headers = textscan(headline, '%s%s%s%s%s%s', ...
                            'Delimiter',char(9));
                        content = textscan(str, '%f%f%f%f%f%f', ...
                            'HeaderLines',2);
                        try
                            s = struct( ...
                                'descr'   , descr,      ...
                                'type'    , type,       ...
                                obj.LegalVariableName(headers{1}{1}), ...
                                    content{1}, ...
                                obj.LegalVariableName(headers{2}{1}), ...
                                    content{2}, ...
                                obj.LegalVariableName(headers{3}{1}), ...
                                    content{3}, ...
                                obj.LegalVariableName(headers{4}{1}), ...
                                    content{4}, ...
                                obj.LegalVariableName(headers{5}{1}), ...
                                    content{5}, ...
                                obj.LegalVariableName(headers{6}{1}), ...
                                    content{6});
                        catch
                            s = struct( ...
                                'descr'   , descr,      ...
                                'type'    , type,       ...
                                obj.LegalVariableName(headers{1}{1}), ...
                                    content{1}, ...
                                obj.LegalVariableName(headers{2}{1}), ...
                                    content{2}, ...
                                obj.LegalVariableName(headers{3}{1}), ...
                                    content{3});
                        end
                        obj = additem(obj,ext{f},s);

                    case 3      % spectra
                        content = textscan(str, '%f%f%f', ...
                            'HeaderLines',2);
                        s = struct( ...
                            'descr'    , descr,      ...
                            'type'     , type,       ...
                            'frequency', content{2}, ...
                            'amplitude', content{3});
                        obj = additem(obj,ext{f},s);

                end             % end switch type

            end
            
            % import special SEATS output, and list of models for PICKMDL
            specialfile = {'ROGTABLE.OUT','summarys.txt','TABLE-S.OUT'};
            specialext  = {'rog'         ,'sum'         ,'tbs'        };
            for f = 1:numel(specialfile)
                fname = fullfile(obj.fileloc,specialfile{f});
                if exist(fname,'file');
                    str = ''; nlines = 0;
                    hFile = fopen(fname,'r');
                    if hFile == -1
                        str = sprintf(['X13TBX Warning: Cannot read the', ...
                            'file %s for some reason,'], fname);
                        S = obj.warnings; S{end+1} = str; obj.warnings = S;
                        warning('X13TBX:x13series:CollectFiles:CannotReadFile', ...
                            'Cannot read the file ''%s'' for some reason.', ...
                            fname);
                    else
                        while ~feof(hFile)
                            str = [str,fgetl(hFile),char(10)];
                            nlines = nlines + 1;
                        end
                        fclose(hFile);
                        obj = additem(obj,specialext{f},obj.cleanString(str));
                    end
                end
            end
            
            % import HTML files from 'accessible version'
            specialfile = { ...
                [obj.filename,'_rog.html'],'summarys.html', ...
                [obj.filename,'_tbs.html'],[obj.filename,'_log.html'], ...
                [obj.filename,'_err.html'],[obj.filename,'.html']};
            specialext  = { ...
                'rog'                     ,'sum'          , ...
                'tbs'                     ,'log'          , ...
                'err'                     ,'out'          };
            for f = 1:numel(specialfile)
                fname = fullfile(obj.fileloc,specialfile{f});
                if exist(fname,'file');
                    str = 'text://'; nlines = 0;
                    hFile = fopen(fname,'r');
                    if hFile == -1
                        str = sprintf(['X13TBX Warning: Cannot read the', ...
                            'file %s for some reason,'], fname);
                        S = obj.warnings; S{end+1} = str; obj.warnings = S;
                        warning('X13TBX:x13series:CollectFiles:CannotReadFile', ...
                            'Cannot read the file ''%s'' for some reason.', ...
                            fname);
                    else
                        while ~feof(hFile)
                            str = [str,fgetl(hFile),char(10)];
                            nlines = nlines + 1;
                        end
                        fclose(hFile);
                        obj = additem(obj,specialext{f},obj.cleanString(str));
                    end
                end
            end

            % update tables
            obj = obj.updatetables();
            
            % update msg property ...
            obj = obj.updatemsg();
            % ... and show them as warnings.
            if ~obj.quiet
                for m = numel(obj.warnings)+1:numel(obj.msg)
                    % preappend LF, remove LF at the end
                    str = [char(10),strrep(obj.msg{m},'/','//')];
                    str = strrep(str,'\','/');
                    warning('X13TBX:x13series:CollectFiles:x13message',str);
                end
            end
            
            % run fixedseas if requested
            if ismember('fixedseas',fieldnames(obj.spec))
                if ismember('composite',fieldnames(obj.spec))
                    obj = RunFixedSeas(obj, obj.cms.dates, obj.cms.cms, ...
                        obj.spec);
                else
                    obj = RunFixedSeas(obj, obj.dat.dates, obj.dat.dat, ...
                        obj.spec);
                end
            end
            
            % run camplet if requested
            if ismember('camplet',fieldnames(obj.spec))
                if ismember('composite',fieldnames(obj.spec))
                    obj = RunCamplet(obj, obj.cms.dates, obj.cms.cms, ...
                        obj.spec);
                else
                    obj = RunCamplet(obj, obj.dat.dates, obj.dat.dat, ...
                        obj.spec);
                end
            end
            
        end
               
        % --- RUNFIXEDSEAS ------------------------------------------------
        
        function obj = RunFixedSeas(obj, seriesDates, seriesData, ...
                seriesSpec)
        % run fixedseas.m on the data in the x13series object
            
            % is it a composite?
            isComp = ismember('composite',fieldnames(seriesSpec));
            
            % parse the options
            fixedOptions = seriesSpec.fixedseas;
            if ~isstruct(fixedOptions)
                fixedOptions = struct;
            end
            if ~ismember('period',fieldnames(fixedOptions))
                fixedOptions.period = obj.period;
                if ~isnumeric(fixedOptions.period)
                    fixedOptions.period = str2double(fixedOptions.period);
                end
            end
            if ~ismember('type',fieldnames(fixedOptions))
                fixedOptions.type = 'ma';
            else
                legal = {'ma','moving average','epanechnikov','hp', ...
                    'detrend','spline','polynomial', ...
                    'none','additive','logarithmic','multiplicative'};
                fixedOptions.type = validatestring(fixedOptions.type,legal);
            end
            if ~ismember('typearg',fieldnames(fixedOptions))
                fixedOptions.typearg = [];
            end
            strARIMA = obj.arima; l = strfind(strARIMA,'(');
            if ~isempty(l); strARIMA = strARIMA(l:end); end
            if ~ismember('extend',fieldnames(fixedOptions))
                if ~isempty(strARIMA)
                    fixedOptions.extend = max(fixedOptions.period) * 3;
                else
                    fixedOptions.extend = 0;
                end
            end
            
%             % typearg of detrend is given as vector of dates, but
%             % fixedseas.m does not work with dates, so we need to map the
%             % dates in the typearg to the position in the sample
%             if strcmp(fixedOptions.type,'detrend') && ...
%                     ~isempty(fixedOptions.typearg)
%                 d = fixedOptions.typearg;
%                 for a = 1:numel(d);
%                     idx = find(d(a)<=seriesDates,1,'first');
%                     if isempty(idx)
%                         d(a) = NaN;
%                     else
%                         d(a) = idx;
%                     end
%                 end
%                 d(isnan(d)) = [];
%                 fixedOptions.typearg = d + fixedOptions.extend;
%             end
            
            % create a temporary spec (to compute forecasts and backcasts)
            tempSpec = cbd.private.sax13.x13spec( ...
                'forecast',  'save'   , '(bct fct)', ...
                'forecast',  'maxback', fixedOptions.extend, ...
                'forecast',  'maxlead', fixedOptions.extend, ...
                'forecast',  'print'  , 'none', ...
                'transform', 'savelog', 'atr');
            addSpecs = {'series','transform','estimate', ...
                'regression','outlier'};
            for s = 1:numel(addSpecs)
                if ismember(addSpecs{s},fieldnames(seriesSpec))
                    add = seriesSpec.(addSpecs{s});
                    add = [repmat(addSpecs(s),numel(fieldnames(add)),1), ...
                        fieldnames(add),struct2cell(add)]';
                    tempSpec = cbd.private.sax13.x13spec(tempSpec,add{:});
                end
            end
            if ~isempty(strARIMA)
                tempSpec = cbd.private.sax13.x13spec(tempSpec,'arima','model',strARIMA);
            end
            if isComp
                try
                    tempSpec = cbd.private.sax13.x13spec(tempSpec, ...
                        'series',    'save'   ,'mv', ...
                        'series',    'name'  ,[tempSpec.composite.name,'Temp']);
                catch
                    tempSpec = cbd.private.sax13.x13spec(tempSpec, ...
                        'series',    'save'   ,'mv', ...
                        'series',    'name'  ,'TempComposite');
                end
            else
                try
                    tempSpec = cbd.private.sax13.x13spec(tempSpec, ...
                        'series',   'save'  ,'mv', ...
                        'series',   'name'  ,[tempSpec.series.name,'Temp']);
                catch
                    tempSpec = cbd.private.sax13.x13spec(tempSpec, ...
                        'series',   'save'  ,'mv', ...
                        'series',   'name'  ,'Temp');
                end
            end
            
            % compute forecasts and backcasts
            if isnumeric(fixedOptions.extend)
                extend = fixedOptions.extend;
            else
                extend = str2double(fixedOptions.extend);
            end
            tempObj = x13([seriesDates,seriesData],tempSpec,'quiet','-n');
            try
                dat = tempObj.mv.mv;
            catch
                dat = tempObj.dat.dat;
            end
            try
                tempData  = [tempObj.bct.backcast; dat; ...
                    tempObj.fct.forecast];
                tempDates = [tempObj.bct.dates; seriesDates; ...
                    tempObj.fct.dates];
            catch
                tempData  = dat;
                tempDates = seriesDates;
                extend    = 0;
            end
            
            % determine transformation
            if ~ismember('transform',fieldnames(fixedOptions))
                if obj.isLog
                    fixedOptions.transform = 'log';
                else
                    fixedOptions.transform = 'none';
                end
            end
            
            % compute fixed seasonal adjustment
            s = fixedseas([tempDates,tempData], fixedOptions.period, ...
                    fixedOptions.transform, fixedOptions.type, ...
                    fixedOptions.typearg);
                
            % extract typearg if none was given by user
            if isempty(fixedOptions.typearg)
                loc = strfind(s.type,' = ');
                if ~isempty(loc)
                    fixedOptions.typearg = s.type(loc+3:end);
                end
            end
            
            % pack everything into an x13series
            np = numel(fixedOptions.period);
            obj.addvariable('sa', seriesDates, ...
                s.sa(extend+1:end-extend,:), 'sa',1);
            obj.addvariable('sf', seriesDates, ...
                s.sf(extend+1:end-extend,:), 'sf',1);
            if obj.isLog
                si = repmat(s.sf,1,np) .* s.ir;
            else
                si = repmat(s.sf,1,np) +  s.ir;
            end
            if np == 1
                obj.addvariable('tr', seriesDates, ...
                    s.tr(extend+1:end-extend,:), 'tr',1);
                obj.addvariable('ir', seriesDates, ...
                    s.ir(extend+1:end-extend,:), 'ir',1);
                obj.addvariable('si', seriesDates, ...
                    si(extend+1:end-extend,:), 'si',1);
            else
                h = cellfun(@(x) ['tr_',num2str(x)], ...
                    num2cell(fixedOptions.period), ...
                    'UniformOutput',false);
                obj.addvariable('tr', seriesDates, ...
                    s.tr(extend+1:end-extend,:), h,1);
                h = cellfun(@(x) ['ir_',num2str(x)], ...
                    num2cell(fixedOptions.period), ...
                    'UniformOutput',false);
                obj.addvariable('ir', seriesDates, ...
                    s.ir(extend+1:end-extend,:),h,1);
                h = cellfun(@(x) ['si_',num2str(x)], ...
                    num2cell(fixedOptions.period), ...
                    'UniformOutput',false);
                obj.addvariable('si', seriesDates, ...
                    si(extend+1:end-extend,:),h,1);
            end
            
            % fill in blanks in fixedseas section of the obj.spec
            obj.spec = cbd.private.sax13.x13spec(seriesSpec, ...
                'fixedseas',    'period',    fixedOptions.period, ...
                'fixedseas',    'transform', fixedOptions.transform, ...
                'fixedseas',    'type',      fixedOptions.type, ...
                'fixedseas',    'typearg',   fixedOptions.typearg, ...
                'fixedseas',    'extend',    fixedOptions.extend);
            
        end
        
        % --- RUNCAMPLET --------------------------------------------------
        
        function obj = RunCamplet(obj, seriesDates, seriesData, ...
                seriesSpec)

%             if ~isstruct(fixedOptions)
%                 fixedOptions = struct;
%             end
%             if ~ismember('period',fieldnames(fixedOptions))
%                 fixedOptions.period = obj.period;
%                 if ~isnumeric(fixedOptions.period)
%                     fixedOptions.period = str2double(fixedOptions.period);
%                 end
%             end
        
            % parse the options
            campletOptions = seriesSpec.camplet;
            args = cell(0);
            if ~isstruct(campletOptions)
                args = [args,{obj.period}];
                campletOptions = struct;
            else
                fn = fieldnames(campletOptions);
                if ~ismember('period',fn)
                    campletOptions.period = obj.period;
                    if ~isnumeric(campletOptions.period)
                        campletOptions.period = str2double(campletOptions.period);
                    end
                end
                args = [args,{campletOptions.period}];
            end
            fn = fieldnames(campletOptions);
            if ~ismember('transform',fn)
                if obj.isLog
                    args = [args,{'log'}];
                else
                    args = [args,{'none'}];
                end
            else
                args = [args, {campletOptions.transform}];
            end
            if ismember('options',fn)
                args = [args, campletOptions.options];
            end
            
            % compute camplet adjustment
            c = camplet([seriesDates,seriesData], args{:});
            
            % pack everything into an x13series
            obj.addvariable('csa',seriesDates,c.sa,'csa',1);
            obj.addvariable('csf',seriesDates,c.sf,'csf',1);
            obj.addvariable('crp',seriesDates, ...
                [c.fcst,c.err,c.relerr,c.ybar,c.g, ...
                double(c.outlier),double(c.pshift), ...
                c.currca,c.ca,c.m,c.le,c.t,c.graduator], ...
                {'fcst','err','relerr','ybar','g', ...
                'outlier','pattern_shift', ...
                'curr_ca','ca','mu','le','ti','graduator'} ,1);
            
            % fill in blanks in camplas section of the obj.spec
            options = [fieldnames(c.opt),struct2cell(c.opt)]';
            obj.spec = cbd.private.sax13.x13spec(seriesSpec, ...
                'camplet',    'period'   , c.period, ...
                'camplet',    'transform', c.transform, ...
                'camplet',    'options'  , options);
            
        end
        
    end     % --- end of methods for interacting with x13
    
end     % -- end classdef
