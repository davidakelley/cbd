% SEASBREAKS (overloaded) produces a special plot showing potential seasonal breaks
%
% Usage:
%   seasbreaks(obj)
%   seasbreaks(h, obj, ...)
%   seasbreaks(h, obj, sf, si, ...)
%   seasbreaks(..., plotoptions)
%   [fh,ax] = seasbreaks(...)
%
% The plot produces a chart with one axis for each month (quarter)
% displaying the seasonal factors as lines and the SI ratios as markers.
% Normally, the lines should be relatively close to the markers. If for one
% month (quarter), the markers are all below the line, and then suddenly
% above it (or vice versa), this indicates a break in the seasonal
% structure. The function returns a handle to the figure and a matrix of
% handles to the individual axes.
%
% The program works only if
%  - the X-11 seasonal factors have been computed and 'd8' and 'd10' have
%    been saved, or
%  - the SEATS seasonal factors have been computed and 's10' and 's13' have
%    been saved, or
%  - the FIXEDSEAS seasonal factors have been computed (sf and si).
% For SEATS, a new variable will be computed. We call it s8. It is defined
% as s8 = s10 + s13.
%
% Alternatively, the variables that represent the seasonal factor and the SI
% variable can also be added as arguments manually (see third line in 'Usage'
% above).
%
% Inputs:
%   obj          An x13series object.
%   h            An optional figure handle.
%   sf           Name of variable (as string) containing a seasonal factor.
%   si           Name of variable (as string) containing an SI variable.
%   plotoptions  Any options passed on to x13series.plot.
%
% Outputs:
%   fh           A handle to the figure that is created.
%   ax           Handles to the axes in the figure.
%
% NOTE: This file is part of the X-13 toolbox.
%
% see also guix, x13, makespec, x13spec, x13series, x13composite, 
% x13series.plot,x13composite.plot, x13series.seasbreaks,
% x13composite.seasbreaks, fixedseas, camplet, spr, InstallMissingCensusProgram
%
% Author  : Yvan Lengwiler
% Version : 1.30
%
% If you use this software for your publications, please reference it as
%   Yvan Lengwiler, 'X-13 Toolbox for Matlab, Version 1.30', Mathworks File
%   Exchange, 2016.

% History:
% 2017-01-09    Version 1.30    First release featuring camplet. Added the
%                               option to provide variables for sf and si
%                               manually.
% 2016-07-10    Version 1.17.1  Improved guix. Bug fix in x13series relating to
%                               fixedseas.
% 2016-07-06    Version 1.17    First release featuring guix.
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
% 2015-07-21    Version 1.13.1  Common span of ordinates.
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

function [fh,ax] = seasbreaks(varargin)

    % first arg a figure handle?
    if ishghandle(varargin{1},'figure');
        fh = varargin{1};
        obj = varargin{2};
        varargin(1:2) = [];
        isFig = true;
    else
        obj = varargin{1};
        varargin(1) = [];
        isFig = false;
    end
    
    % error checking
    if ~isa(obj,'x13series')
        e = MException('X13TBX:x13series:seasbreaks:objectmissing', ...
            ['First or second argument must be a x13series object. ', ...
            '(This error should not occur! Something''s seriously messed up.)']);
        % If the TBX is correctly installed, this error should not occur,
        % because ML would not reach the seasbreaks function if no x13series
        % object is given as argument.
        throw(e);
    end
%     if ~ismember([4,12],obj.period)
%         p = obj.period;
%         warning('X13TBX:x13series:seasbreaks:must_be_monthly_or_quarterly', ...
%             ['The x13series has a period of %i. ', ...
%             'Only monthly (12) and quarterly (4) periods ', ...
%             'are supported by the requested plot type (''byperiod'').'], p);
%         return;
%     end

    % select seasonal factors and SI ratios
    
    var1 = nan;
    if numel(varargin) >= 2
        if all(ismember(varargin(1:2),obj.listofitems))     % sf and si selected
            var1 = varargin{1}; var2 = varargin{2};         % by user
            varargin(1:2) = [];
        end
    end
    if isnan(var1)
        if all(ismember({'d10','d8'},obj.listofitems))      % X-11
            var1 = 'd10'; var2 = 'd8';
        elseif all(ismember({'s10','s8'},obj.listofitems))  % SEATS
            var1 = 's10'; var2 = 's8';
        elseif all(ismember({'s10','s13'},obj.listofitems)) % SEATS, but d8 missing
            if obj.isLog
                s8 = obj.s10.s10 .* obj.s13.s13;
                obj.addvariable('s8',obj.s10.dates,s8,'s8',1, ...
                    'SEATS s10 * s13 (= SI)');
            else
                s8 = obj.s10.s10 + obj.s13.s13;
                obj.addvariable('s8',obj.s10.dates,s8,'s8',1, ...
                    'SEATS s10 + s13 (= SI)');
            end
            var1 = 's10'; var2 = 's8';
%        elseif all(ismember({'csf','csi'},obj.listofitems)) % camplet
%            var1 = 'csf'; var2 = 'csi';
        elseif all(ismember({'sf','si'},obj.listofitems))   % fixedseas
            var1 = 'sf'; var2 = 'si';
        end
    end
    
    % make the graph
    if ~isnan(var1)
        if ~isFig
            fh = figure('Name',[obj.name,' : seasonal breaks'], ...
                'Position',[206 305 869 515]);
        end
        [fh,ax] = plot(fh,obj,var2,var1,'separate', ...
            'options',{{'Marker','o','LineStyle','none', ...
            'MarkerEdgeColor','r','MarkerSize',3}, ...
            {'Color','k','LineWidth',3}}, varargin{:});
    else
        warning('X13TBX:x13series:seasbreaks:no_SA_found',['No seasonal ', ...
            'adjustment found. Cannot produce requested graph for ', ...
            'series ''%s''.'], obj.name)
        return;
    end
    
    % ensure that span of ordinate is identical across axes
    % - determine maximum span
    yspan = ylim(ax(1,1)); yspan = yspan(2)-yspan(1);
    for r = 1:size(ax,1)
        for c = 1:size(ax,2)
            candidate = ylim(ax(r,c));
            candidate = candidate(2)-candidate(1);
            if candidate > yspan; yspan = candidate; end
        end
    end
    % - set ylim of all axes
    yspan = yspan/2;
    for r = 1:size(ax,1)
        for c = 1:size(ax,2)
            yl = ylim(ax(r,c));
            yl = (yl(1)+yl(2))/2;
            ylim(ax(r,c),[yl-yspan,yl+yspan]);
        end
    end
    
    % deal with argout
    if nargout < 2
        clear ax
        if nargout < 1
            clear fh
        end
    end

end
