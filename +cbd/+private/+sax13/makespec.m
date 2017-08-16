% MAKESPEC produces x13 specification structures. It makes the use of
% x13spec easier by providing quick access to meaningful specification
% combinations.
%
% Usage:
%   spec = makespec(shortcut, [shortcut2, ...])
%   spec = makespec(shortcut, section, key, value, ...)
%
% Available shortcuts are:
%   'DIAGNOSTIC'    produce ACF and spectra of the data; this is useful to
%                   determine if the data is seasonal at all
%   'ACF'           subset of 'DIAGNOSTIC' without spectra (for quarterly
%                   data); saves (partial) auto-correlation functions 
%   'SPECTRUM'      save some spectra
%   'STOCK'         Data is a stock variable. (This is relevant for the types of
%                   calendar dummies.)
%   'FLOW'          Data is a flow variable.
%   'AUTO'          let program select additive vs multiplicative filtering
%   'MULTIPLICATIVE'    force multiplicative filtering
%   'ADDITIVE'      force additive filtering
%   'ESTIMATE'      estimate ARIMA, even if no seasonal adjustment is
%                   computed
%   'TRAMO'         use TRAMO to select model
%   'TRAMOPURE'     use TRAMO, but do not consider mixed models
%   'PICKFIRST' or 'PICK' use Census X-11 procedure to select model; pick the
%                   first that meets the criteria
%   'PICKBEST'      use Census X-11 procedure to select model; check all
%                   models and pick the best
%   'CONSTANT'      adds a constant to the regARIMA model
%   'AO'            allow additive outliers
%   'LS'            allow level shifts
%   'TC'            allow temporary changes
%   'NO OUTLIERS'   do not detect outliers
%   'TDAYS'         add trading day dummies to the regression and keep them
%                   if they are significant
%   'FORCETDAYS'    force seven trading day dummies on the regression
%                   (even if not significant)
%   'EASTER'        add an Easter dummy and keep it if significant
%   'FCT'           compute forecast with default confidence bands
%   'FCT50'         compute forecast with 50% confidence bands
%   'X11'           compute Trend-Cycle and Seasonality using X11
%   'FULLX11'       same as X11, but save all available variables, except
%                   intermediary iteration results
%   'TOTALX11'      same as X11, but save all available variables,
%                   including intermediary iteration results
%   'SEATS'         compute Trend-Cycle and Seasonality using SEATS
%   'FULLSEATS'     same as SEATS, but save all available variables
%   'FIXEDSEASONAL' compute simple seasonal filtering with fixedseas
%   'CAMPLET'       compute filtering with camplet algorithm
%   'SLIDINGSPANS'  produces sliding span analysis to gauge the stability
%                   of the estimation and filtered series
%   'FULLSLIDINGSPANS'  same as SLIDINGSPANS, but save all available variables
%   'HISTORY'       another stability analysis that computes the amount of
%                   revisions that would have occurred in the past
%   'FULLHISTORY'   same as HISTORY, but save all available variables
%
% There are also meta-shortcuts:
%   'X' is equal to {'DIAG','AUTO','PICKBEST' ,'X11'  ,'AO'}
%   'S' is equal to {'DIAG','AUTO','TRAMOPURE','SEATS','AO'}
%   'DEFAULT' is the same as 'X'.
% You are free to add further meta-shortcuts according to your needs; see
% the program text right at the beginning after the 'function' statement.
%
% Note that shortcuts can be abbreviated but they are case sensitive; they
% must be given in upper case letter. (This is so in order to distinguish
% the shortcut 'X11' from the spec section 'x11', and shortcut 'SEATS' from
% the spec section 'seats').
%
% Multiple shortcuts can be combined, though some combinations are
% non-sensical (such as X11 and SEATS, or TRAMO and PICK together).
%
% No selection of shortcuts will ever accomodate all needs, unless the
% shortcuts are as detailed as the original specification possibilities,
% which would defy their intent. Therefore, one can also add normal
% section-key-value triples as in x13spec (the second usage form above).
% These settings are simply merged, working from left to right. This means
% that later arguments overwrite earlier arguments.
%
% So, makespec('NO OUTLIERS','AO') is the same as makespec('AO'), and in
% makespec('AUTO','transform','function','none') the 'AUTO' shortcut is
% overruled. Likewise, makespec('X','MULT') is the same as the 'X' 
% meta-shortcut, but forcing the logarithmic transformation of the data
% ('X' sets this to 'auto' and therefore lets x13as choose between no
% transformation and the log).
%
% Example:
%   spec = makespec('DIAG','AUTO','TRAMO','AO');
%   x1 = x13([dates,data],makespec(spec, 'X11', ...
%       'series','name','Using X11'));
%   x2 = x13([dates,data],makespec(spec, 'SEATS', ...
%       'series','name','Using SEATS');
%   plot(x1,x2,'d11','s11','comb')
%
% Most users will never use x13spec directly, but will always create their
% specs with makespec, because everything you can do with x13spec you can
% also do with makespec, plus you have the added convenience of the
% shortcuts (and even meta-shortcuts).
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
% 2017-03-27    Version 1.32    Added 'x11','save','d4' to X11 shortcut.
% 2017-01-09    Version 1.30    First release featuring camplet.
% 2016-09-94    Version 1.18.1  Simpler syntax for defining meta-shortcuts.
% 2016-08-18    Version 1.17.8  Added backcast to FCT shortcut.
% 2016-07-13    Version 1.17.2  Removed 'x11-appendfcst-yes' from 'X11'
%                               definition in makespec.
% 2016-07-10    Version 1.17.1  Improved guix. Bug fix in x13series relating to
%                               fixedseas.
% 2016-07-06    Version 1.17    First release featuring guix.
% 2016-07-04    Version 1.16.1  Added 'STOCK' and 'FLOW'.
% 2016-03-03    Version 1.16    Adapted to X-13 Version 1.1 Build 26.
% 2015-08-20    Version 1.15    Significant speed improvement. The imported
%                               time series will now be mapped to the first
%                               day of month if this is the case for the
%                               original data as well. Otherwise, they will
%                               be mapped to the last day of the month. Two
%                               new options --- 'spline' and 'polynomial'
%                               --- for fixedseas. Improvement of .arima,
%                               bugfix in .isLog.
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
% 2015-06-13    Version 1.12.1  Added 'CONST' and 'ESTIMATE' shortcut.
% 2015-05-21    Version 1.12    Several improvements: Ensuring backward
%                               compatibility back to 2012b (possibly
%                               farther); Added 'seasma' option to x13;
%                               Added RunsSeasma to x13series; other
%                               improvements throughout. Changed numbering
%                               of versions to be in synch with FEX's
%                               numbering.
% 2015-04-28    Version 1.6     x13as V 1.1 B 19
% 2015-04-15    Version 1.2     Adaptation of (meta-)shortcuts to version
%                               1.1 Build 19 of x13as.exe
% 2015-01-04    Version 1.1     Better selection of meta-shortcuts
% 2015-01-01    Version 1.01    Better support for meta-shortcuts
% 2014-12-31    Version 1.0     First Version

function spec = makespec(varargin)
    
    % definition of meta-shortcuts
    meta = struct;
    meta.X = {'DIAG','AUTO','PICKBEST' ,'X11'  ,'AO'};
    meta.S = {'DIAG','AUTO','TRAMOPURE','SEATS','AO'};
    % You are free to add your own here using the same syntax.
    % meta. ...
    
    METANAMES = fieldnames(meta)';
    
    % list of available shortcuts
    SHORTCUTS = {'DEFAULT','STOCK','FLOW', ...
        'AUTO','MULTIPLICATIVE','ADDITIVE', ...
        'ESTIMATE','TRAMO','TRAMOPURE','PICK','PICKFIRST','PICKBEST', ...
        'CONSTANT','AO','LS','TC','NO OUTLIERS', ...
        'TDAYS','FORCETDAYS','EASTER','FCT','FCT50', ...
        'X11','FULLX11','TOTALX11','SEATS','FULLSEATS', ...
        'SPECTRUM','ACF','DIAGNOSTIC', ...
        'SLIDINGSPANS','FULLSLIDINGSPANS', ...
        'HISTORY','FULLHISTORY','FIXEDSEASONAL','CAMPLET'};
    
    % if no arg is given, 'DEFAULT' be executed
    if nargin < 1
        varargin{1} = 'DEFAULT';
    end
    
    % the work starts here
    
    spec = cbd.private.sax13.x13spec();
    
    while ~isempty(varargin)    % loop through all args
        
        try % don't want to abort if no match is found
            % deal with abbreviated shortcuts ...
            validStr = validatestring(varargin{1},[METANAMES,SHORTCUTS]);
            % ... but accept only if they are upper case
            if strncmp(validStr,varargin{1},length(varargin{1}))
                varargin{1} = validStr;
            end
        end
        
        if isa(varargin{1},'cbd.private.sax13.x13spec')
            
            spec = cbd.private.sax13.x13spec(spec,varargin{1});
            varargin(1) = [];
            
        elseif ismember(varargin{1},[METANAMES,SHORTCUTS])
            
            spec = applyshortcut(spec,varargin{1});
            varargin(1) = [];
            
        else    % it's not a shortcut, so it ought to be a
                % section-key-value triple
        
            if numel(varargin) < 3
                str = strjoin([SHORTCUTS,METANAMES],''', ''');
                err = MException('X13TBX:MAKESPEC:IllArg', ...
                    ['Arguments must be specified as triples ', ...
                    '(section-key-value), or be valid shortcuts.\n\n', ...
                    'To see valid section-key-value triplets, use ', ...
                    'help x13spec.\n\nValid shortcuts are: ''%s''.'], str);
                throw(err);
            else
                spec = cbd.private.sax13.x13spec(spec,varargin{1:3});
                varargin(1:3) = [];
            end
            
        end
        
    end
    
    % --- sub-function ----------------------------------------------------
    
    function spec = applyshortcut(spec,arg)

        switch arg
            
            case METANAMES      % it's a meta-shortcut
                spec = cbd.private.sax13.x13spec(spec, ...
                    cbd.private.sax13.makespec(meta.(arg){:}));           % recursive call

            case 'DEFAULT'      % DEFAULT is the first meta-shortcut
                spec = cbd.private.sax13.x13spec(spec, ...
                    cbd.private.sax13.makespec(meta.(METANAMES{1}){:}));  % recursive call
                
            case 'STOCK'
                spec = cbd.private.sax13.x13spec(spec, ...
                    'series'   ,    'type',         'stock');

            case 'FLOW'
                spec = cbd.private.sax13.x13spec(spec, ...
                    'series'   ,    'type',         'flow');

            case 'AUTO'         % let progam select additive vs multiplicative
                spec = cbd.private.sax13.x13spec(spec, ...
                    'transform',    'power',        [],     ...
                    'transform',    'function',     'auto', ...
                    'transform',    'print',        'tac');
    
            case 'MULTIPLICATIVE'	% force multiplicative
                spec = cbd.private.sax13.x13spec(spec, ...
                    'transform',    'power',        [],     ...
                    'transform',    'function',     'log');
                spec = spec.RemoveRequests('transform','print','tac');
    
            case 'ADDITIVE'         % force additive
                spec = cbd.private.sax13.x13spec(spec, ...
                    'transform',    'power',        [],     ...
                    'transform',    'function',     'none');
                spec = spec.RemoveRequests('transform','print','tac');
               
            case 'ESTIMATE'     % estimate ARIMA,
                                % even without seasonal adjustment
                spec = cbd.private.sax13.x13spec(spec, ...
                    'estimate',     'save',         '(mdl ref rsd rts est lks)', ...
                    'estimate',     'print',        '(none est lks rts)');
                if ~ismember('regression',fieldnames(spec))
                    spec = cbd.private.sax13.x13spec(spec,'regression',{},{});
                end

            case 'TRAMO'        % use TRAMO to select model
                                % do allow mixed models
                spec = cbd.private.sax13.makespec(spec, 'ESTIMATE', ...
                    'arima'  , [], [], ...    % remove arima
                    'pickmdl', [], [], ...    % remove PICKMDL
                    'automdl',      'maxorder',     '(4,2)',    ...
                    'automdl',      'acceptdefault','no',       ...
                    'automdl',      'print',        '(hdr urt ach b5m)');
                if ismember('const', spec.ExtractRequests(spec, ...
                        'regression','variables'))
                    spec = cbd.private.sax13.x13spec(spec,'automdl','checkmu','no');
                end
            
            case 'TRAMOPURE'   % use TRAMO to select model, 
                               % do not allow mixed models
                spec = cbd.private.sax13.makespec(spec,'TRAMO','automdl','mixed','no');

            case {'PICKFIRST','PICK'} % use Census X-11 procedure to select model
                spec = cbd.private.sax13.makespec(spec, 'ESTIMATE', ...
                    'arima'  , [], [], ...    % remove arima
                    'automdl', [], [], ...    % remove TRAMO
                    'pickmdl',      'method',       'first',    ...
                    'pickmdl',      'print',        '(hdr pch -umd)', ...
                    'pickmdl',      'mode',         'fcst',     ...
                    'pickmdl',      'outofsample',  'yes');
                
            case 'PICKBEST'
                spec = cbd.private.sax13.makespec(spec,'PICKFIRST', ...
                    'pickmdl',      'method',       'best');
            
            case 'CONSTANT'     % add a constant to the ARIMA model
                spec = AddRequests(spec, ...
                    'regression',   'variables',    'const');
                if ismember('automdl',fieldnames(spec))
                    spec = cbd.private.sax13.x13spec(spec,'automdl','checkmu','no');
                end
                
            case 'AO'           % allow additive outliers
                spec = spec.RemoveRequests('outlier','types','none');
                spec = cbd.private.sax13.x13spec(spec, ...
                    'regression',   'save',         'ao',       ...
                    'outlier',      'types',        'ao',       ...
                    'outlier',      'print',        'none', ...
                    'outlier',      'savelog',      'id');
            
            case 'LS'           % allow level shifts
                spec = spec.RemoveRequests('outlier','types','none');
                spec = cbd.private.sax13.x13spec(spec, ...
                    'regression',   'save',         'ls',       ...
                    'outlier',      'types',        'ls',       ...
                    'outlier',      'print',        'none', ...
                    'outlier',      'savelog',      'id');
                
            case 'TC'           % allow temporary changes
                spec = spec.RemoveRequests('outlier','types','none');
                spec = cbd.private.sax13.x13spec(spec, ...
                    'regression',   'save',         'tc',       ...
                    'outlier',      'types',        'tc',       ...
                    'outlier',      'print',        'none', ...
                    'outlier',      'savelog',      'id');
               
            case 'NO OUTLIERS'  % do not detect outliers
                spec = cbd.private.sax13.x13spec(spec, ...
                    'outlier',      'method',       {},         ...
                    'outlier',      'types',        {},         ...
                    'outlier',      'types',        'none',     ...
                    'outlier',      'print',        'none',     ...
                    'outlier',      'savelog',      {});
                spec = RemoveRequests(spec, ...
                    'regression',   'save',   {'ao','ls','tc'});
                
            case 'TDAYS'
                spec = cbd.private.sax13.x13spec(spec, ...
                    'regression',   'aictest',      'td',       ...
                    'regression',   'save',         'td',       ...
                    'regression',   'print',        'ats');
                
            case 'FORCETDAYS'
                spec = cbd.private.sax13.x13spec(spec, ...
                    'regression',   'variables',    'td',       ...
                    'regression',   'save',         'td');
                
            case 'EASTER'
                spec = cbd.private.sax13.x13spec(spec, ...
                    'regression',   'aictest',      'easter',   ...
                    'regression',   'save',         'hol',      ...
                    'regression',   'print',        'ats');
                
            case 'FCT'      % compute forecast
                spec = cbd.private.sax13.x13spec(spec, ...
                    'forecast',     'maxlead',      36,     ...
                    'forecast',     'maxback',      36,     ...
                    'forecast',     'save',         '(bct fct)',  ...
                    'forecast',     'print',        'none');

            case 'FCT50'    % compute forecast with 50% confidence bands
                spec = cbd.private.sax13.makespec(spec, 'FCT', ...
                    'forecast',     'probability',  0.5);

            case 'X11'      % compute trend-cycle and seasonality using X11
                spec = cbd.private.sax13.x13spec(spec, ...
                    'seats', [], [], ...    % remove SEATS
                    'x11',   'print',       '(none d8f d9a f2 f3 rsf)', ...
                    'x11',   'save',        [], ...    % remove existing x11-save
                    'x11',   'save',        '(e2 e3 d4 d8 d10 d11 d12 d13 d16)');
%                    'x11',   'appendfcst',  'yes', ...

            case 'FULLX11'  % more complete selection of saved variables
                spec = cbd.private.sax13.makespec(spec, 'X11', ...
                    'x11',   'save',   ...
                        ['(ars bcf chl d4 d8 d10 d11 d12 d13 d16 d18 ', ...
                         'd8b d9 e1 e11 e18 e2 e3 e4 e5 e6 e7 e8 f1 ', ...
                         'fad fsd ira sac tac tad tal paf pe8 pir pe5 ', ...
                         'pe6 psf pe7)']);

            case 'TOTALX11' % all available variables of X11 are saved
                spec = cbd.private.sax13.makespec(spec, 'X11', ...
                    'x11',   'save',  ...
                        ['(ars b10 b11 b13 b17 b19 b2 b20 b3 b5 b6 ', ...
                         'b7 b8 bcf c1 c10 c11 c13 c17 c19 c2 c20 c4 ', ...
                         'c5 c6 c7 c9 chl d1 d10 d11 d12 d13 d16 d18 ', ...
                         'd2 d4 d5 d6 d7 d8 d8b d9 e1 e11 e18 e2 e3 ', ...
                         'e4 e5 e6 e7 e8 f1 fad fsd ira sac tac tad ', ...
                         'tal paf pe8 pir pe5 pe6 psf pe7)']);

            case 'SEATS'    % compute trend-cycle and seasonality using SEATS
                spec = cbd.private.sax13.x13spec(spec, ...
                    'x11',   [], [], ...        % remove X11
                    'seats', 'save',  [], ...   % remove existing seats-save
                    'seats', 'out',   2, ...
                    'seats', 'save',  '(s10 s16 s11 s12 s13)');

            case 'FULLSEATS'    % all available variables of SEATS are saved
                spec = cbd.private.sax13.makespec(spec, 'SEATS', ...
                    'seats', 'out',   0, ...
                    'seats', 'save',  ...
                        ['(afd cyc dsa dtr ltt ofd s10 s11 s12 s13 ', ...
                        's14 s16 s18 sec sfd ssm sta stc tfd yfd ' ...
                        'mdc fac faf ftc ftf pic pis pit pia gac gaf ', ...
                        'gtc gtf tac ttc wkf psa psi psc pss)']);
                    
            case 'SLIDINGSPANS'
                spec = cbd.private.sax13.x13spec(spec, ...
                    'slidingspans','save','(chs sfs ycs)');
                    
            case 'FULLSLIDINGSPANS'
                spec = cbd.private.sax13.makespec(spec, 'SLIDINGSPANS', ...
                    'slidingspans','save','(cis ais sis yis tds)');
                    
            case 'HISTORY'
                spec = cbd.private.sax13.x13spec(spec, ...
                    'history','save','(iae iar rot sae sar smh)');
                    
            case 'FULLHISTORY'
                spec = cbd.private.sax13.makespec(spec, 'HISTORY', ...
                    'history','save',['(che chr fce fch lkh sfe sfh sfr ', ...
                        'tce tcr tre trr)']);
            
            case 'ACF'              % subset of DIAGNOSTIC
                spec = cbd.private.sax13.makespec(spec, 'ESTIMATE', ...
                    'check',    'save',     '(acf ac2 pcf)',    ...
                    'check',    'print',    '(none hst nrm)');
                
            case 'SPECTRUM'         % subset of DIAGNOSTIC
                spec = cbd.private.sax13.x13spec(spec, ...
                    'spectrum', 'save' , ['(sp0 sp1 sp2 s1s s2s ser ', ...
                        'spr is0 is1 is2 ', ...
                        'st0 st1 st2 t1s t2s ter str it0 it1 it2)'], ...
                    'spectrum', 'print',   '(none tpk)');
                    
            case 'DIAGNOSTIC'       % ACF and SPECTRUM
                spec = cbd.private.sax13.makespec(spec,'ACF','SPECTRUM');
                
            case 'FIXEDSEASONAL'    % compute fixed seasonal pattern
                                    % with simple method
                spec = cbd.private.sax13.x13spec(spec,'fixedseas',{},{});

            case 'CAMPLET'          % compute seasonal pattern using CAMPLET
                                    % argorithm
                spec = cbd.private.sax13.x13spec(spec,'camplet',{},{});

        end
        
    end

end
