% GUIX is a GUI that allows you to easily create a specification for a seasonal
% adjustment using X-13, perform the computations, and view the results in the
% GUI. guix supports only single times series, not composites.
%
% Usage:
%   guix
%   guix('style')
%   guix 'style'
%   guix('variable')
%   guix variable
%   h = guix([style],['variable'])
%
% Inputs and Outputs:
%   'style'     Can be 'normal', 'modal', or 'docked' (or 'n', 'm', or
%               'd', for short), indicating the WindowStyle of the GUI.
%               Default is 'normal'.
%   variable    A x13series variable in the main workspace.
%   'variable'  The name of a x13series variable in the main workspace, as
%               string.
%   h           A struct containing handles to the GUI and to its
%               components.
%
% Usage of this GUI should be self-explanatory (if you are familiar with the
% outputs that X-13ARIMA-SEATS generates). In the dates / data field, the user
% can enter variable names containing the dates (a vector) and the data that are
% to be worked on (also a vector). These variables must be present in the
% calling workspace. You can also import an x13series object existing in the
% calling workspace into guix with the 'Import' button.
% 
% The 'Run' button performs the computations. You can export the resulting
% x13series object to the calling workspace with the 'Export' button.
%
% With the 'Text/Chart' button you can switch between viewing tables and text
% items on the one hand, and plots on the other.
%
% The 'Copy' button copies the current output window (text or chart) to Windows’
% clipboard. You can then paste it into some other program.
%
% NOTE: This GUI was programmatically created, without using GUIDE.
% Other than the code generated with GUIDE, it uses nested functions,
% which has the advantage that all variables that are defined in the main
% function are also in the scope of the nested functions.
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
%                               dates.
% 2017-01-09    Version 1.30    First release featuring camplet.
% 2016-08-23    Version 1.18.2  Added ability to provide a variable that is to
%                               be loaded from the command line.
% 2016-08-22    Version 1.18.1  Using 'specminus' inmstead of 'specdiff' now.
%                               'specdiff' is not part of the toolbox.
% 2016-08-19    Version 1.18    Adaptations related to x13series support of
%                               user-defined variables.
% 2016-08-18    Version 1.17.7  Take care of incompatinility of -r with -w and
%                               -n.
% 2016-08-16    Version 1.17.6  Added flag support.
% 2016-07-30    Version 1.17.5  Better support for composite series (not for
%                               x13composite objects; they are still not
%                               supported). Bug fix in reading value of
%                               'x11-mode'. Added 'no model' option. Bug fix in
%                               working with 'additional specifications' field
%                               that ontains only spaces or empty lines.
% 2016-07-27    Version 1.17.4  Added possibility to import an x13series object
%                               from the base workspace.
% 2016-07-17    Version 1.17.3  Added buttons to open documentation files. Fixed
%                               problem of sliders with non-monthly data. 
% 2016-07-13    Version 1.17.2  Further improvements of guix. Separating lines
%                               in menu, plots of arbitrary variables, sliders
%                               to select the date-range that is plotted.
% 2016-07-10    Version 1.17.1  Improved guix. Bug fix in x13series relating to
%                               fixedseas.
% 2016-07-06    Version 1.17    First release featuring guix.

%#ok<*TRYNC>    % suppress 'try needs a catch' complaint in this file

function handles = guix(varargin)

% *** parse parameter **********************************************************
style = [];
loadvariable = [];
while ~isempty(varargin)
    try
        style = validatestring(varargin{1},{'normal','modal','docked'});
    catch e
        loadvariable = [loadvariable, varargin(1)]; %#ok<AGROW>
    end
    varargin(1) = [];
end

if numel(loadvariable) > 1
    warning('X13TBX:GUIX:too_many:params', ...
        ['Too many parameters provided. Will attempt to load the first ', ...
        ' variable ''', loadvariable{1}, '''.']);
    loadvariable(2:end) = [];
end

% *** initialize some variables ************************************************
% (these variables are 'global' within this program)

    cmdspec   = '';                     % makespec command line
    cmdx13    = '';                     % call x13 command line
    strFlags  = '';                     % flags for x13 command line
    x = x13series;                      % x13series object
    
    itemTextMenu = 'command line';      % item chosen in text menu
    itemPlotMenu = 'data';              % item chosen in plot menu
    % separator menu line
    hline = {'--------------------------------------------'};
    
    vecFirstDate = NaN; vecLastDate = NaN;  % date range of list of variables
    vecFromDate = NaN;  vecToDate = NaN;    % date range to plot
    
    doKeepPlotRange = false;            % If true, vecFromDate and vecToDate is
                                        % used to compute position of sliders.
                                        % If false, position of sliders is used
                                        % to compute vecFromDate and vecToDate.

% *** create but hide the GUI as it is being constructed ***********************

    % sizes of objects
    s = get(0,'ScreenSize');            % size of monitor
    vsizeGUI = min(s(4),724);           % size of GUI
    hsizeGUI = min(s(3),1188);
    % spaces between objects
    vmargin = 20;   hmargin = 20;       % vert and horiz margins
    headvspace = 8;                     % vert space between menu buttons and
                                        % rest
    vspace = 6;     hspace = 10;        % vert and horiz spacing
    xspace = 8;                         % extra vertical space
    sspace = 5;                         % small horizontal space
    % widths of columns
    width0 = 80; width = 87;            % first and regular columns
    % horizontal positions
    hpos0 = hmargin;                    % left-most column
    hpos1 = hpos0 + width0 + hspace;    % column 1
    hpos2 = hpos1 + width  + hspace;    % column 2
    hpos3 = hpos2 + width  + hspace;    % column 3
    widthcol123 = 3*width + 2*hspace;   % width col 1 - col 3
    widthcol0123 = widthcol123 + width0 + hspace;
    hposR = hpos3 + width  + 2*hspace;  % right part of GUI
    % size of particular objects
    vpb = 19;       hpb = 54;           % size of pushbuttons
    vpu = 18;                           % vert size of popup menu
    ved = 18;                           % vert size of editable text
    vtx = 18;                           % vert size of fixed text
    vti = 18;       hti = widthcol0123; % size of titles
    vsl = 18;                           % vert size of sliders
    bup = 3;    % move button row on top a little up
    hflag = 30;                         % width of flag check boxes
    % margins for axes
    axLmargin = 40; axRmargin = 5; axTmargin = 40; axBmargin = 25;

    hGUI = figure(...
        'Visible'         , 'off', ...
        'Units'           , 'pixels', ...
        'WindowStyle'     , 'normal', ...
        'Position'        , [0,0,hsizeGUI,vsizeGUI], ...
        'Name'            ,'GUIX : X-13 adjustment with a mouse click', ...
        'MenuBar'         , 'none', ...
        'NumberTitle'     , 'off', ...
        'Resize'          , 'on', ...
        'Color'           , get(0,'defaultUicontrolBackgroundColor'), ...
        'ResizeFcn'       , {@resizeGUI} ...
        );
    
    if ~isempty(style)
        try
            set(hGUI,'WindowStyle',style);
        catch e
            id = e.identifier;
            msg = ['clickspec: argument must be one of the following: ',...
                '''normal'', ''modal'', or ''docked''.\n', e.message];
            error(id,msg);
        end
    end
    
%% *** populate the GUI with objects *******************************************
% Note that at this point the positions and sizes of the objects are not
% specified. They will be set later in 'resizeGUI'.

    hpbDocX13 = uicontrol(...
        'Style'          ,'pushbutton',...
        'String'         ,'Doc X-13',...
        'TooltipString'  ,'View X-13ARIMA-SEATS documentation.',...
        'Callback'       ,@OpenDoc);
    hpbDocTBX = uicontrol(...
        'Style'          ,'pushbutton',...
        'String'         ,'Doc TBX',...
        'TooltipString'  ,'View Documentation of Toolbox.',...
        'Callback'       ,@OpenDoc);
    
    htxtVARIABLE = uicontrol(...
        'Style'          ,'text',...
        'FontWeight'     ,'bold',...
        'HorizontalAlignment','left',...
        'String'         ,'VARIABLES');
    htxtX13 = uicontrol(...
        'Style'          ,'text',...
        'HorizontalAlignment','right',...
        'String'         ,'x13 object');
    hedX13Name = uicontrol(...
        'Style'          ,'edit',...
        'String'         ,'',...
        'TooltipString'  ,'Name of x13series variable',...
        'Callback'       ,@SpecChanged);
    hpbLoad = uicontrol(...
        'Style'          ,'pushbutton',...
        'String'         ,'Import',...
        'TooltipString'  ,'Load x13series from main workspace',...
        'Enable'         ,'off',...
        'Callback'       ,@LoadX13);
    hpbSave = uicontrol(...
        'Style'          ,'pushbutton',...
        'String'         ,'Export',...
        'TooltipString'  ,'Export x13series to main workspace',...
        'Enable'         ,'off',...
        'Callback'       ,@SaveX13);

    htxtDATA = uicontrol(...
        'Style'          ,'text',...
        'FontWeight'     ,'bold',...
        'HorizontalAlignment','left',...
        'String'         ,'DATA');
    htxtDatesData = uicontrol(...
        'Style'          ,'text',...
        'HorizontalAlignment','right',...
        'String'         ,'dates / data');
    hedDates = uicontrol(...
        'Style'          ,'edit',...
        'FontName'       ,'Courier',...
        'String'         ,'',...
        'TooltipString'  ,'Specify the variable that contains the dates.',...
        'BackgroundColor','white',...
        'Callback'       ,@SpecChanged);
    hedData = uicontrol(...
        'Style'          ,'edit',...
        'FontName'       ,'Courier',...
        'String'         ,'',...
        'TooltipString'  ,'Specify the variable that contains the data.',...
        'BackgroundColor','white',...
        'Callback'       ,@SpecChanged);
    hpuType = uicontrol(...
        'Style'          ,'popupmenu',...
        'String'         ,{'unspecified','stock','flow'},...
        'TooltipString'  ,'Select the type of the data.',...
        'BackgroundColor','white',...
        'Callback'       ,@SpecChanged);
    htxtTitle = uicontrol(...
        'Style'          ,'text',...
        'HorizontalAlignment','right',...
        'String'         ,'title');
    hedTitle = uicontrol(...
        'Style'          ,'edit',...
        'String'         ,'',...
        'FontName'       ,'Courier',...
        'HorizontalAlignment','left',...
        'TooltipString'  ,['Specify the name of the variable as contained ',...
                           'in the X-13 output.'],...
        'BackgroundColor','white',...
        'Callback'       ,@SpecChanged);
    
    htxtFCT = uicontrol(...
        'Style'          ,'text',...
        'FontWeight'     ,'bold',...
        'HorizontalAlignment','left',...
        'String'         ,'FORECAST / BACKCAST');
    htxtHorizon = uicontrol(...
        'Style'          ,'text',...
        'HorizontalAlignment','right',...
        'String'         ,'horizon');
    hedHorizon = uicontrol(...
        'Style'          ,'edit',...
        'FontName'       ,'Courier',...
        'String'         ,'0',...
        'TooltipString'  ,'Specify the horizon of the forecast. (0 means that no forecast is computed.)',...
        'BackgroundColor','white',...
        'Callback'       ,@SpecChanged);
    htxtConfidence = uicontrol(...
        'Style'          ,'text',...
        'HorizontalAlignment','right',...
        'String'         ,'conf. band');
    hedConfidence = uicontrol(...
        'Style'          ,'edit',...
        'FontName'       ,'Courier',...
        'String'         ,'0.95',...
        'TooltipString'  ,['Specify the probability covered by the ', ...
            'confidence band around the the forecast (greater than 0.0, ', ...
            'less than 1.0.'],...
        'BackgroundColor','white',...
        'Callback'       ,@SpecChanged);

    htxtREGR = uicontrol(...
        'Style'          ,'text',...
        'FontWeight'     ,'bold',...
        'HorizontalAlignment','left',...
        'String'         ,'REGRESSION and OUTLIERS');
    htxtRegressors = uicontrol(...
        'Style'          ,'text',...
        'HorizontalAlignment','right',...
        'String'         ,'regressors');
    hchkConst = uicontrol(...
        'Style'          ,'checkbox',...
        'String'         ,' constant',...
        'TooltipString'  ,'Add a constant to the ARIMA model.',...
        'Callback'       ,@SpecChanged);
    hchkTD = uicontrol(...
        'Style'          ,'checkbox',...
        'String'         ,' trading days',...
        'TooltipString'  ,'Automatic trading day/leap year regressors.',...
        'Callback'       ,@SpecChanged);
    hchkEaster = uicontrol(...
        'Style'          ,'checkbox',...
        'String'         ,' Easter',...
        'TooltipString'  ,'Check for Easter regressor.',...
        'Callback'       ,@SpecChanged);
    htxtAutoOutliers = uicontrol(...
        'Style'          ,'text',...
        'HorizontalAlignment','right',...
        'String'         ,'auto outliers');
    hchkAO = uicontrol(...
        'Style'          ,'checkbox',...
        'String'         ,' additive',...
        'TooltipString'  ,'Add auto-detected additive (''one-time'') outliers.',...
        'Callback'       ,@SpecChanged);
    hchkLS = uicontrol(...
        'Style'          ,'checkbox',...
        'String'         ,' level shifts',...
        'TooltipString'  ,'Add auto-detected permanent level shifts.',...
        'Callback'       ,@SpecChanged);
    hchkTC = uicontrol(...
        'Style'          ,'checkbox',...
        'String'         ,' trans. shifts',...
        'TooltipString'  ,'Add auto-detected transitory shifts.',...
        'Callback'       ,@SpecChanged);
    htxtMoreRegressors = uicontrol(...
        'Style'          ,'text',...
        'HorizontalAlignment','right',...
        'String'         ,'more regr.');
    hedMoreRegressors = uicontrol(...
        'Style'          ,'edit',...
        'String'         ,'',...
        'HorizontalAlignment','left',...
        'TooltipString'  ,'Specify further regressors.',...
        'BackgroundColor','white',...
        'Callback'       ,@SpecChanged);

    htxtSARIMA = uicontrol(...
        'Style'          ,'text',...
        'FontWeight'     ,'bold',...
        'HorizontalAlignment','left',...
        'String'         ,'SARIMA-Model');
    htxtTransform = uicontrol(...
        'Style'          ,'text',...
        'HorizontalAlignment','right',...
        'String'         ,'transformation');
    hpuTransform = uicontrol(...
        'Style'          ,'popupmenu',...
        'String'         ,{'none specified','auto','no transformation', ...
            'logarithm','square root','inverse','logistic','power'},...
        'TooltipString'  ,'Select how data are transformed before working on them.',...
        'BackgroundColor','white',...
        'Callback'       ,@SpecChanged);
    hedPower = uicontrol(...
        'Style'          ,'edit',...
        'FontName'       ,'Courier',...
        'String'         ,'1.0',...
        'TooltipString'  ,'Specify the exponent of the power transformation.',...
        'BackgroundColor','white',...
        'Callback'       ,@SpecChanged);
    htxtSelectModel = uicontrol(...
        'Style'          ,'text',...
        'HorizontalAlignment','right',...
        'String'         ,'select model');
    hgrSelectModel = uibuttongroup(...
        'BorderType'     ,'none',...
        'SelectionChangedFcn',@SpecChanged);
    hrbPickmdl = uicontrol(hgrSelectModel, ...
        'Style'          ,'radiobutton',...
        'String'         ,'X-11 PickMdl',...
        'TooltipString'  ,'Use X-11 procedure to pick a model.');
    p = mfilename('fullpath');      % get direcory of the toolbox
    [strPath, ~, ~] = fileparts(p); % parse filename and path
    modelfiles = dir(fullfile(strPath,'@x13spec','*.pml'));
    modelfiles = {'(use default)',modelfiles.name};
    hpuPickmdlFile = uicontrol(...
        'Style'          ,'popupmenu',...
        'String'         ,modelfiles,...
        'TooltipString'  ,'Select the model definition file used by PICKMDL.',...
        'BackgroundColor','white',...
        'Callback'       ,@SpecChanged);
    hpuFirstBest = uicontrol(...
        'Style'          ,'popupmenu',...
        'String'         ,{'use best','use first'},...
        'TooltipString'  ,'Test all models and pick the best, or use the first acceptable model.',...
        'BackgroundColor','white',...
        'Callback'       ,@SpecChanged);
    hrbTramo = uicontrol(hgrSelectModel, ...
        'Style'          ,'radiobutton',...
        'String'         ,'TRAMO',...
        'TooltipString'  ,'Use TRAMO procedure to select a model.');
    hchkCheckMu = uicontrol(...
        'Style'          ,'checkbox',...
        'String'         ,' check mu',...
        'TooltipString'  ,'Check if constant is significant.',...
        'Callback'       ,@SpecChanged);
   hchkAllowMixed = uicontrol(...
        'Style'          ,'checkbox',...
        'String'         ,' allow mixed',...
        'TooltipString'  ,'Allow TRAMO to select a mixed model.',...
        'Callback'       ,@SpecChanged);
    hrbManualModel = uicontrol(hgrSelectModel, ...
        'Style'          ,'radiobutton',...
        'String'         ,'manual',...
        'TooltipString'  ,'Specify model manually.');
    hedArima = uicontrol(...
        'Style'          ,'edit',...
        'String'         ,'(0 1 1)(0 1 1)',...
        'FontName'       ,'Courier',...
        'TooltipString'  ,'(S)ARIMA specification.',...
        'BackgroundColor','white',...
        'Callback'       ,@SpecChanged);
    hrbNoModel = uicontrol(hgrSelectModel, ...
        'Style'          ,'radiobutton',...
        'String'         ,'no model',...
        'TooltipString'  ,'Do not estimate a regARIMA model.');
    
    htxtSEASADJ = uicontrol(...
        'Style'          ,'text',...
        'FontWeight'     ,'bold',...
        'HorizontalAlignment','left',...
        'String'         ,'SEASONAL ADJUSTMENT');
    htxtSeasType = uicontrol(...
        'Style'          ,'text',...
        'HorizontalAlignment','right',...
        'String'         ,'adjustment-type');
    hpuSeasType = uicontrol(...
        'Style'          ,'popupmenu',...
        'String'         ,{'none','X-11','SEATS'},...
        'TooltipString'  ,'Type of seasonal adjustment.',...
        'BackgroundColor','white',...
        'Callback'       ,@SpecChanged);
    hpuMode = uicontrol(...
        'Style'          ,'popupmenu',...
        'String'         ,{'unspecified','additive','multiplicative','pseudo-additive','log-additive'},...
        'TooltipString'  ,'Mode of seasonal adjustment.',...
        'BackgroundColor','white',...
        'Callback'       ,@SpecChanged);
    hchkFixed = uicontrol(...
        'Style'          ,'checkbox',...
        'String'         ,' fixed factors',...
        'TooltipString'  ,'Compute fixed factors as well.',...
        'Callback'       ,@SpecChanged);
    hchkCamplet = uicontrol(...
        'Style'          ,'checkbox',...
        'String'         ,' camplet',...
        'TooltipString'  ,'Compute CAMPLET adjustment as well.',...
        'Callback'       ,@SpecChanged);
    
    htxtDIAG = uicontrol(...
        'Style'          ,'text',...
        'FontWeight'     ,'bold',...
        'HorizontalAlignment','left',...
        'String'         ,'DIAGNOSTICS');
    hchkACF = uicontrol(...
        'Style'          ,'checkbox',...
        'String'         ,' ACF',...
        'TooltipString'  ,'Compute auto-correlation function.',...
        'Callback'       ,@SpecChanged);
    hchkSpectrum = uicontrol(...
        'Style'          ,'checkbox',...
        'String'         ,' spectrum',...
        'TooltipString'  ,'Compute different spectrums.',...
        'Callback'       ,@SpecChanged);
    hchkHistory = uicontrol(...
        'Style'          ,'checkbox',...
        'String'         ,' history',...
        'TooltipString'  ,'Compute revision history.',...
        'Callback'       ,@SpecChanged);
    hchkSlidingSpans = uicontrol(...
        'Style'          ,'checkbox',...
        'String'         ,' sliding spans',...
        'TooltipString'  ,'Compute sliding span analysis.',...
        'Callback'       ,@SpecChanged);
    
    htxtMORESPECS = uicontrol(...
        'Style'          ,'text',...
        'FontWeight'     ,'bold',...
        'HorizontalAlignment','left',...
        'String'         ,'ADDITIONAL SPECIFICATIONS');
    hedMoreSpecs = uicontrol(...
        'Style'          ,'edit',...
        'Min'            ,0,...
        'Max'            ,2,...                     % multi-line
        'FontName'       ,'Courier',...
        'String'         ,'',...
        'HorizontalAlignment','left',...
        'TooltipString'  ,'Space for additional specifications (passed on to makespec).',...
        'BackgroundColor','white',...
        'Callback'       ,@SpecChanged);

    hpbRun = uicontrol(...
        'Style'          ,'pushbutton',...
        'String'         ,'Run',...
        'Enable'         ,'off',...
        'TooltipString'  ,'Run the commands.',...
        'Callback'       ,@Run);
    hchkW = uicontrol(...
        'Style'          ,'checkbox',...
        'String'         ,'-w',...
        'TooltipString'  ,'Use wide format (132 chars) for tables.',...
        'Value'          ,false,...
        'Callback'       ,@SetW);
    hchkN = uicontrol(...
        'Style'          ,'checkbox',...
        'String'         ,'-n',...
        'TooltipString'  ,'Make only the explicitly requested tables.',...
        'Value'          ,true,...
        'Callback'       ,@SetN);
    hchkR = uicontrol(...
        'Style'          ,'checkbox',...
        'String'         ,'-r',...
        'TooltipString'  ,'Make a reduced set of tables.',...
        'Value'          ,false,...
        'Callback'       ,@SetR);
    hchkS = uicontrol(...
        'Style'          ,'checkbox',...
        'String'         ,'-s',...
        'TooltipString'  ,'Make diagnostics files.',...
        'Value'          ,true,...
        'Callback'       ,@SpecChanged);
    hchkQ = uicontrol(...
        'Style'          ,'checkbox',...
        'String'         ,'quiet',...
        'TooltipString'  ,'Suppress warnings to console.',...
        'Value'          ,false,...
        'Callback'       ,@SpecChanged);
    
    
    htglOut = uicontrol(...
        'Style'          ,'togglebutton',...
        'String'         ,'Text / Chart',...
        'Enable'         ,'off',...
        'TooltipString'  ,'Switch between text and graph items.',...
        'Callback'       ,@TogglePressed);
    hpuOut = uicontrol(...
        'Style'          ,'popupmenu',...
        'String'         ,{'command line'},...
        'Enable'         ,'off',...
        'TooltipString'  ,'Select type of output.',...
        'BackgroundColor','white',...
        'Callback'       ,@MenuItemChanged);
    hpbCopy = uicontrol(...
        'Style'          ,'pushbutton',...
        'String'         ,'Copy',...
        'TooltipString'  ,'Copy command line or output to clipboard.',...
        'Callback'       ,@Copy);
    htxtTimeOfRun = uicontrol(...
        'Style'          ,'text',...
        'FontName'       ,'Courier',...
        'HorizontalAlignment','right',...
        'String'         ,'');
    hedOut = uicontrol(...
        'Style'          ,'edit',...
        'Enable'         ,'inactive',...              % content not selectable
        'Min'            ,0,...
        'Max'            ,2,...                       % multi-line
        'FontName'       ,'Courier',...
        'BackgroundColor','white',...
        'HorizontalAlignment','left',...
        'String'         ,'');
    set(hedOut,'FontSize',get(hedOut,'FontSize')+1);  % make font a little larger
    haxOut = axes(...
        'Visible'        ,'off');
    hslFrom = uicontrol(...
        'Style'          ,'slider',...
        'Min'            ,0,...
        'Max'            ,240,...
        'SliderStep'     ,[1/36,12/36],...
        'Value'          ,0,...
        'Visible'        ,'off',...
        'TooltipString'  ,'Select lower boundary of date-range that is shown in the graph.',...
        'Callback'       ,@SliderMovement);
    hslTo = uicontrol(...
        'Style'          ,'slider',...
        'Min'            ,-240,...
        'Max'            ,0,...
        'SliderStep'     ,[1/36,12/36],...
        'Value'          ,0,...
        'Visible'        ,'off',...
        'TooltipString'  ,'Select upper boundary of date-range that is shown in the graph.',...
        'Callback'       ,@SliderMovement);
    
%% *** prepare output arg (if requested) ***************************************

    if nargout > 0
        % collect all handles
        handles = struct( ...
            'GUI',              hGUI, ...
            'pbDocX13',         hpbDocX13, ...
            'pbDocTBX',         hpbDocTBX, ...
            'txtVARIABLE',      htxtVARIABLE, ...
            'txtX13',           htxtX13, ...
            'edX13Name',        hedX13Name, ...
            'pbLoad',           hpbLoad, ...
            'pbSave',           hpbSave, ...
            'txtDATA',          htxtDATA, ...
            'txtDatesData', 	htxtDatesData, ...
            'edDates',          hedDates, ...
            'edData',           hedData, ...
            'puType',           hpuType, ...
            'txtTitle',          htxtTitle, ...
            'edTitle',           hedTitle, ...
            'txtFCT',           htxtFCT, ...
            'txtHorizon',       htxtHorizon, ...
            'edHorizon',        hedHorizon, ...
            'txtConfidence',    hedConfidence, ...
            'edConfidence',     hedConfidence, ...
            'txtREGR',          htxtREGR, ...
            'txtRegressors', 	htxtRegressors, ...
            'chkConst',         hchkConst, ...
            'chkTD',            hchkTD, ...
            'chkEaster',        hchkEaster, ...
            'txtAutoOutliers', 	htxtAutoOutliers, ...
            'chkAO',            hchkAO, ...
            'chkLS',            hchkLS, ...
            'chkTC',            hchkTC, ...
            'txtMoreRegressors',htxtMoreRegressors, ...
            'edMoreRegressors', hedMoreRegressors, ...
            'txtSARIMA',        htxtSARIMA, ...
            'txtTransform', 	htxtTransform, ...
            'puTransform',      hpuTransform, ...
            'edPower',          hedPower, ...
            'txtSelectModel', 	htxtSelectModel, ...
            'grSelectModel', 	hgrSelectModel, ...
            'rbPickmdl',        hrbPickmdl, ...
            'puPickmdlFile', 	hpuPickmdlFile, ...
            'puFirstBest',      hpuFirstBest, ...
            'rbTramo',          hrbTramo, ...
            'chkCheckMu',       hchkCheckMu, ...
            'chkAllowMixed', 	hchkAllowMixed, ...
            'rbManualModel', 	hrbManualModel, ...
            'edArima',          hedArima, ...
            'rbNoModel',        hrbNoModel, ...
            'txtSEAS',          htxtSEASADJ, ...
            'txtSeasType',      htxtSeasType, ...
            'puSeasType',       hpuSeasType, ...
            'puMode',           hpuMode, ...
            'chkFixed',         hchkFixed, ...
            'chkCamplet',       hchkCamplet, ...
            'txtDIAG',          htxtDIAG, ...
            'chkACF',           hchkACF, ...
            'chkSpectrum',      hchkSpectrum, ...
            'chkHistory',       hchkHistory, ...
            'chkSlidingSpans', 	hchkSlidingSpans, ...
            'txtMORESPECS',     htxtMORESPECS, ...
            'edMoreSpecs',      hedMoreSpecs, ...
            'pbRun',            hpbRun, ...
            'chkW',             hchkW, ...
            'chkN',             hchkN, ...
            'chkR',             hchkR, ...
            'chkS',             hchkS, ...
            'chkQ',             hchkQ, ...
            'tglOut',           htglOut, ...
            'puOut',            hpuOut, ...
            'pbCopy',           hpbCopy, ...
            'txtTimeOfRun',     htxtTimeOfRun, ...
            'edOut',            hedOut, ...
            'axOut',            haxOut, ...
            'slFrom',           hslFrom, ...
            'slTo',             hslTo);
    end

%% *** finalize appearance of GUI **********************************************

    % no element is adjusted automatically on resize ('units' are
    % not 'normalized')
    AllHandles = [hGUI, hpbDocTBX, hpbDocX13, htxtVARIABLE, htxtX13, ...
        hedX13Name, hpbLoad, hpbSave, htxtDATA, htxtDatesData, hedDates, ...
        hedData, hpuType, htxtTitle, hedTitle, htxtFCT, htxtHorizon, hedHorizon, ...
        hedConfidence, hedConfidence, htxtREGR, htxtRegressors, hchkConst, ...
        hchkTD, hchkEaster, htxtAutoOutliers, hchkAO, hchkLS, hchkTC, ...
        htxtMoreRegressors, hedMoreRegressors, htxtSARIMA, htxtTransform, ...
        hpuTransform, hedPower, htxtSelectModel, hgrSelectModel, hrbPickmdl, ...
        hpuPickmdlFile, hpuFirstBest, hrbTramo, hchkCheckMu, hchkAllowMixed, ...
        hrbManualModel, hedArima, hrbNoModel, htxtSEASADJ, htxtSeasType, ...
        hpuSeasType, hpuMode, hchkFixed, hchkCamplet, htxtDIAG, hchkACF, ...
        hchkSpectrum, hchkHistory, hchkSlidingSpans, htxtMORESPECS, ...
        hedMoreSpecs, hedOut, haxOut, hslFrom, hslTo, hpbRun, hchkW, hchkN, ...
        hchkR, hchkS, hchkQ, htglOut, hpuOut, hpbCopy, htxtTimeOfRun];
    set(AllHandles,'Units','pixels');
%    The following line makes ML crash when a radio button is operated:
%    set(AllHandles,'HitTest','off');    % items cannot take the focus
    resizeGUI();                        % size and position all elements
    if ~strcmp(get(hGUI,'WindowStyle'),'docked')
        movegui(hGUI,'center')  % move it to the center of the screen
    end
    CleanDialog();              % standard settings
    SpecChanged();              % initial run of SpecChanged
    % the GUI should never become the 'current figure'
    set(hGUI,'HandleVisibility','off');
    set(hGUI,'Visible','on');   % now show it
    % if requested, load a x13series object from the main workspace
    if ~isempty(loadvariable)
        fine = false;
        try
            fine = evalin('caller',sprintf('isa(%s,''x13series'')', ...
                loadvariable{1}));
        end
        if fine
            hedX13Name.String = loadvariable{1};
            LoadX13();
        end
    end

%% *** function for adjusting the GUI ******************************************

    % position all the objects of the GUI
    % all objects remain fixed, except htxtOut, haxOut, htxtTimeOfRun, and
    % hedMoreSpecs
    function resizeGUI(varargin)
        % get current position of GUI and avoid negative sizes
        p = get(hGUI,'Position'); hsizeGUI = p(3); vsizeGUI = p(4);
        
        % VARIABLE NAMES
        vpos = vsizeGUI - (vpb + sspace) - vmargin - vti;
        vpos = vpos - headvspace;    % to make some vspace to the doc buttons
        set(htxtVARIABLE , 'Position' , [hpos0,vpos,hti,vti]);
        vpos = vpos - vspace - vtx;
        set(htxtX13      , 'Position' , [hpos0,vpos,width0,vtx]);
        set(hedX13Name   , 'Position' , [hpos1,vpos,width,ved]);
        set(hpbLoad      , 'Position' , [hpos2,vpos,width,vpb]);
        set(hpbSave      , 'Position' , [hpos3,vpos,width,vpb]);
        
        % DATA
        vpos = vpos - (vspace+xspace) - vti;
        set(htxtDATA     , 'Position' , [hpos0,vpos,hti,vti]);
        vpos = vpos - vspace - vtx;
        set(htxtDatesData, 'Position' , [hpos0,vpos,width0,vtx]);
        set(hedDates     , 'Position' , [hpos1,vpos,width,ved]);
        set(hedData      , 'Position' , [hpos2,vpos,width,ved]);
        set(hpuType      , 'Position' , [hpos3,vpos,width,vpu]);
        vpos = vpos - vspace - vtx;
        set(htxtTitle     , 'Position' , [hpos0,vpos,width0,vtx]);
        set(hedTitle      , 'Position' , [hpos1,vpos,widthcol123,ved]);
        
        % FCT
        vpos = vpos - (vspace+xspace) - vti;
        set(htxtFCT      , 'Position' , [hpos0,vpos,hti,vti]);
        vpos = vpos - vspace - vtx;
        set(htxtHorizon  , 'Position' , [hpos0,vpos-3,width0,vtx]);
        set(hedHorizon   , 'Position' , [hpos1,vpos,width,vtx]);
        set(htxtConfidence,'Position' , [hpos2,vpos-3,width0,vtx]);
        set(hedConfidence, 'Position' , [hpos3,vpos,width,vtx]);

        % REGRESSION and OUTLIERS
        vpos = vpos - (vspace+xspace) - vti;
        set(htxtREGR     , 'Position' , [hpos0,vpos,hti,vti]);
        vpos = vpos - vspace - vtx;
        set(htxtRegressors,'Position' , [hpos0,vpos-3,width0,vtx]);
        set(hchkConst    , 'Position' , [hpos1,vpos,width,vtx]);
        set(hchkTD       , 'Position' , [hpos2,vpos,width,vtx]);
        set(hchkEaster   , 'Position' , [hpos3,vpos,width,vtx]);
        vpos = vpos - vspace - vtx;
        set(htxtAutoOutliers, 'Position', [hpos0,vpos-3,width0,vtx]);
        set(hchkAO       , 'Position' , [hpos1,vpos,width,vtx]);
        set(hchkLS       , 'Position' , [hpos2,vpos,width,vtx]);
        set(hchkTC       , 'Position' , [hpos3,vpos,width,vtx]);
        vpos = vpos - vspace - vtx;
        set(htxtMoreRegressors,'Position', [hpos0,vpos-3,width0,vtx]);
        set(hedMoreRegressors, 'Position', [hpos1,vpos,widthcol123,ved]);
        
        % SARIMA
        vpos = vpos - (vspace+xspace) - vti;
        set(htxtSARIMA     , 'Position', [hpos0,vpos,hti,vti]);
        vpos = vpos - vspace - vtx;
        set(htxtTransform  , 'Position', [hpos0,vpos-3,width0,vtx]);
        set(hpuTransform   , 'Position', [hpos1,vpos,width,vtx]);
        set(hedPower       , 'Position', [hpos2,vpos,width,vtx]);
        vpos = vpos - (vspace+xspace) - vtx;
        set(htxtSelectModel, 'Position', [hpos0,vpos-3,width0,vtx]);
        set(hpuPickmdlFile , 'Position', [hpos2,vpos,width,vpu]);
        set(hpuFirstBest   , 'Position', [hpos3,vpos,width,vpu]);
        vpos = vpos - vspace - vtx;
        set(hchkCheckMu    , 'Position', [hpos2,vpos,width,vpu]);
        set(hchkAllowMixed , 'Position', [hpos3,vpos,width,vpu]);
        vpos = vpos - vspace - vtx;
        set(hedArima       , 'Position', [hpos2,vpos,2*width+hspace,ved]);
        vpos = vpos - vspace - vtx;
        set(hgrSelectModel , 'Position', [hpos1,vpos,width,4*vtx+3*vspace]);
        set(hrbPickmdl     , 'Position', [0,3*(vtx+vspace),width,vtx]);
        set(hrbTramo       , 'Position', [0,2*(vtx+vspace),width,vtx]);
        set(hrbManualModel , 'Position', [0,vtx+vspace    ,width,vtx]);
        set(hrbNoModel     , 'Position', [0,0             ,width,vtx]);
        
        % SEASONAL ADJUSTMENT
        vpos = vpos - (vspace+xspace) - vti;
        set(htxtSEASADJ    , 'Position', [hpos0,vpos,hti,vti]);
        vpos = vpos - vspace - vtx;
        set(htxtSeasType, 'Position', [hpos0,vpos-3,width0,vtx]);
        set(hpuSeasType , 'Position', [hpos1,vpos,width,vpu]);
        set(hpuMode     , 'Position', [hpos2,vpos,width,vpu]);
        set(hchkFixed   , 'Position', [hpos3,vpos+(xspace),width,vpu]);
        set(hchkCamplet , 'Position', [hpos3,vpos-(xspace),width,vpu]);
        
        % DIAGNOSTICS
        vpos = vpos - (vspace+xspace) - vti;
        set(htxtDIAG    , 'Position', [hpos0,vpos,hti/2,vti]);
        vpos = vpos - vspace - vtx;
        set(hchkACF         ,'Position', [hpos0,vpos,width0,vtx]);
        set(hchkSpectrum    ,'Position', [hpos1,vpos,width ,vtx]);
        set(hchkHistory     ,'Position', [hpos2,vpos,width ,vtx]);
        set(hchkSlidingSpans,'Position', [hpos3,vpos,width ,vtx]);
        
        % MORE SPECS
        vpos = vpos - (vspace+xspace) - vti;
        set(htxtMORESPECS   ,'Position' , [hpos0,vpos,hti,vti]);
        vheight = max(1,vpos - vspace - vmargin);
        vpos = vmargin;
        set(hedMoreSpecs    ,'Position' , [hpos0,vpos,widthcol0123,vheight]);
        
        % DOCUMENTATION, FLAGS, and RUN
        vpos = vsizeGUI -vmargin - vpb;
        hpos = hpos0;
        set(hpbDocX13, 'Position', [hpos,vpos+bup,hpb,vpb]);
        hpos = hpos + sspace + hpb;
        set(hpbDocTBX, 'Position', [hpos,vpos+bup,hpb,vpb]);
        hpos = hpos + 3*sspace + hpb;
        set(hchkW,     'Position', [hpos,vpos+bup,hflag,vpb]);
        hpos = hpos + sspace + hflag;
        set(hchkN,     'Position', [hpos,vpos+bup,hflag,vpb]);
        hpos = hpos + sspace + hflag;
        set(hchkR,     'Position', [hpos,vpos+bup,hflag,vpb]);
        hpos = hpos + sspace + hflag;
        set(hchkS,     'Position', [hpos,vpos+bup,hflag,vpb]);
        hpos = hpos + sspace + hflag;
        set(hchkQ,     'Position', [hpos,vpos+bup,1.5*hflag,vpb]);
        hpos = hpos3 + width - hpb;
        set(hpbRun,    'Position', [hpos,vpos+bup,hpb,vpb]);
        
        % OUTPUT
        vpos = vsizeGUI - vmargin - vpb;
        hpos = hposR;
        set(htglOut,       'Position', [hpos,vpos+bup,1.3*hpb,vpb]);
        hpos = hpos + 1.3*hpb + sspace;
        set(hpuOut,        'Position', [hpos,vpos+bup,160,vpb]);
        hpos = hpos + 160 + sspace;
        set(hpbCopy,       'Position', [hpos,vpos+bup,hpb,vpb]);
        hpos = hpos + hpb + sspace;
        hwidth = max(1,hsizeGUI-hpos-hmargin);
        set(htxtTimeOfRun, 'Position', [hpos,vpos,hwidth,vtx]);
        % txtOut and axOut
        hpos = hposR;
        vheight = max(1,vsizeGUI-2*(vmargin+vspace)-headvspace-vpb);
        hwidth = max(1,hsizeGUI-hposR-hmargin);
        vpos = vmargin;
        set(hedOut, 'Position', [hpos,vpos,hwidth,vheight]);
        set(haxOut, 'Position', [ ...
            hpos+axLmargin, ...
            vpos+axBmargin+(vsl+vspace), ...
            max(1,hwidth-(axLmargin+axRmargin)), ...
            max(1,vheight-(axBmargin+axTmargin)-(vsl+vspace)) ...
            ]);
        set(hslFrom,'Position', [hpos                  , vpos, ...
            (hwidth-hspace)/2, vsl]);
        set(hslTo  ,'Position', [hpos+(hwidth+hspace)/2, vpos, ...
            (hwidth-hspace)/2, vsl]);
        
    end
    
%% *** callbacks ***************************************************************

    function OpenDoc(hObject,~)
        p = mfilename('fullpath');      % get direcory of the toolbox
        [docfile, ~, ~] = fileparts(p); % parse filename and path
        docfile = [docfile,filesep,'doc',filesep];
        switch hObject.String
            case 'Doc X-13'
                docfile = [docfile,'docX13as.pdf'];
            case 'Doc TBX'
                docfile = [docfile,'DocX13TBX.pdf'];
        end
        try
            winopen(docfile);
        catch e
            str = sprintf(['It is possible that you have not installed the ', ...
                'documentation. Try running\n', ...
                '     InstallMissingCensusProgram(''x13doc'')\n', ...
                'from the Matlab command window. You also need Acrobat ', ...
                'reader to view the documentation. Moreover, this ', ...
                'function works only on the Windows operation system.']);
            errordlg(sprintf(['Cannot open %s\n\n%s\n%s\n', ...
                '> In %s (line %i)\n\n%s'], docfile, e.identifier, ...
                e.message, e.stack(1).name, e.stack(1).line, str), ...
                'Cannot open documentation');
        end
    end

    function LoadX13(varargin)
        try
            x = evalin('base',hedX13Name.String);
            if ~isa(x,'x13series')
                x = x13series;
                set(htglOut,'Value' ,0);
                set(hpuOut ,'Value' ,1);
                set(htglOut,'Enable','off');
                set(hpuOut ,'Enable','off');
                PopulateMenu();
                MakeOutput();
                error('X13TBX:GUIX:WrongType', ['Variable ''%s'' is not a ', ...
                    'x13series object.'], hedX13Name.String);
            end
            hchkW.Value = ~isempty(strfind(x.flags,'-w'));
            hchkN.Value = ~isempty(strfind(x.flags,'-n'));
            hchkR.Value = ~isempty(strfind(x.flags,'-r'));
            hchkS.Value = ~isempty(strfind(x.flags,'-s'));
            hchkQ.Value = x.quiet || ~isempty(strfind(x.flags,'-q'));
            LoadX13spec(x.specgiven);
            set(htglOut,'Enable','on');
            set(hpuOut ,'Enable','on');
            PopulateMenu();
            doKeepPlotRange = true;
            MakeOutput();
        catch e
            errordlg(sprintf('%s\n%s\n> In %s (line %i)', ...
                e.identifier, e.message, e.stack(1).name, e.stack(1).line), ...
                'Error importing variable');
        end
    end

    function SaveX13(varargin)
        try
%            assignin('caller', hedX13Name.String, x);
            assignin('base', hedX13Name.String, x);
            set(hpbSave,'Enable','off');
            fprintf('(variable ''%s'' assigned)\n', hedX13Name.String);
        catch e
            errordlg(sprintf('%s\n%s\n> In %s (line %i)', ...
                e.identifier, e.message, e.stack(1).name, e.stack(1).line), ...
                'Error exporting variable');
        end
    end

    function SetR(varargin)
        if hchkR.Value              % -r is not compatible with -w and -n
            hchkW.Value = false;
            hchkN.Value = false;
        end
        SpecChanged(varargin);
    end
        
    function SetW(varargin)
        if hchkW.Value              % -r is not compatible with -w and -n
            hchkR.Value = false;
        end
        SpecChanged(varargin);
    end

    function SetN(varargin)
        if hchkN.Value              % -r is not compatible with -w and -n
            hchkR.Value = false;
        end
        SpecChanged(varargin);
    end

    function SpecChanged(varargin)
        CreateCmdLine();            % fill in cmdspec and cmdx13
        if strcmp(itemTextMenu,'command line')  % hedOut shows the command line,
            str = {['spec = ',cmdspec],[],cmdx13}; % so this needs to be updated
            set(hedOut,'String',str);           % right away
        end
        set(hpbSave,'Enable','off');
        set(hpbLoad,'Enable','off');
        if ~isempty(hedX13Name.String)
            set(hpbLoad,'Enable','on');
        end
    end

    function MenuItemChanged(varargin)
        legit = GetMenuItem();
        if legit
            if htglOut.Value                % we're in plot menu ...
                doKeepPlotRange = true;     % ... so this is a new type of graph
            end
            MakeOutput();
        end
    end

    function SliderMovement(varargin)
        hslFrom.Value = round(hslFrom.Value);
        hslTo.Value   = round(hslTo.Value);
        doKeepPlotRange = false;            % we explicitly want to change the
        MakeOutput();                       % current date-range of the plot
    end

    function Run(varargin)
        set(hpbRun,'String','working...');
        try
            % import data
%            d0 = evalin('caller',hedDates.String);
%            d1 = evalin('caller',hedData.String);
            d0 = evalin('base',hedDates.String);
            d1 = evalin('base',hedData.String);
            % create spec and x by calling the two components of the command line
%            spec = evalin('caller',cmdspec);
            spec = evalin('base',cmdspec);
            if hchkQ.Value
                x = x13([d0,d1],spec,'quiet',strFlags);
            else
                x = x13([d0,d1],spec,strFlags);
            end
            % unset 'spectrum' for non-monthly data
            if x.period ~= 12; hchkSpectrum.Value = false; end
            % enable htglOut and hpuOut
            set(htglOut,'Enable','on');
            set(hpuOut ,'Enable','on');
            % reset menu
            PopulateMenu;
            RestoreStoredMenuItem();
            % make new output
            doKeepPlotRange = true;
            MakeOutput();
            % make Run button unavailable
            set(hpbRun,'Enable','off');
            % make Export button available
            if ~isempty(hedX13Name.String)
                set(hpbSave,'Enable','on');
            end
        catch e
            errordlg(sprintf('%s\n%s\n\n%s\n> In %s (line %i)\n\n%s', ...
                cmdspec, cmdx13, e.identifier, e.stack(1).name, ...
                e.stack(1).line, e.message),'Error running x13');
            if hpuOut.Value > numel(hpuOut.String)
                hpuOut.Value = 1;
                doKeepPlotRange = true;
                MakeOutput();
            end
        end
        set(hpbRun,'String','Run');
    end

    function TogglePressed(varargin)
        PopulateMenu;                       % fill menu
        RestoreStoredMenuItem;              % get to correct position in menu
        doKeepPlotRange = true;
        MakeOutput();                       % generate and show output
    end
    
    function Copy(varargin)
        if htglOut.Value                            % chart
            hTempFig = figure('Visible','off');             % create temp figure
            set(hTempFig,'Units','pixels');                 % size it
            set(hTempFig,'Position',get(hGUI,'Position'));
            copyobj(haxOut,hTempFig);                       % copy axes to temp fig
            set(gca,'Units','pixels');                      % move axes to bottom-left corner
            s = get(hedOut,'Position');
            set(gca,'Position', [ ...
                axLmargin ...
                axBmargin ...
                s(3)-axLmargin-axRmargin ...
                s(4)-axBmargin-axTmargin ...
                ]);
            set(hTempFig,'Position',[0 0 s(3) s(4)]);       % resize temp fig
%            print(hTempFig,'-dmeta');
            hgexport(hTempFig,'-clipboard');                % place in clipboard
            delete(hTempFig);                               % clean up
        else                                        % text
            str = hedOut.String;                            % get content
            if iscell(str)                                  % deal with multiple lines      
                nrows = size(str);                          % (if cells, i.e. cmdline)
                out = '';
                for r = 1:nrows
                    out = sprintf('%s%s\n',out,str{r});
                end
                str = out;
            elseif isa(str,'char')                          % (if multiline array,
                [r,c] = size(str);                          % i.e. all other cases)
                if r > 1
                    str = [str, repmat(sprintf('\n'),r,1)]; % append linefeed to each line
                    str = reshape(str',1,r*(c+1));          % make it a single line
                end
            end
            clipboard('copy',str);                          % place in clipboard
        end
    end

%% *** create command line *****************************************************

    function CreateCmdLine()
        
        cmdx13 = ''; cmdspec = '';
        
        % cmdx13
        if ~isempty(hedDates.String) && ~isempty(hedData.String)
            % flags
            strFlags = '';
            if hchkW.Value strFlags = [strFlags,'-w ']; end
            if hchkN.Value strFlags = [strFlags,'-n ']; end
            if hchkR.Value strFlags = [strFlags,'-r ']; end
            if hchkS.Value strFlags = [strFlags,'-s ']; end
            if strcmp(strFlags,'-n -s ')
                strFlags = '';
            elseif strcmp(strFlags,'')
                strFlags = 'noflags';
            end
            strFlags = strtrim(strFlags);
            addFlags = '';
            if ~isempty(strFlags)
                addFlags = sprintf(', ''%s''', strFlags);
            end
            if hchkQ.Value
                addQuiet = ', ''quiet''';
            else
                addQuiet = '';
            end
            % command line
            if isempty(hedX13Name.String)
                cmdx13 = sprintf('x13(%s, %s, spec%s%s);', ...
                    hedDates.String, hedData.String, addQuiet, addFlags);
            else
                cmdx13 = sprintf('%s = x13(%s, %s, spec%s%s);', ...
                    hedX13Name.String, hedDates.String, hedData.String, ...
                    addQuiet, addFlags);
            end
            set(hpbRun,'Enable','on');
        else
            set(hpbRun,'Enable','off');
        end
        
        % cmdspec
        if ~isempty(hedTitle.String)
            AddStuff('series','title',hedTitle.String);
        end
        switch hpuType.Value
            case 2
                AddStuff('STOCK');
            case 3
                AddStuff('FLOW');
        end
        fHorizon = str2double(hedHorizon.String);
        if isnan(fHorizon) || fHorizon <= 0
            hedHorizon.String = '0';
            set([htxtConfidence,hedConfidence],'Enable','off');
        else
            fHorizon = round(fHorizon);
            hedHorizon.String = int2str(fHorizon);
            set([htxtConfidence,hedConfidence],'Enable','on');
            fConfidence = str2double(hedConfidence.String);
            if fConfidence == 0.95
                AddStuff('FCT');
            elseif fConfidence == 0.5
                AddStuff('FCT50');
            else
                AddStuff('FCT','forecast','probability',hedConfidence.String);
            end
            if fHorizon ~= 36
                AddStuff('forecast','maxlead',hedHorizon.String);
                AddStuff('forecast','maxback',hedHorizon.String);
            end
        end
        if hchkConst.Value;  AddStuff('CONSTANT'); end
        if hchkTD.Value;     AddStuff('TD');       end
        if hchkEaster.Value; AddStuff('EASTER');   end
        if hchkAO.Value;     AddStuff('AO');       end
        if hchkLS.Value;     AddStuff('LS');       end
        if hchkTC.Value;     AddStuff('TC');       end
        if ~hchkAO.Value && ~hchkLS.Value && ~hchkTC.Value
            AddStuff('NO OUTLIERS');
        end
        if ~isempty(hedMoreRegressors.String)
            str = hedMoreRegressors.String;
            if strfind(str,' ')
                if ~strcmp(str(1),'(')   str = ['(',str]; end
                if ~strcmp(str(end),')') str = [str,')']; end
            end
            AddStuff('regression','variables',str);
        end
        set(hedPower,'Enable','off');
        switch hpuTransform.Value
            case 2
                AddStuff('AUTO');
            case 3
                AddStuff('ADDITIVE');
            case 4
                AddStuff('MULTIPLICATIVE');
            case 5
                AddStuff('transform','function','sqrt');
            case 6
                AddStuff('transform','function','inverse');
            case 7
                AddStuff('transform','function','logistic');
            case 8
                set(hedPower,'Enable','on');
                AddStuff('transform','power',hedPower.String);
        end
        if hrbPickmdl.Value
            set(hpuFirstBest  ,'Enable','on' );
            set(hpuPickmdlFile,'Enable','on' );
            set(hchkAllowMixed,'Enable','off');
            set(hchkCheckMu   ,'Enable','off');
            set(hedArima      ,'Enable','off');
            switch hpuFirstBest.Value
                case 1
                    AddStuff('PICKBEST');
                case 2
                    AddStuff('PICKFIRST');
            end
            if hpuPickmdlFile.Value ~= 1
                AddStuff('pickmdl','file', ...
                    hpuPickmdlFile.String{hpuPickmdlFile.Value});
            end
        end
        if hrbTramo.Value
            set(hpuFirstBest  ,'Enable','off');
            set(hpuPickmdlFile,'Enable','off');
            set(hchkAllowMixed,'Enable','on' );
            set(hchkCheckMu   ,'Enable','on' );
            set(hedArima      ,'Enable','off');
            if hchkAllowMixed.Value
                AddStuff('TRAMO');
            else
                AddStuff('TRAMOPURE');
            end
            if ~hchkCheckMu.Value
                AddStuff('automdl','checkmu','no');
            end
        end
        if hrbManualModel.Value
            set(hpuFirstBest  ,'Enable','off');
            set(hpuPickmdlFile,'Enable','off');
            set(hchkAllowMixed,'Enable','off');
            set(hchkCheckMu   ,'Enable','off');
            set(hedArima      ,'Enable','on' );
            AddStuff('arima','model',hedArima.String);
        end
        if hrbNoModel.Value
            set(hpuFirstBest  ,'Enable','off');
            set(hpuPickmdlFile,'Enable','off');
            set(hchkAllowMixed,'Enable','off');
            set(hchkCheckMu   ,'Enable','off');
            set(hedArima      ,'Enable','off');
        end
        switch hpuSeasType.Value
            case 1
%                AddStuff('ESTIMATE');
                set(hpuMode,'Enable','off');
            case 2
                AddStuff('X11');
                set(hpuMode,'Enable','on' );
                switch hpuMode.Value
                    case 2
                        AddStuff('x11','mode','add');
                    case 3
                        AddStuff('x11','mode','mult');
                    case 4
                        AddStuff('x11','mode','pseudoadd');
                    case 5
                        AddStuff('x11','mode','logadd');
                end
            case 3
                AddStuff('SEATS');
                set(hpuMode,'Enable','off');
        end
        if hchkFixed.Value;        AddStuff('FIXEDSEASONAL'); end
        if hchkCamplet.Value;      AddStuff('CAMPLET');       end
        if hchkACF.Value;          AddStuff('ACF');           end
        if hchkSpectrum.Value;     AddStuff('SPECTRUM');      end
        if hchkHistory.Value;      AddStuff('HISTORY');       end
        if hchkSlidingSpans.Value; AddStuff('SLIDINGSPANS');  end
        if ~isempty(strtrim(hedMoreSpecs.String))
            str = hedMoreSpecs.String;
            strkeep = str;
            str = strrep(str,'  ',' ');     % remove double spaces
            str = strrep(str,'''''','''');  % remove double quotes
            str = strrep(str,'''{','{');    % replace '{ with {
            str = strrep(str,'}''','}');    % replace }' with }
            while ~strcmp(str,strkeep)
                strkeep = str;
                str = strrep(str,'  ',' ');     % remove double spaces
                str = strrep(str,'''''','''');  % remove double quotes
                str = strrep(str,'''{','{');    % replace '{ with {
                str = strrep(str,'}''','}');    % replace }' with }
            end
%             while strcmp(str(end-1:end),', ')   % remove empty entries at the end
%                 str(end-1:end) = [];
%             end
            hedMoreSpecs.String = str;
            % deal with multiple lines
            [r,c] = size(str);
            if iscellstr(str)
                str = strjoin(str,', ');
            else
                if r > 1
                    str = [str, repmat(sprintf(','),r,1)]; % append comma to each line
                    str = reshape(str',1,r*(c+1));         % make it a single line
                    str(end) = [];                         % remove last comma
                end
            end
            % add to spec string
            AddStuff(str,'no_quotes');
        end
        
        cmdspec = strrep(cmdspec,',  ',', ');   % remove double spaces after commas
        cmdspec = strrep(cmdspec,', ,',', ');   % remove empty entries in the middle
        compare = cmdspec;
        while ~isequal(compare,cmdspec)
            compare = cmdspec;
            cmdspec = strrep(cmdspec,',  ',', ');   % remove double spaces after commas
            cmdspec = strrep(cmdspec,', ,',', ');   % remove empty entries in the middle
        end
        while strcmp(cmdspec(end-1:end),', ')   % remove empty entries at the end
            cmdspec(end-1:end) = [];
        end
        try
            if strcmp(cmdspec(end-2:end),',  ')
                cmdspec(end-2:end) = [];
            end
        end
        cmdspec = sprintf('makespec(%s);',cmdspec);
        
        % --- add entries to the spec ------------------------------------------
        function AddStuff(varargin)
            % Normally, each entry is surrounded by quotes before being added to
            % the cmdspec variable. The option 'no_quotes' as last argument
            % makes that this is not done.
            if strcmp(varargin{end},'no_quotes')
                varargin(end) = [];
                fmt = repmat('%s, ',[1,numel(varargin)]);
            else
                fmt = repmat('''%s'', ',[1,numel(varargin)]);
            end
            fmt = ['%s',fmt];
            cmdspec = sprintf(fmt, cmdspec, varargin{:});
        end
        
    end

%% *** populate out menu *******************************************************

    % extract lists of items in x13series object
    function [tbl,txt,ts,other] = GetAllItems()
        % tables
        tbl = fieldnames(x.tbl)';
        % text items and variables
        allprop = x.listofitems;
        types = NaN(numel(allprop),1);
        for t = 1:numel(types)
            [~,types(t)] = x.descrvariable(allprop{t});
        end
        keep = (types == 0); txt = allprop(keep);
        keep = (types == 1); ts = allprop(keep);
        keep = (types > 1);  other = allprop(keep);
        rem_vrbl = {'dat','d8','d10','d11','d12','d13','d16', ...
            's8','s10','s11','s12','s13','s16','e2','e3', ...
            'tr','sa','sf','ir','si','hol','td','ao','tc','ls', ...
            'fct','bct','rsd','sp0','sp1','sp2','spr','st0', ...
            'st1','st2','str','s1s','s2s','t1s','sfs','acf','pcf','ac2', ...
            'chs','ycs','sae','sar','csa','csf'};
        remove = ismember(ts   ,rem_vrbl); ts(remove)    = [];
        remove = ismember(other,rem_vrbl); other(remove) = [];
    end

    % fill hpuOut popup menu
    function PopulateMenu()
        [tbl,txt,ts,other] = GetAllItems();
        if htglOut.Value                    % chart
            if ~isempty(ts);    ts    = [hline,ts];    end
            if ~isempty(other); other = [hline,other]; end
            menu = ['data','seasonally adjusted (SA)','trend (TR)', ...
                'forecast','SF by period','seasonal breaks', ...
                'seasonal factors (SF)','combined adjustments', ...
                'holidays adjustments','trading day adjustments', ...
                'outliers','irregular','residuals', ...
                'ACF','PACF','ACF squared','spectrum of data', ...
                'spectrum of residuals','spectrum of adjusted series', ...
                'spectrum of mod. irregular','revisions','% revisions', ...
                'sliding spans of SF','sl sp of SF, max diff', ...
                'sliding spans of SA','sl sp of SA, max diff', ...
                'sliding spans % yoy of SA','sl sp % yoy of SA, max diff', ...
                ts, other];
        else                                % text
            if isempty(x.listofitems)
                menu = {'command line'};
            else
                menu = [{'command line'},{'messages'}, ...
                    {'x13series object'},{'x13spec object'}, ...
                    hline,tbl,hline,txt];
            end
        end
        if hpuOut.Value > numel(menu); hpuOut.Value = 1; end
        hpuOut.String = menu;
    end

    % make sure menu entry is not a separator line; store itemTextMenu or
    % itemPlotMenu, respectively
    function legit = GetMenuItem()
        legit = ~strcmp(hpuOut.String{hpuOut.Value},hline);
        if ~legit                   % it's a separator line
            RestoreStoredMenuItem();
        else
            if htglOut.Value        % update itemTextMenu or itemPlotMenu
                itemPlotMenu = hpuOut.String{hpuOut.Value};
            else
                itemTextMenu = hpuOut.String{hpuOut.Value};
            end
        end
    end

    % set menu item to stored last entries of text or plot menu, respectively
    function RestoreStoredMenuItem()
        if htglOut.Value
            idx = find(ismember(hpuOut.String,itemPlotMenu));
        else
            idx = find(ismember(hpuOut.String,itemTextMenu));
        end
        if isempty(idx); idx = 1; end
        hpuOut.Value = idx;     % set position in menu to stored entry
    end

%% *** make output in hedOut or haxOut *****************************************

    % fill in htxtOut or haxOut, respectively
    function MakeOutput()
        % report time of run of current x13series
        if isempty(x.timeofrun{2})
            htxtTimeOfRun.String = '';
        else
            str = sprintf('%s (%3.1f sec)\n', ...
            datestr(x.timeofrun{1}), x.timeofrun{2});
            htxtTimeOfRun.String = str;
        end
        % make output in edOut or axOut, respectively
        out = hpuOut.String{hpuOut.Value};      % selected position in menu item
        [tbl,txt,ts,other] = GetAllItems;
        %
        % --- axes -------------------------------------------------------------
        if htglOut.Value
            set(hedOut ,'Visible','off');
            set(haxOut ,'Visible','on' );
            % composite?
            isComposite = ismember('composite',fieldnames(x.spec));
            slidersOn = true;
            vrbl = {'NA'};
            args = {};
            switch out
                case 'data'
                    if ~isComposite
                        vrbl = {'dat'};
                    else
                        vrbl = {'cms'};
                    end
                case 'seasonally adjusted (SA)'
                    switch hpuSeasType.Value
                        case 2
                            vrbl = {'d11','e2'};
                        case 3
                            vrbl = {'s11'};
                    end
                    if isComposite
                        vrbl = [vrbl,{'isa'}];
                    end
                    if hchkFixed.Value
                        vrbl = [vrbl,{'sa'}];
                    end
                    if hchkCamplet.Value
                        vrbl = [vrbl,{'csa'}];
                    end
                case 'trend (TR)'
                    switch hpuSeasType.Value
                        case 2
                            vrbl = {'d12'};
                        case 3
                            vrbl = {'s12'};
                    end
                    if isComposite
                        vrbl = [vrbl,{'itn'}];
                    end
                    if hchkFixed.Value
                        vrbl = [vrbl,{'tr'}];
                    end
                case 'forecast'
                    switch hpuSeasType.Value
                        case 1
                            vrbl = {'dat','sa','tr','fct','bct'};
                        case 2
                            vrbl = {'dat','d11','d12','fct','bct'};
                        case 3
                            vrbl = {'dat','s11','s12','fct','bct'};
                    end
                case 'seasonal factors (SF)'
                    switch hpuSeasType.Value
                        case 2
                            vrbl = {'d10'};
                        case 3
                            vrbl = {'s10'};
                    end
                    if hchkFixed.Value
                        vrbl = [vrbl,{'sf'}];
                    end
                    if hchkCamplet.Value
                        vrbl = [vrbl,{'csf'}];
                    end
                case 'SF by period'
                    slidersOn = false;
                    switch hpuSeasType.Value
                        case 1
                            vrbl = {'sf','csf'};  args = {'byperiod'};
                        case 2
                            vrbl = {'d10'}; args = {'byperiod'};
                        case 3
                            vrbl = {'s10'}; args = {'byperiod'};
                    end
                case 'seasonal breaks'
                    slidersOn = false;
                    if all(ismember({'d10','d8'},x.listofitems))      % X-11
                        vrbl = {'d10','d8'};
                    elseif all(ismember({'s10','s8'},x.listofitems))  % SEATS
                        vrbl = {'s10','s8'};
                    elseif all(ismember({'s10','s13'},x.listofitems)) % SEATS but s8 missing
                        if x.isLog
                            s8 = x.s10.s10 .* x.s13.s13;
                            x.addvariable('s8',x.s10.dates,s8,'s8',1, ...
                                'SEATS s10 * s13 (= SI)');
                        else
                            s8 = x.s10.s10 + x.s13.s13;
                            x.addvariable('s8',x.s10.dates,s8,'s8',1, ...
                                'SEATS s10 + s13 (= SI)');
                        end
                        vrbl = {'s10','s8'};
                    elseif all(ismember({'sf','si'},x.listofitems))   % fixedseas
                        vrbl = {'sf','si'};
                    end
                    args = {'byperiodnomean'};
                case 'holidays adjustments'
                    vrbl = {'hol'};
                case 'trading day adjustments'
                    vrbl = {'td'};
                case 'outliers'
                    vrbl = {'ao','ls','tc'};
                case 'combined adjustments'
                    switch hpuSeasType.Value
                        case 2
                            vrbl = {'d16'};
                        case 3
                            vrbl = {'s16'};
                    end
                     if isComposite
                        vrbl = [vrbl,{'iaf'}];
                    end
               case 'irregular'
                    switch hpuSeasType.Value
                        case 2
                            vrbl = {'d13','e3'};
                        case 3
                            vrbl = {'s13'};
                    end
                    if isComposite
                        vrbl = [vrbl,{'iir'}];
                    end
                    if hchkFixed.Value
                        vrbl = [vrbl,{'ir'}];
                    end
                case 'residuals'
                    vrbl = {'rsd'};
                case 'ACF'
                    slidersOn = false;
                    vrbl = {'acf'};
                case 'PACF'
                    slidersOn = false;
                    vrbl = {'pcf'};
                case 'ACF squared'
                    slidersOn = false;
                    vrbl = {'ac2'};
                case 'spectrum of data'
                    slidersOn = false;
                    vrbl = {'sp0','st0'};
                    if isComposite
                        vrbl = [vrbl,{'is0'},{'it0'}];
                    end
                case 'spectrum of residuals'
                    slidersOn = false;
                    vrbl = {'spr','str'};
                case 'spectrum of adjusted series'
                    slidersOn = false;
                    switch hpuSeasType.Value
                        case 2
                            vrbl = {'sp1','st1'};
                        case 3
                            vrbl = {'s1s','t1s'};
                    end
                    if isComposite
                        vrbl = [vrbl,{'is1'},{'it1'}];
                    end
                case 'spectrum of mod. irregular'
                    slidersOn = false;
                    switch hpuSeasType.Value
                        case 2
                            vrbl = {'sp2','st2'};
                        case 3
                            vrbl = {'s2s'}; % ,'t2s'};   % t2s does not look right ... (?)
                    end
                    if isComposite
                        vrbl = [vrbl,{'is2'},{'it2'}];
                    end
                case 'sliding spans of SF'
                    try
                        nsp = numel(fieldnames(x.sfs))-4;
                        vrbl = {'sfs'};
                        args = {'selection',[ones(1,nsp) 0]};
                    end
                case 'sl sp of SF, max diff'
                    try
                        nsp = numel(fieldnames(x.sfs))-4;
                        vrbl = {'sfs'};
                        args = {'selection',[zeros(1,nsp) 1]};
                    end
                case 'sliding spans of SA'
                    try
                        nsp = numel(fieldnames(x.chs))-4;
                        vrbl = {'chs'};
                        args = {'selection',[ones(1,nsp) 0]};
                    end
                case 'sl sp of SA, max diff'
                    try
                        nsp = numel(fieldnames(x.chs))-4;
                        vrbl = {'chs'};
                        args = {'selection',[zeros(1,nsp) 1]};
                    end
                case 'sliding spans % yoy of SA'                            
                    try
                        nsp = numel(fieldnames(x.ycs))-4;
                        vrbl = {'ycs'};
                        args = {'selection',[ones(1,nsp) 0]};
                    end
                case 'sl sp % yoy of SA, max diff'                            
                    try
                        nsp = numel(fieldnames(x.ycs))-4;
                        vrbl = {'ycs'};
                        args = {'selection',[zeros(1,nsp) 1]};
                    end
                case 'revisions'
                    vrbl = {'sae'};
                case '% revisions'
                    vrbl = {'sar'};
                case ts
                    vrbl = {out};
                case other
                    slidersOn = false;
                    vrbl = {out};
            end
            if slidersOn
                set(hslFrom,'Visible','on' );
                set(hslTo  ,'Visible','on' );
                if isnan(vecFirstDate)     % very first plot request since start
                    SetSliderLimits(vrbl);
                    GetSliders();
                elseif doKeepPlotRange
                    SetSliderLimits(vrbl); 
                    SetSliders();
                else
                    GetSliders();
                end
                opt = {'fromdate',datenum(vecFromDate), ...
                    'todate',datenum(vecToDate), ...
                    'options',{'linewidth',1},'quiet'};
            else
                set(hslFrom,'Visible','off');
                set(hslTo  ,'Visible','off');
                opt = {'options',{'linewidth',1},'quiet'};
            end
            cla(haxOut,'reset');                % clear content from axis
            if numel(vrbl) == 1 || ismember(vrbl{1},{'sfs','chs','ycs'})
                plot(haxOut,x,vrbl{:},args{:},opt{:});
            else
                plot(haxOut,x,vrbl{:},args{:},'combined',opt{:});
            end
            drawnow;
        else
        %
        % --- text -------------------------------------------------------------
            set(hedOut ,'Visible','on' );
            set(haxOut ,'Visible','off');
            set(hslFrom,'Visible','off');
            set(hslTo  ,'Visible','off');
            switch out
                case 'command line'
                    str = {['spec = ',cmdspec],[],cmdx13};
                case 'messages'
                    str = x.showmsg;
                case 'x13series object'
                    str = dispstring(x);
                case 'x13spec object'
                    str = dispstring(x.spec);
                case tbl
                    str = x.table(out);
                case txt
                    str = x.(out);
            end
            set(hedOut,'String',str);
        end
    end

    % set min, max, and step sizes of the two sliders
    function SetSliderLimits(vrbl)
        idx = ismember(vrbl,x.listofitems);
        if any(idx)
            vrbl = vrbl(idx);
            FirstDate  = x.(vrbl{1}).dates(1);
            LastDate   = x.(vrbl{1}).dates(end);
            for v = 2:numel(vrbl)
                temp = x.(vrbl{v}).dates(1);
                if temp < FirstDate;  FirstDate = temp;  end
                temp  = x.(vrbl{v}).dates(end);
                if temp > LastDate;   LastDate = temp;   end
            end
            vecFirstDate = datevec(FirstDate); vecFirstDate(4:end) = [];
            vecLastDate  = datevec(LastDate);  vecLastDate(4:end)  = [];
            lengthData = x.period*(vecLastDate(1)-vecFirstDate(1)) + ...
                (vecLastDate(2)-vecFirstDate(2)*(x.period/12));
            hslFrom.SliderStep = [1/lengthData,x.period/lengthData];
            hslFrom.Max        = lengthData;
            hslTo.SliderStep   = [1/lengthData,x.period/lengthData];
            hslTo.Min          = -lengthData;
        else
            hslFrom.Visible = 'off';
            hslTo.Visible   = 'off';
        end
    end

    % set value of the two sliders to correspond to current date range
    function SetSliders()
        if datenum(vecFromDate) > datenum(vecLastDate) || ...
                datenum(vecToDate) < datenum(vecFirstDate)
            % incompatible date range (the user has estimates using some date
            % range, and then estimates again using a new date range that is
            % imcompatible with the first date range)
            hslFrom.Value = 0; vecFromDate = vecFirstDate;
            hslTo.Value   = 0; vecToDate   = vecLastDate;
        else
            % hslFrom
            diff = vecFromDate - vecFirstDate;
            value = x.period*diff(1) + diff(2)*(x.period/12);
            value = min(value, hslFrom.Max);
            value = max(value, hslFrom.Min);
            if value > hslFrom.Max
                hslFrom.Value = hslFrom.Max;
            else
                hslFrom.Value = value;
            end
            % hslTo
            diff = vecToDate - vecLastDate;
            value = x.period*diff(1) + diff(2)*(x.period/12);
            value = min(value, hslTo.Max);
            value = max(value, hslTo.Min);
            if value < hslTo.Min;
                hslTo.Value = hslTo.Min;
            else
                hslTo.Value = value;
            end
        end
    end

    % compute current date range from position of sliders
    function GetSliders()
        vecFromDate = addMonth(vecFirstDate,hslFrom.Value*(12/x.period));
        vecToDate   = addMonth(vecLastDate ,hslTo.Value  *(12/x.period));
    end

    % add (or subtract) a number of months from a date
    % (always returns first or last day of month)
    function thedate = addMonth(thedate,n)
        if numel(thedate) == 1
            thedate = datevec(thedate);
        end
        ym = 12*thedate(1) + (thedate(2)-1) + n;
        m = mod(ym,12)+1;
        y = (ym-(m-1))/12;
        if thedate(3) < 15
            d = 1;
        else
            d = eomday(y,m);
        end
        thedate = [y,m,d];
    end

    % assign the proper settings to the dialog to replicate the given
    % specification
    function LoadX13spec(spec)
        CleanDialog();
        % composite?
        isComposite = ismember('composite',fieldnames(spec));
        % name
        if ~isComposite
            try hedTitle.String = spec.series.title;
            catch
                try hedTitle.String = spec.series.name; end
            end
            spec = x13spec(spec,'series','title',[],'series','name',[]);
        else
            try hedTitle.String = spec.composite.title;
            catch
                try hedTitle.String = spec.composite.name; end
            end
            spec = x13spec(spec,'composite','title',[],'composite','name',[]);
        end
        % dates and data
        if ~isComposite
            fromDate = x.dat.dates(1); toDate = x.dat.dates(end);
            hedDates.String = [hedX13Name.String,'.dat.dates'];
            hedData.String  = [hedX13Name.String,'.dat.dat'];
        else
            fromDate = x.cms.dates(1); toDate = x.cms.dates(end);
            hedDates.String = [hedX13Name.String,'.cms.dates'];
            hedData.String  = [hedX13Name.String,'.cms.cms'];
        end
        % stock, flow
        if ~isComposite
            s = specminus(makespec('STOCK'),spec);
            if isempty(fieldnames(s))
                hpuType.Value = 2;
            else
                s = specminus(makespec('FLOW'),spec);
                if isempty(fieldnames(s))
                    hpuType.Value = 3;
                else
                    hpuType.Value = 1;
                end
            end
        else
            s = spec.composite.type;
            if isempty(s)
                hpuType.Value = 1;
            elseif strcmpi(s,'stock')
                hpuType.Value = 2;
            elseif strcmpi(s,'flow')
                hpuType.Value = 3;
            end
            spec = x13spec(spec,'composite','type',[]);
        end
        % forecast
        s = specminus(makespec('FCT'),spec);
        try strfwd = spec.forecast.maxlead; catch e; strfwd = ''; end
        try strbwd = spec.forecast.maxback; catch e; strbwd = ''; end
        try strp = spec.forecast.probability; catch; strp = '0.95'; end
        s = specminus(makespec('FCT', ...
                'forecast','maxlead',[], ...
                'forecast','maxback',[], ...
                'forecast','probability',[]), ...
            spec);
        if isempty(fieldnames(s))
            hedHorizon.String    = strfwd;
            hedConfidence.String = strp;
        else
            hedHorizon.String    = '0';
        end
        % regression
        s = specminus(makespec('CONST'),spec);
        hchkConst.Value = isempty(fieldnames(s));
        s = specminus(makespec('TD'),spec);
        hchkTD.Value = isempty(fieldnames(s));
        s = specminus(makespec('EASTER'),spec);
        hchkEaster.Value = isempty(fieldnames(s));
        % outliers
        s = specminus(makespec('AO'),spec);
        hchkAO.Value = isempty(fieldnames(s));
        s = specminus(makespec('LS'),spec);
        hchkLS.Value = isempty(fieldnames(s));
        s = specminus(makespec('TC'),spec);
        hchkTC.Value = isempty(fieldnames(s));
        % SARIMA-Model
        try
            v = spec.transform.power;
            hpuTransform.Value = 8;
            hedPower.String = v;
        catch
            hpuTransform.Value = 1;
        end
        s = specminus(makespec('AUTO'),spec);
        if isempty(fieldnames(s))
            hpuTransform.Value = 2;
        end
        s = specminus(makespec('ADDITIVE'),spec);
        if isempty(fieldnames(s))
            hpuTransform.Value = 3;
        end
        s = specminus(makespec('MULTIPLICATIVE'),spec);
        if isempty(fieldnames(s))
            hpuTransform.Value = 4;
        end
        s = specminus(x13spec('transform','function','sqrt'),spec);
        if isempty(fieldnames(s))
            hpuTransform.Value = 5;
        end
        s = specminus(x13spec('transform','function','inverse'),spec);
        if isempty(fieldnames(s))
            hpuTransform.Value = 6;
        end
        s = specminus(x13spec('transform','function','logistic'),spec);
        if isempty(fieldnames(s))
            hpuTransform.Value = 7;
        end
        % manual model
        f = fieldnames(spec);
        if ismember('arima',f)
            try
                hrbManualModel.Value = true;
                m = spec.arima.model;
                hedArima.String = m;
            end
        else
            % pickmdl
            found = false;
            s = specminus(makespec('PICKBEST'),spec);
            if isempty(fieldnames(s))
                hrbPickmdl.Value = true;
                hpuFirstBest.Value = 1;
                found = true;
            end
            s = specminus(makespec('PICKFIRST'),spec);
            if isempty(fieldnames(s)) && ~found
                hrbPickmdl.Value = true;
                hpuFirstBest.Value = 2;
                found = true;
            end
            if found
                f = spec.ExtractRequests(spec,'pickmdl','file');
                if ~isempty(f)
                    idx = find(ismember(hpuPickmdlFile.String,f));
                    if ~isempty(idx)
                        hpuPickmdlFile.Value = idx;
                    end
                else
                    hpuPickmdlFile.Value = 1;   % use default model file
                end
            end
            % tramo
            s = specminus(makespec('TRAMO'),spec);
            if isempty(fieldnames(s))
                found = true;
                hrbTramo.Value = true;
                m = spec.ExtractRequests(spec,'automdl','mixed');
                if ismember(m,'no')
                    hchkAllowMixed.Value = false;
                else
                    hchkAllowMixed.Value = true;
                end
                c = spec.ExtractRequests(spec,'automdl','checkmu');
                if ismember(c,'no')
                    hchkCheckMu.Value = false;
                else
                    hchkCheckMu.Value = true;
                end
            end
            % no regARIMA
            if ~found
                hrbNoModel.Value = true;
            end
        end
        % seasonal adjustment
        found = false;
        s = specminus(makespec('X11'),spec);
        if isempty(fieldnames(s))
            hpuSeasType.Value = 2;
            found = true;
            m = spec.ExtractRequests(spec,'x11','mode');
            if ~isempty(m)
                m = find(ismember({'add','mult','pseudoadd','logadd'},m));
                hpuMode.Value = m+1;
            end
        end
        s = specminus(makespec('SEATS'),spec);
        if isempty(fieldnames(s)) && ~found
            hpuSeasType.Value = 3;
            found = true;
        end
        if ~found
            hpuSeasType.Value = 1;
        end
        s = specminus(makespec('FIXEDSEAS'),spec);
        if isempty(fieldnames(s))
            hchkFixed.Value = true;
        end
        s = specminus(makespec('CAMPLET'),spec);
        if isempty(fieldnames(s))
            hchkCamplet.Value = true;
        end
        % diagnostics
        s = specminus(makespec('ACF'),spec);
        hchkACF.Value = isempty(fieldnames(s));
        s = specminus(makespec('SPECTRUM'),spec);
        hchkSpectrum.Value = isempty(fieldnames(s));
        s = specminus(makespec('HISTORY'),spec);
        hchkHistory.Value = isempty(fieldnames(s));
        s = specminus(makespec('SLIDINGSPANS'),spec);
        hchkSlidingSpans.Value = isempty(fieldnames(s));
        %
        % deal with span and modelspan keys in series section
        more = [];
%         dataspan = sprintf('%i.%i', ...
%             yqmd(fromDate,'y'), yqmd(fromDate,'m'));
%         startdate = ''; try startdate = spec.series.start; end
%         if ~strcmp(startdate,dataspan) && ~isempty(startdate)
%             more = [more, {sprintf('''series'',''start'',''%s''', startdate)}];
%         end
%         dataspan = sprintf('(%i.%i, %i.%i)', ...
%             yqmd(fromDate,'y'), yqmd(fromDate,'m'), ...
%             yqmd(toDate,'y')  , yqmd(toDate,'m'));
%         modelspan = ''; try modelspan = spec.series.modelspan; end
%         if ~strcmp(modelspan,dataspan) && ~isempty(modelspan)
%             more = [more, {sprintf('''series'',''modelspan'',''%s''', ...
%                 modelspan)}];
%         end
%         span = ''; try span = spec.series.span; end
%         if ~strcmp(span,dataspan) && ~isempty(span)
%             more = [more, {sprintf('''series'',''span'',''%s''', span)}];
%         end
%         hedMoreSpecs.String = more;
        % deal with all the remaining specifications
        CreateCmdLine();
        s = evalin('caller',cmdspec);
        s = specminus(spec,s);
        % deal with additional explanatory variables in regression
        regr = s.ExtractRequests(s,'regression','variables');
        hedMoreRegressors.String = strjoin(regr,' ');
        % recreate cmdspec
        CreateCmdLine();
        s = evalin('caller',cmdspec);
        s = specminus(spec,s);
        % list of stuff that remains
        series = fieldnames(s);
        for ser = 1:numel(series)
            if isstruct(s.(series{ser}));
                keys = fieldnames(s.(series{ser}));
                for key = 1:numel(keys)
                    value = s.(series{ser}).(keys{key});
                    if iscell(value)
                        valuestr = '{';
                        for c = 1:numel(value)
                            if ~ischar(value{c});
                                valuestr = [valuestr,mat2str(value{c}),', '];
                            else
                                valuestr = [valuestr,'''',value{c},''', '];
                            end
                        end
                        value = [valuestr(1:end-2),'}'];
                    else
                        if ~ischar(value);
                            value = mat2str(value);
                        end
                    end
                    more = [more, {sprintf('''%s'',''%s'',''%s''', ...
                        series{ser},keys{key},value)}]; %#ok<AGROW>
                end
            end
        end
        hedMoreSpecs.String = more;
        CreateCmdLine();
    end

    % default state of the dialog
    function CleanDialog()
        % x13series OBJECT NAME
        % hedX13Name.String           = '';
        % DATES, DATA, and NAME
        % hedDates.String             = '';
        % hedData.String              = '';
        hedTitle.String              = '';
        hpuType.Value               = 1;        % stock or flow not specified
        % FORECAST
        hedHorizon.String           = '0';      % no forecast by default
        hedConfidence.String        = '0.95';
        % REGRESSION and OUTLIERS
        hchkConst.Value             = false;
        hchkTD.Value                = false;
        hchkEaster.Value            = false;
        hchkAO.Value                = false;
        hchkLS.Value                = false;
        hchkTC.Value                = false;
        hedMoreRegressors.String    = '';
        % SARIMA-Model selection
        hpuTransform.Value          = 2;        % automatic transformation
        hedPower.String             = '1.0';
        hrbPickmdl.Value            = false;
        hpuPickmdlFile.Value        = 1;
        hpuFirstBest.Value          = 1;
        hrbTramo.Value              = true;     % TRAMO is default
        hchkCheckMu.Value           = true;
        hchkAllowMixed.Value        = true;
        hrbManualModel.Value        = false;
        hedArima.String             = '';
        hrbNoModel.Value            = false;
        % SEASONAL ADJUSTMENT
        hpuSeasType.Value           = 2;        % seasonal adjustment with X-11
        hpuMode.Value               = 1;        % unspecified
        hchkFixed.Value             = false;    % so fixedseas by default
        % DIAGNOSTICS
        hchkACF.Value               = true;     % yes
        hchkSpectrum.Value          = true;     % yes
        hchkHistory.Value           = false;    % no
        hchkSlidingSpans.Value      = false;    % no
        hedMoreSpecs.String         = '';
    end

end     % --- end function
