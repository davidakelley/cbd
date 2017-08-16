% X13SPEC is the class definition for x13spec objects. Such an object is
% used to set all specifications of a run of the X13-ARIMA-SEATS program.
%
% Usage:
%   Specifications are entered as triples: section-key-value.
%   spec  = x13spec(section,key,value, section,key,value, ...);
%   spec2 = x13spec(spec1, section,key,value, section,key,value, ...);
%   spec3 = x13spec(spec1, section,key,value, spec2, section,key,value, ...);
%
% Remark 1: simple section-key-value syntax -------------------------------
% spec = x13spec('series','name','rainfall','transform','function','auto')
% would set name = rainfall in the series-section series, and function = 
% auto in the transform section. When using this with x13.m, this creates
% the following .spc file on the harddrive:
%   series{
%       name = rainfall
%   }
%   transform{
%       function = auto
%   }
% which is then used by the x13as.exe program.
%
% Remark 2: merging existing specs ----------------------------------------
% If existing x13spec objects are entered as arguments (second and third
% usage form above), the specifications are merged, from left to right,
% i.e. later section-key-value pairs or settings in later specs overwrite
% earlier ones.
% Example:
%   spec1 = x13spec('series','name','rainfall','x11','save','d10');
%   spec2 = x13spec(spec1,'series','name','snowfall');
% then spec2 contains save = d10 in the x11-section (inherited from spec1),
% but name = snowfall in the series-section (the name rainfall was
% overwritten).
%
% Remark 3: accumulating keys ---------------------------------------------
% The keys 'save', 'savelog', 'print', 'variables', 'aictest', 'types',
% 'user', and 'usertype' behave differently. These keys are accumulated,
%   spec = x13('x11','save','d10');
%   spec = x13(spec,'x11','save','d11');
% This does not overwrite the 'd10' value. Instead, 'd11' is added to the
% list of variables that ought to be saved, and spec contains
% save = (d10 d11) in the x11-section. To remove an item from one of these
% special keys, use the RemoveRequests function . There are also
% ExtractRequests, AddRequests, and SaveRequests methods.
%
% Remark 4: entering empty sections ---------------------------------------
% An empty section can be added by specifying an empty cell for the key,
% e.g. spec = x13spec('x11',{},{}) produces the entry
%   x11{ }
% in the .spc file.
%
% Remark 5: removing sections or keys from a spec -------------------------
% To remove a section completely, use an empty set in place of the key,
% i.e., if spec has a 'x11' section, then spec = x13spec(spec,'x11',[],[])
% removes the x11 section completely from this spec.
%
% To remove a key from a section, use an empty set as value, as follows:
% spec = x13('x11','save','d10','x11','savelog','q') produces
%   x11{
%       save = d10
%       savelog = q
%   }
% Then spec = x13(spec,'x11','save',[]) removes the 'save' key and produces
%   x11{
%       savelog = q
%   }
% spec = x13(spec,'x11','save',{}), on the other hand, leaves the value of
% x11-save unchanged.
%
% Remark 6: user-defined variable -----------------------------------------
% The 'regression' and 'x11regression' sections allow the user to specify
% exogenous variables in the regressions that are not built in (like Easter
% or TD or AO2003.Jan). The names of such variables are added with the
% 'user' key, the type of the variables is specified with the 'usertype'
% key, and the exogenous variables themeselves are provided either with the
% 'data' key (in which case the data are part of the spec), or they are
% defined in an extra file and then the name of the file is specified with
% the 'file' key. You can use 'user', 'usertype', and 'data' in this
% fashion with x13spec. You could also use the 'file' key, but in that case
% you would have to make sure that your variables are stored as a table in
% plain ascii text in a file and then provide the path to this file in the
% spec. All of this is rather cumbersome.
%
% For this reason, x13spec provides a more convenient way. Suppose your
% exogenous variable is called 'strike' and is in your Matlab workspace.
% You can then simply say
% spec = x13spec(..., 'regression','user','strike', ...);
% The program will then create a file filename.udv containing the strike
% data in a form that is readable by the x13as program, and also adds the
% correct entries to the spec-file.
%
% If you have more than one user-definied exogenous variable, use this
% syntax,
% spec = x13spec(..., 'regression','user','(strike oilprice)', ...);
%
% Remark 7: error checking ------------------------------------------------
% x13spec allows you to set only sections that are known to the x13as
% program, and keys fitting to the respective sections. It does not check,
% however, if the values you assign are legal. If you assign illegal
% values you are likely to throw a runtime error by x13as.exe.
%
% For an explanation of all available options and settings, consult the
% documentation of the x13as program provided by the US Census Bureau.
%
% Remark 8: short vs long names of saveable variables ---------------------
% CAUTION: USE ONLY THE THREE-LETTER CODES FOR THE 'SAVE' KEY.
% The x13as program uses a long name and a short three-letter name for
% variables or tables (e.g. 'save = levelshift' in the .spc file is
% equivalent to 'save = ls'). For the 'save' key, the Matlab X-13 toolbox
% recognizes ONLY the short three-letter versions of these variable names,
%   x13spec('regression','save','ls')
% Using the long name,
%   x13spec('regression','save','levelshift')
% may cause problems and is not advised.
%
% Remark 9: pickmdl file lists --------------------------------------------
% If the X-11 'pickmdl' method is used to select the regARIMA  model, a
% list of models to choose from should be supplied. You can create such a
% model list file yourself, or use one of the files provided for you by the
% toolbox. The selection of these ready-to-use model files includes:
% - StatisticsCanada.pml    The default of Statistics Canada, contains
%                           5 models.
% - Hussain-McLaren-Stuttard.pml   5 models proposed by these authors.
% - ONS.pml                 Default of the Office of National Statistics,
%                           United Kingdom. 8 models. It's the union of
%                           Hussain-McLaren-Stuttard and StatisticsCanada.
% - pure2.pml               All ARIMA models (p d q)(P D Q) with p and q
%                           between 0 and 2, P and Q also between 0 and 2,
%                           d either 0 or 1, and D always equal to 1. Does
%                           not include mixed models (50 models).
% - pure3.pml               Same as pure2 but with p and q varying from 0
%                           to 3 (70 models).
% - pure4.pml and pure5.pml    Analogue (90 and 110 models, respectively).
% - st-pure2.pml and st-pure3.pml	Same as pure2 and pure3, respectively,
%                           but containing only stationary models (d = 0).
% - int-pure2.pml and int-pure3.pml	Same as pure2 and pure3, respectively,
%                           but containing only integrated models (d = 1).
% - mixed2.pml and mixed3.pml  Same as pure2 and pure3, respectively, but
%                           including mixed models (162 models and
%                           288 models, respectively).
% - ARIMA.pml               ARIMA models with no seasonal ARIMA part; all
%                           models from (0 0 0) to (3 1 3).
% To use one of these files, include the section-key-value triple
% 'pickmdl','file','ONS.pml' (as an example) in your x13spec command.
%
% You can also use your own model definition files. Your file must have
% the .pml extension and must be in the current directory, or you must
% provide the full path.
%
% If the pickmdl section is set but no file name is provided by the user,
% the toolbox will use pure2.pml.
%
% Remark 10: the fixedseas and camplet sections --------------------------------
% x13spec also accommodates two sections that have no meaning for the x13as
% program. This sections are 'fixedseas' and 'camplet'. The contents of these
% sections are not transmitted to x13as. Instead, they are passed to separate
% Matlab programs (fixedseas.m and camplet.m). Specifying the 'fixedseas' and/or
% the 'camplet' section together with the 'x11' or the 'seats' section allows
% you to perform two/three seasonal adjustments at the same time.
% 
% fixedseas computes a trend and seasonal adjustment using a much simpler method
% than X-13ARIMA-SEATS. The results are embedded into the x13series object as
% variables 'tr' (for trend), 'sf' (for seasonal factor), 'sa' (for
% seasonally adjusted), and 'ir' (for irregular). fixedseas is much less
% successful in removing seasonality that X-13ARIMA-SEATS is, but it has the
% advantage of producing seasonal factors that do not change over time.
%
% The 'fixedseas' section supports the following keys:
% - 'period'    This can be a single positive integer or a vector of
%               positive integers. It determines the frequencies that are
%               filtered out. If this key is not given, it is set equal to
%               obj.period (i.e. typically 4 or 12).
% - 'transform' fixedseas does an additive or a multiplicative
%               (log-additive) decomposition of the data. You can specify
%               here which one to use. If this argument is omitted, the
%               decomposition is log-additive if obj.isLog is true and additive
%               otherwise.
% - 'type'      Determines how the trend is computed. Default is 'ma' for
%               moving averages. Alternatives are 'hp' (for Hodrick-Prescott),
%               'detrend' (using Matlab's detrend function), 'spline', and
%               'polynomial'.
% - 'typearg'   Additional arguments for 'type' can be specified here. For
%               'hp', 'spline', and 'polynomial', see help fixedseas for an
%               explanation. With 'detrend', the additional argument must
%               be a date or datevector, indicating where breaks in the
%               trend should be allowed.
% - 'extend'    X13ARIMA-SEATS is used to estimate an ARIMA and compute
%               forecasts and backcasts before fixedseas is used. These
%               fore- and backcasts are appended and preappended,
%               respectively, to the data, before computing the trend. This
%               avoids problems of estimating the trend close to the edge
%               of the sample. This cannot be achieved automatically by
%               using fixedseats.m directly. It is, however, automatically
%               done when the x13spec induces x13as to estimate an ARIMA
%               model (either with an 'arima' or 'pickmdl' oder 'automdl'
%               command). By default, 'extend' is set to 3*max(period).
%
% camplet computes a seasonal adjustment propsed by Abeln and Jacobs, 2015.
% The results are embedded into the x13series object as  variables 'csf'
% (seasonal factor), 'csa' (seasonally adjusted), 'cer' (rolling forecast
% error), and 'cg' (rolling trand estimate). camplet is less successful in
% removing seasonality that X-13ARIMA-SEATS is, but it has the
% advantage of producing seasonal factors that do not change over time.
%
% - 'period'    This can be a single positive integer or a vector of
%               positive integers. It determines the frequencies that are
%               filtered out. If this key is not given, it is set equal to
%               obj.period (i.e. typically 4 or 12).
% - 'transform' fixedseas does an additive or a multiplicative
%               (log-additive) decomposition of the data. You can specify
%               here which one to use. If this argument is omitted, the
%               decomposition is log-additive if obj.isLog is true and additive
%               otherwise.
% The following parameters are the ones defining the CAMPLET algorithm. See the
% working paper for explanations.
% - 'CA'        CA parameter (Common Adjustment).
% - 'M'         M parameter (Multiplier).
% - 'P'         P parameter (Pattern).
% - 'LE'        LE parameter (Limit to Error).
% - 'T'         T parameter (Times).
% - 'INITYEARS' The number of years used to initialize the algorithm. The
%               CAMPLET algorithms sets this to 3, but you can override this
%               choice.
%
% NOTE: This file is part of the X-13 toolbox.
%
% see also guix, x13, makespec, x13spec, x13series, x13composite, 
% x13series.plot,x13composite.plot, x13series.seasbreaks,
% x13composite.seasbreaks, fixedseas, camplet, spr, InstallMissingCensusProgram
%
% Author  : Yvan Lengwiler
% Version : 1.31
%
% If you use this software for your publications, please reference it as
%   Yvan Lengwiler, 'X-13 Toolbox for Matlab, Version 1.30', Mathworks File
%   Exchange, 2016.

% History:
% 2017-03-10    Version 1.31    Adaptation to X13ARIMA-SEATE V1.1 B39.
% 2017-01-09    Version 1.30    First release featuring camplet.
% 2017-01-03    Version 1.21.1  Further bug fix related to not sorting user
%                               field.
% 2016-12-31    Version 1.21    Bug fix: regression-user was being sorted
%                               before, which leads to problems with
%                               regression-file and regression-usertype. (Bug
%                               was discovered while working on a question of
%                               Young-Min Kim.)
% 2016-08-19    Version 1.18    Better support for user-definied variables in
%                               'regression' and 'x11regression'.
% 2016-07-18    Version 1.17.4  Bug fix in special treatment of 'metadata' key.
% 2016-07-10    Version 1.17.1  Improved guix. Bug fix in x13series relating to
%                               fixedseas.
% 2016-07-06    Version 1.17    First release featuring guix.
% 2016-03-03    Version 1.16    Adapted to X-13 Version 1.1 Build 26.
% 2015-09-20    Version 1.15.1  Improved display of numerical values (in
%                               disp method). Improved help.
% 2015-08-20    Version 1.15    Significant speed improvement. The imported
%                               time series will now be mapped to the first
%                               day of month if this is the case for the
%                               original data as well. Otherwise, they will
%                               be mapped to the last day of the month. Two
%                               new options --- 'spline' and 'polynomial'
%                               --- for fixedseas. Improvement of .arima,
%                               bugfix in .isLog.
% 2015-07-28    Version 1.14.1  Making sure that values are always strings
%                               (except for 'period' key, where they are
%                               always numeric).
% 2015-07-25    Version 1.14    Improved backward compatibility. Overloaded
%                               version of seasbreaks for x13composite. New
%                               x13series.isLog property. Several smaller
%                               bugfixes and improvements.
% 2015-07-24    Version 1.13.3  Resolved some backward compatibility
%                               issues (thank you, Carlos).
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
% 2015-06-15    Version 1.12.1  Change in disp: 'series' or 'composite' are
%                               shown on top.
% 2015-05-21    Version 1.12    Several improvements: Ensuring backward
%                               compatibility back to 2012b (possibly
%                               farther); Added 'seasma' option to x13;
%                               Added RunsSeasma to x13series; other
%                               improvements throughout. Changed numbering
%                               of versions to be in synch with FEX's
%                               numbering.
% 2015-04-28    Version 1.6     x13as V 1.1 B 19
% 2015-04-02    Version 1.2     Adaptation to X-13 Version V 1.1 B19
% 2015-01-11    Version 1.1     accumulating keys; bugfix for removing
%                               sections and keys
% 2015-01-01    Version 1.05    error checking (only legal sections and
%                               corresponding keys accepted); abbreviation
%                               of sections and keys with 'validatestring';
%                               special formatting of 'metadata'
% 2014-12-31    Version 1.0     first version

classdef x13spec < dynamicprops   %  & matlab.mixin.Copyable

%     properties(Dependent)
%         isempty;
%     end
    
    methods
        
    % --- CONSTRUCTOR -----------------------------------------------------
    
%         function b = get.isempty(obj)
%             b = (numel(fieldnames(obj)) == 0);
%         end
           
        function obj = x13spec(varargin)
        % constructor of x13spec object
        
            spec = struct();
            
            % keys that can be accumulated, save = (d10 d11 d12), for
            % instance.
            accumulKeys = {'save', 'savelog', 'print', 'variables', ...
                'aictest', 'types', 'user', 'usertype'};
            % keys whose values have to be stored as numerics
            numValues = {'period','typearg'};
            
            % merge leading x13opt arguments
            while ~isempty(varargin)
            
                if isa(varargin{1},'cbd.private.sax13.x13spec')

                    Nspec = varargin{1};
                    % sectionsN are sections in Nspec (= varargin{1})
                    sectionsN = fieldnames(Nspec);
                    % sectionsS are sections in existing spec
                    sectionsS = fieldnames(spec);

                    % newSections are sections that were not in spec,
                    % but are in Nspec. This information is simply
                    % copied into spec.
                    newSections = find(~ismember(sectionsN,sectionsS));
                    for n = 1:numel(newSections)
                        spec.(sectionsN{newSections(n)}) = ...
                            Nspec.(sectionsN{newSections(n)});
                    end

                    % oldSections are sections that were already in
                    % spec, but Nspec has also some entries there. This
                    % needs to be merged.
                    hit = ismember(sectionsN,sectionsS);
                    oldSections = sectionsN(hit);
                    for n = 1:numel(oldSections)
                        thissectionN = Nspec.(oldSections{n});
                        thissectionS = spec.(oldSections{n});
                        if isstruct(thissectionN)
                            keysN = fieldnames(thissectionN);
                        else
                            keysN = {};
                        end
                        for nn = 1:numel(keysN)
                            if ismember(keysN{nn},accumulKeys)
                                value  = thissectionN.(keysN{nn});
                                value  = strrep(value,'(','');
                                value  = strrep(value,')','');
                                itemsN = strsplit(value);
                                try
                                    value  = thissectionS.(keysN{nn});
                                    value  = strrep(value,'(','');
                                    value  = strrep(value,')','');
                                    itemsS = strsplit(value);
                                    if any(strcmp(keysN{nn},{'user','usertype'}))
                                        items = [itemsS,itemsN];
                                    else
                                        items  = unique([itemsS,itemsN]);
                                    end
                                catch
                                    items = itemsN;
                                end
                                if numel(items) == 1
                                    value = items{1};
                                else
                                    value = ['(',items{1}];
                                    for t = 2:numel(items)
                                        value = [value,' ',items{t}];
                                    end
                                    value = [value,')'];
                                end
                                thissectionS.(keysN{nn}) = value;
                            else
                                thissectionS.(keysN{nn}) = ...
                                    thissectionN.(keysN{nn});
                            end
                        end
                        spec.(oldSections{n}) = thissectionS;
                    end

                    varargin(1) = [];

                else        % add additional parameters

                    if numel(varargin) < 3
                        err = MException('X13SPEC:IllegalSyntax', ...
                            ['X13 specifications must be triples: ', ...
                            '''section'', ''key'', ''value''.']);
                        throw(err);
                    end

                    section = lower(varargin{1});
                    key     = lower(varargin{2});
                    value   = varargin{3};
                    
                    section = obj.legalize(section);
                    done = false;
                    if iscell(key) && numel(key) == 0   % key = {}
                        spec.(section) = {};
                        done = true;
                    elseif isempty(key)                 % key = []
                        try
                            spec = rmfield(spec,section);
                        end
                        done = true;
                    % key = string, value = [] or {} or ''
                    elseif isempty(value)
                        % value = {} or value = ''
                        if iscell(value) || ischar(value)
                            % do nothing
                        else    % value = []
                            if ismember(section,fieldnames(spec))
                                [section,key] = obj.legalize(section,key);
                                try
                                    if ismember(key,fieldnames(spec.(section)))
                                        spec.(section) = rmfield(spec.(section),key);
                                        if isempty(fieldnames(spec.(section)))
                                            spec.(section) = {};
                                        end
                                    end
                                end
                            end
                        end
                        done = true;
                    end
                    
                    if ~done
                    
                        [section,key] = obj.legalize(section,key);
                        
                        if strcmp(section,'metadata')
                            if ~iscell(value)
                                value = {value};
                            end
                            if numel(value) == 1
                                value = obj.addquotes(value{1});
                            else
                                value = cellfun(@(x) obj.addquotes(x), value, ...
                                    'UniformOutput',false);
                                str = ['(',char(10)];
                                for v = 1:numel(value)
                                    str = [str,char(9),char(9),value{v},char(10)];
                                end
                                value = [str,char(9),char(9),')'];
                            end
                        end

                        fn = fieldnames(spec);
                        if isempty(fn)      % spec is empty
                            if isempty(key)
                                spec.(section) = [];
                            else
                                if ismember(key,numValues)
                                    if ischar(value)
                                        value = strrep(value,'[','');
                                        value = strrep(value,']','');
                                        value = strrep(value,'''','');
                                        v = strsplit(value,' ');
                                        value = cellfun(@(c) str2double(c), v);
                                    end
                                else
                                    if isnumeric(value)
                                        value = mat2str(value);
                                    end
                                end
                                spec.(section) = struct(key,value);
                            end
                        else                % no value given
                            if iscell(value) && numel(value) == 0
                                spec.(section) = rmfield(spec.(section),key);
                                if isempty(fieldnames(spec.(section)))
                                    spec.(section) = [];
                                end
                            elseif isempty(value)
                                spec.(section) = [];
                            else
                                if ismember(section,fn)
                                    if ismember(key,accumulKeys)
                                        if isempty(spec.(section))
                                            olditems = {};
                                        else
                                            try
                                                oldvalue  = spec.(section).(key);
                                                oldvalue  = strrep(oldvalue,'(','');
                                                oldvalue  = strrep(oldvalue,')','');
                                                olditems = strsplit(oldvalue);
                                            catch
                                                olditems = {};
                                            end
                                        end
                                        newvalue  = strrep(value,'(','');
                                        newvalue  = strrep(newvalue,')','');
                                        newitems = strsplit(newvalue);
                                        % unique command sorts the items. This
                                        % is a problem with regression-user, so
                                        % we avoid this in that case.
                                        if any(strcmp(key,{'user','usertype'}))
                                            items = [olditems, newitems];
                                        else
                                            items  = unique([olditems,newitems]);
                                        end
                                        if numel(items) == 1
                                            value = items{1};
                                        else
                                            value = ['(',items{1}];
                                            for t = 2:numel(items)
                                                value = [value,' ',items{t}];
                                            end
                                            value = [value,')'];
                                        end
                                        spec.(section).(key) = value;
                                    else
                                        if ismember(key,numValues)
                                             if ischar(value)
                                                value = strrep(value,'[','');
                                                value = strrep(value,']','');
                                                value = strrep(value,'''','');
                                                v = strsplit(value,' ');
                                                value = cellfun(@(c) ...
                                                    str2double(c), v);
                                            end
                                       else
                                            if isnumeric(value);
                                                value = mat2str(value);
                                            end
                                        end
                                        spec.(section).(key) = value;
                                    end
                                else
                                    if ~isempty(key)
                                        if ismember(key,numValues)
                                            if ischar(value)
                                                value = strrep(value,'[','');
                                                value = strrep(value,']','');
                                                value = strrep(value,'''','');
                                                v = strsplit(value,' ');
                                                value = cellfun(@(c) ...
                                                    str2double(c), v);
                                            end
                                        else
                                            if isnumeric(value);
                                                value = mat2str(value);
                                            end
                                        end
                                        spec.(section) = struct(key,value);
                                    else
                                        spec.(section) = [];
                                    end
                                end
                            end
                        end
                        
                    end

                    varargin(1:3) = [];

                end

            end     % end of varargin

            % sort fields and put into object as properties
            fn = fieldnames(spec);
            fn = sort(fn);
            for f = numel(fn):-1:1
                obj.addprop(fn{f});
                obj.(fn{f}) = spec.(fn{f});
            end

        end     % --- end function
        
    % --- DISPLAY METHODS -------------------------------------------------

        function str = display(obj)
        % short form display of x13spec object
            [nrow,ncol] = size(obj);
            if nrow*ncol == 1
                str = sprintf(' X-13-ARIMA-SEATS specification object\n');
                n = numel(properties(obj));
                if n == 0
                    str = [str, ' The object is empty.'];
                elseif n == 1
                    str = [str, ' Contains 1 section'];
                    str = [str,' (use disp(obj) to see details).'];
                else
                    str = [str, sprintf(' Contains %i sections', n)];
                    str = [str,' (use disp(obj) to see details).'];
                end
                disp(str);
            else
                fprintf(['%ix%i <a href="matlab:helpPopup x13spec">', ...
                    'x13spec</a> array.\n'], nrow, ncol);
            end
        end
        
        function disp(obj)
        % long form display of x13spec object
            if numel(properties(obj)) == 0;
                display(obj);
            else
                display(dispstring(obj));
            end
        end
        
        function str = dispstring(obj)
        % long form display of x13spec object, return as string
            [nrow,ncol] = size(obj);
            if nrow*ncol == 1
                dline = [repmat('=',1,78),char(10)];
                sline = [repmat('.',1,78),char(10)];
                str = dline;
                str = [str, sprintf(' X-13-ARIMA-SEATS specification object\n')];
                fn = fieldnames(obj);
                fn = sort(fn);
                loc = ismember(fn,{'series','composite'});
                fn = [fn(loc);fn(~loc)];
                % fixedseas-detrend-breakpoints should be displayed as datestr
                hasDetrendBreakpoints = false;
                try
                    hasDetrendBreakpoints = ...
                        strcmp('detrend',obj.fixedseas.type) && ...
                        ~isempty(obj.fixedseas.typearg);
                end
                if ~isempty(fn)
                    str = [str, sline];
                    for f = 1:numel(fn)
                        str = [str, sprintf(' - %s\n',fn{f})];
                        sect = obj.(fn{f});
                        if isstruct(sect)
                            keys = fieldnames(sect);
                            for k = 1:numel(keys)-1
                                isDetrendBreakpoints = ...
                                    hasDetrendBreakpoints && ...
                                    (strcmp(fn{f},'fixedseas')) && ...
                                    strcmp(keys{k},'typearg');
                                str = [str,'    ',char(9500),char(9472),' '];
                                value = sect.(keys{k});
                                if ~iscell(value); value = {value}; end
                                if isDetrendBreakpoints
                                    strDates = '';
                                    for c = 1:numel(value)
                                        thedates = datestr(value{c});
                                        for v = 1:size(thedates,1);
                                            strDates = [strDates, ...
                                                thedates(v,:), ', '];
                                        end
                                    end
                                    str = [str, keys{k}, ' : ', ...
                                        strDates(1:end-2), char(10)];
                                else
                                    isnum = cellfun(@(s) isnumeric(s),value);
                                    value(isnum) = cellfun(@(s) num2str(s), ...
                                        value(isnum), 'Uniform',false);
                                    thisstr = strjoin(value,', ');
                                    keep = [thisstr,'  '];
                                    while numel(keep) > numel(thisstr)
                                        keep = thisstr;
                                        thisstr = strrep(thisstr,'  ',' ');
                                    end
                                    str = [str, keys{k}, ' : ', ...
                                        thisstr, char(10)];
                                end
                            end
                            isDetrendBreakpoints = ...
                                hasDetrendBreakpoints && ...
                                (strcmp(fn{f},'fixedseas')) && ...
                                strcmp(keys{end},'typearg');
                            str = [str,'    ',char(9492),char(9472),' '];
                            value = sect.(keys{end});
                            if ~iscell(value); value = {value}; end
                            if isDetrendBreakpoints
                                strDates = '';
                                for c = 1:numel(value)
                                    thedates = datestr(value{c});
                                    for v = 1:size(thedates,1);
                                        strDates = [strDates,thedates(v,:),', '];
                                    end
                                end
                                str = [str, keys{end}, ' : ', ...
                                    strDates(1:end-2), char(10)];
                            else
                                isnum = cellfun(@(s) isnumeric(s),value);
                                value(isnum) = cellfun(@(s) num2str(s), ...
                                    value(isnum), 'Uniform',false);
                                thisstr = strjoin(value,', ');
                                keep = [thisstr,'  '];
                                while numel(keep) > numel(thisstr)
                                    keep = thisstr;
                                    thisstr = strrep(thisstr,'  ',' ');
                                end
                                str = [str, keys{end} ,' : ',thisstr,char(10)];
                            end
                        else
                            str = [str, char(10)];
                        end
                    end
                end
                str = obj.wrapLinesSpecial(str);
            else
                str = sprintf(['%ix%i <a href="matlab:helpPopup x13spec">', ...
                    'x13spec</a> array.\n'], nrow, ncol);
            end
        end     % --- end function
        
    % --- ADD and REMOVE SPECS --------------------------------------------
    
        function obj = SaveRequests(obj,section,key,items)
        % assigns requests to accumulating key, overwriting existing entries
            if isempty(items)
                items = {''};
            end
            if ~iscell(items)
                items = {items};
            end
            if numel(items) == 1
                itemstr = items{1};
                if isempty(itemstr)     % itemstr = ''
                    try
                        obj.(section) = rmfield(key,obj.(section));
                    end
                else
                    obj = cbd.private.sax13.x13spec(obj,section,key,itemstr);
               end
            else
                itemstr = ['(',items{1}];
                for t = 2:numel(items)
                    itemstr = [itemstr,' ',items{t}];
                end
                itemstr = [itemstr,')'];
                obj = cbd.private.sax13.x13spec(obj,section,key,itemstr);
            end
        end

        function obj = AddRequests(obj,section,key,items)
        % adds requests to an accumulating key
            if ~iscell(items)
                items = {items};
            end
            req = obj.ExtractRequests(obj,section,key);
            if numel(req) == 1 && isempty(req{1})
                req = [];
            end
            if any(strcmp(key,{'user','usertype'}))
                items = [req, items];
            else
                items = unique([req,items]);
            end
            obj = SaveRequests(obj,section,key,items);
        end

        function obj = RemoveRequests(obj,section,key,items)
        % removes item from an accumulating key
            if ~iscell(items)
                items = {items};
            end
            req = obj.ExtractRequests(obj,section,key);
            if ~isempty(req)
                keep = ~ismember(req,items);
                obj.(section) = rmfield(obj.(section),key);
                if ~any(keep)
                    if isempty(fieldnames(obj.(section)))
                        obj.(section) = {};
                    end
                else
                    obj = SaveRequests(obj,section,key,req(keep));
                end
            end
        end
       
        function obj = RemoveInconsistentSpecs(obj)
        % removes some (not all) inconsistencies in specifications

            assert(isa(obj,'cbd.private.sax13.x13spec'),'X13TBX:REMOVEINCONSISTENTSPECS:IllArg', ...
                'The argument must be an x13spec object.');

            % TRAMO-SEATS allows an ARIMA of maximum length of 3
            if all(ismember({'seats','automdl'},fieldnames(obj)))
                if ismember('maxorder',fieldnames(obj.automdl))
                    % value is of the form '(x,y)' and x>3
                    if length(obj.automdl.maxorder) == 5 && ...
                            str2double(obj.automdl.maxorder(2)) > 3
                        obj.automdl.maxorder(2) = '3';
                    end
                end
            end

            % only for composites ...
            if ~ismember('composite',fieldnames(obj))
                obj = RemoveRequests(obj,'history','save',{'iae','iar'});
                obj = RemoveRequests(obj,'slidingspans','save', ...
                    {'cis','ais','sis','yis'});
                obj = RemoveRequests(obj,'spectrum','save',{'is0','is1','is2'});
                obj = RemoveRequests(obj,'spectrum','save',{'it0','it1','it2'});
            end

            % only for X11 ...
            if ~ismember('x11',fieldnames(obj))
                obj = RemoveRequests(obj,'spectrum','save',{'sp1','sp2','st1','st2'});
            end

            % only for SEATS ...
            if ~ismember('seats',fieldnames(obj))
                obj = RemoveRequests(obj,'spectrum','save',{'s1s','s2s','t1s', ...
                    't2s','ser','ter'});
                obj = RemoveRequests(obj,'history','save','smh');
            end

            % minimim print for regression obj
            if ismember('regression',fieldnames(obj))
                if (isstruct(obj.regression) && ...
                        ~ismember('print',fieldnames(obj.regression))) || ...
                        isempty(obj.regression)
                    obj = AddRequests(obj, ...
                        'regression', 'print', 'none');
                end
            end

            % minimim print for estimate obj
            if ismember('estimate',fieldnames(obj))
                if (isstruct(obj.estimate) && ...
                        ~ismember('print',fieldnames(obj.estimate))) || ...
                        isempty(obj.estimate)
                    obj = AddRequests(obj, ...
                        'estimate', 'print', '(mdl est lks rts)');
                end
            end

            % minimum print for x11 obj
            if ismember('x11',fieldnames(obj))
                if (isstruct(obj.x11) && ...
                        ~ismember('print',fieldnames(obj.x11))) || ...
                        isempty(obj.x11)
                    obj = AddRequests(obj, ...
                        'x11', 'print', '(none d8f d9a f2 f3 rsf)');
                end
            end

        %     % only for PICKMDL ...
        %     % make sure a 'file' key is present
        %     if ismember('pickmdl',fieldnames(obj))
        %         if ~ismember('file',fieldnames(obj.pickmdl))
        %             fname = [tempdir,'X13\pickmdl.pml'];
        %             obj = x13spec(obj,'pickmdl','file',fname);
        %         end
        %     end

            % only for multiplicative
            % 1) Default of x11/mode is 'mult'. If 'mode' is 'add' or 'pseudoadd',
            %    the decomposition is not multiplicative.
            req = obj.ExtractRequests(obj,'x11','mode');
            isMultiplicative = ~any(ismember({'add','pseudoadd'},req));
            % 2) If transform/function is 'log' or 'auto', the transformation is
            %    multiplicative.
            if ~isMultiplicative
                req = obj.ExtractRequests(obj,'transform','function');
                isMultiplicative = any(ismember({'log','auto'},req));
            end
            % remove tables that give results as percentatge points (these are
            % computed only if the transformation is multiplicative)
            if ~isMultiplicative
                obj = RemoveRequests(obj,'composite','save', ...
                    {'ipa','ip8','ipi','ipf','ipr','ip6','ips','ip7','ip5'});
                obj = RemoveRequests(obj,'force','save', ...
                    {'p6a','p6r'});
                obj = RemoveRequests(obj,'seats','save', ...
                    {'psa','psi','psc','pss'});
                obj = RemoveRequests(obj,'x11','save', ...
                    {'paf','pe8','pir','pe5','pe6','psf','pe7'});
            end

        end
    
    end     % --- end methods
    
    % --- STATIC METHODS --------------------------------------------------

    methods (Static)
        
        function req = ExtractRequests(obj,section,key)
        % returns cell array of requests of an accumulating key
            reqtext = '';
            try
                if ismember(section,fieldnames(obj))
                    if ismember(key,fieldnames(obj.(section)))
                        reqtext = obj.(section).(key);
                    end
                end
                reqtext = strrep(reqtext,char(9),'');   % remove tabs
                reqtext = strrep(reqtext,'"','');       % remove "
                reqtext = strrep(reqtext,'(','');       % remove (
                reqtext = strrep(reqtext,')','');       % remove )
                reqtext = strtrim(reqtext);    % remove leading and trailing spaces
            end
            req = strsplit(reqtext);
            remove = cellfun(@(e) isempty(e), req);
            req(remove) = [];
        end

        function [section,key] = legalize(section,key)
        % return full name of legal section or of key given section
            
            legalsections = {'arima','automdl','check','composite', ...
                'estimate','force','forecast','history','identify', ...
                'metadata','outlier','pickmdl','regression','seats', ...
                'series','slidingspans','spectrum','transform','x11', ...
                'x11regression','fixedseas','camplet'};
            
            legalkeys = { ...
                {'ar','ma','model','title'}, ...                    % arima
                {'acceptdefault','checkmu','diff','fcstlim', ...    % automdl
                 'ljungboxlimit','maxdiff', 'maxorder', 'mixed', ...
                 'print','rejectfcst','savelog','armalimit', ...
                 'balanced','exactdiff','hrinitial','reducecv', ...
                 'urfinal'}, ...
                {'maxlag','print','qtype','save','savelog', ...     % check
                 'acflimit','qlimit'}, ...
                {'appendbcst','appendfcst','decimals', ...          % composite
                 'modelspan','name','print','save','savelog', ...
                 'title','type','indoutlier','saveprecision', ...
                 'yr2000','spectrumstart','diffspectrum','maxspecar', ...
                 'peakwidth','spectrumseries','spectrumtype'}, ...
                {'exact','maxiter','outofsample','print', ...       % estimate
                 'save','savelog','tol','file','fix'} ...,
                {'lambda','mode','print','rho','round','save', ...  % force
                 'start','target','type','usefcst','indforce'}, ...
                {'exclude','lognormal','maxback','maxlead', ...     % forecast
                 'print','probability','save'}, ...
                {'endtable','estimates','fixmdl','fixreg', ...      % history
                 'fstep','print','save','sadjlags','savelog', ...
                 'start','target','trendlags','fixx11reg', ...
                 'outlier','outlierwin','refresh','transformfcst', ...
                 'x11outlier'}, ...
                {'diff','maxlag','print','save','sdiff'}, ...       % identify
                {'keys','values'}, ...                              % metadata
                {'critical','lsrun','method','print','save', ...    % outlier
                 'savelog','span','types','almost','tcrate'}, ...
                {'bcstlim','fcstlim','file','identify', ...         % pickmdl
                 'method','mode','outofsample','overdiff', ...
                 'print','qlim','savelog'}, ...
                {'aicdiff','aictest','chi2test','chi2testcv', ...   % regression
                 'file','data','format','print','pvaictest', ...
                 'save','savelog','start','tlimit','user', ...
                 'usertype','variables','b','centeruser', ...
                 'eastermeans','noapply','tcrate', ...
                 'testalleaster'}, ...
                {'appendfcst','finite','hpcycle','out', ...         % seats
                 'print','printphtrf','qmax','save','savelog', ...
                 'statseas','tabtables','bias','epsiv','epsphi', ...
                 'hplan','imean','maxbias','maxit','noadmiss', ...
                 'rmod','xl'}, ...
                {'appendbcst','appendfcst','comptype','compwt', ... % series
                 'decimals','file','data','format','modelspan','name', ...
                 'period','precision','print','save','span','start', ...
                 'title','type','divpower','missingcode','missingval', ...
                 'saveprecision','trimzero','yr2000'}, ...
                {'cutchng','cutseas','cuttd','fixmdl','fixreg', ... % slidingspans
                 'length','numspans','outlier','print','save', ...
                 'savelog','start','additivesa','fixx11reg', ...
                 'x11outlier'}, ...
                {'logqs','print','save','savelog','start', ...      % spectrum
                 'tukey120','axis','decibel','difference','maxar', ...
                 'peakwidth','series','siglevel','type','qcheck'}, ...
                {'adjust','aicdiff','file','data','format', ...     % transform
                 'function','mode','name','power','precision', ...
                 'print','save','savelog','start','title','type', ...
                 'constant','trimzero'}, ...
                {'appendbcst','appendfcst','final','mode', ...      % x11
                 'print','save','savelog','seasonalma','sigmalim', ...
                 'title','trendma','type','calendarsigma','keepholiday', ...
                 'print1stpass','sfshort','sigmavec','trendi', ...
                 'true7term','excludefcst','spectrumaxis'}, ...
                {'aicdiff','aictest','critical','file','data', ...  % x11regression
                 'format','outliermethod','outlierspan','print', ...
                 'prior','save','savelog','sigma','span','start', ...
                 'tdprior','user','usertype','variables','almost', ...
                 'b','centeruser','eastermeans','forcecal','noapply', ...
                 'reweight','umfile','umdata','umformat','umname', ...
                 'umprecision','umstart','umtrimzero'}, ...
                {'period','transform','type','typearg', ...         % fixedseas
                 'extend'}, ...
                {'period','transform','options'}};                  % camplet
             
             section = strtrim(section);
             section = validatestring(section,legalsections);
             
             if nargin < 2
                 key = [];
                 return;
             end

             if ~isempty(key)
                 hit = ismember(legalsections,section);
                 key = strtrim(key);
                 try
                     key = validatestring(key,legalkeys{hit});
                 catch ME
                     msg = [sprintf('For section ''%s'', ', section), ...
                         'the following keys are possible:\n', ...
                         ME.message(48:end)];
                     msg = strrep(msg,char(10),'\n');
                     err = MException(ME.identifier,msg);
                     throw(err);
                 end
             else
                 key = [];
             end
             
        end
        
    end     % -- end static methods
        
    % --- STATIC HIDDEN METHODS -------------------------------------------

    methods (Static, Hidden)
        
        function str = addquotes(str)
            if ~isempty(str) && ~strcmp(str(1),'"')
                str = ['"',str,'"'];
            end
        end
        
        % wrap string so that no line is longer than 79 characters;
        % preappend a space
        function str = wrapLinesSpecial(str)
            leadText = ['    ',char(9474),'  ']; l = 79;
            if ~strcmp(str(end),char(10))
                str = [str,char(10)];
            end
            posLF    = [0,strfind(str,char(10)),length(str)];
            startpos = posLF(find(diff(posLF) > l)); %#ok<*FNDSB>
            while ~isempty(startpos)
                posSP = find(ismember(str(startpos(1)+1:startpos(1)+1+l),' '), ...
                    1, 'last') + startpos(1);
                if isempty(posSP) || posSP-startpos(1) < ceil(l * 0.6)
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
        
    end     % -- end static hidden methods

end     % -- end classdef
