% ADDSPECTRUM computes the spectrum of a variable using the Signal Processing
% Toolbox and adds the result to an x13series.
%
% Usage:
%   obj.addspectrum(v,d,vname,descr);
%
% Inputs:
%   obj     An x13series object.
%   v       Variable contained in obj.
%   d       Number of differences. d=0 means that the spectrum of the data
%           itself is computed. Setting d=1 computes the spectrum of the first
%           difference of the variable.
%   vname   Name of the new variable that is created.
%   descr   Short text describing the new variable.
% 
% Example: We assume that dates and data contain the dates and the observations
% of a timeseries that will be seasonally adjusted.
%   spec = makespec('ADDITIVE','FIXEDSEAS','CAMPLET');
%   obj = x13([dates,data],spec);
%   obj.addspectrum('sa' ,1,'sfa','Spectrum of fixed seasonal adjustment');
%   obj.addspectrum('csa',1,'sca','Spectrum of camplet seasonal adjustment');
%   plot(obj,'sfa','sca','combined');
%
% NOTE: This program is part of the X-13 toolbox. It requires the Signal
% Processing toolbox as well.
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
% 2017-01-30    Version 1.30    First release featuring camplet and addspectrum,
%                               addacf, and addpcf.

function obj = addspectrum(obj,v,d,vname,descr)
    version = ver;
    ok = any(strcmp('Signal Processing Toolbox',{version.Name}));
    if ok
        if d ~= 0
            ampl = periodogram(diff(obj.(v).(v),d));
        else
            ampl = periodogram(obj.(v).(v));
        end
        freq = 0.5*(1:numel(ampl))/numel(ampl);
        s = struct( ...
            'descr'    , descr,      ...
            'type'     , 3,       ...
            'frequency', freq', ...
            'amplitude', log(ampl));
        obj = additem(obj,vname,s);
    else
        warning('X13TBX:miss_toolbox', ...
            'ADDSPECTRUM requires the Signal Process Toolbox,');
    end
end
