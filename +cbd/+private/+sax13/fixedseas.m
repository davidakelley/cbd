% FIXEDSEAS computes a simple seasonal filter.
%
% Usage:
%   s = fixedseas(data,period);
%   s = fixedseas([dates,data],period);
%   s = fixedseas(... ,transform);
%   s = fixedseas(... ,type);
%   s = fixedseas(... ,type,typearg);
%
% data must be a vector. fixedseas is NaN tolerant, meaning data can contain
% NaNs.
%
% period is a positive number which indicates the length of the seasonal
% cycle (i.e. period = 12 for monthly data, period = 7 for daily data
% having a weekly cycle, or period = 5 if the data is weekdaily).
% period can also be a positive vector. In that case, the seasonal
% filtering is performed several times, removing cycles at all desired
% frequencies.
%
% The optional arguments determine if the filtering should be done
% additively or multiplicatively, and the type of filter to use for
% computing the trend.
%
% 'transform' is one of the following:
%   'none' or 'additive'        The decomposition is done additively. This
%                               is the default.
%   'log' or 'multiplicative'   The decomposition is done multiplicatively.
%                               More precisely, the log is applied to the
%                               data, the decomposition is then applied
%                               additively, and the exponential of the
%                               result is returned.
%
% 'type' (and 'typearg') determines the type of trend. The following
% choices are possible:
%   'moving average' or 'ma'    A simple centered moving average over a
%                               range of minus period/2 lags to plus
%                               period/2 leads is computed. This is the
%                               default.
%   'detrend'                   A linear trend is fitted to the data.
%   'detrend',bp                A continuous, piecewise linear trend is
%                               fitted to the data. 'bp' is the vector of
%                               breakpoints.
%   'hp',lambda                 For the Hodrick-Prescott filter, an
%                               additional argument must be given. lambda
%                               is a smoothing parameter lambda. The
%                               greater lambda, the smoother the trend.
%   'spline',roughness          Fits a smoothing cubic spline to the data.
%                               'roughness' is a number between 0.0
%                               (straight line) and 1.0 (no smoothing), see
%                               doc csaps.
%   'polynomial',degree         Fit a polynomial of specified degree to the
%                               data, see doc polyfit.
%
% The program will select default values if 'lambda','roughness', or
% 'degree', respectively, if you do not specify them. If you use a vector
% for the 'period' argument (filtering out multiple periods), then you can
% also specify vectors of lambda/roughness/degree-arguments, one for each
% component of your period-vector.
%
% s is a struct with the following fields:
%   .dat        The original data.
%   .dates      The original dates. If none were provided, this is just a vecor
%               counting from 1 to the number of data points.
%   .transform  Either 'none' or 'log'.
%   .type       'moving average', 'detrend', 'detrend, bp = dates',
%               'hp, lambda = number', 'cubic spline, roughness = number',
%               or 'polynomial, degree = number'
%   .period     Period(s) that has/have been filtered.
%   .tr         Long term trend (by default the moving average, but other
%               choices are possible, see above).
%   .sa         Seasonally adjusted series (= dat – sf, or exp(dat – sf),
%               respectively).
%   .sf         Seasonal factors.
%   .ir         Irregular (= sa – tr or exp(sa – tr), respectively).
%
% Data is decomposed into the three components, trend (tr), seasonal factor
% (sf), and irregular (ir). For the additive decomposition, it is always
% the case that data = tr + sf + ir. Furthermore, sa = data - sf (or
% equivalently, sa = tr + ir). For the multiplicative decomposition, data =
% tr * sf * ir, and sa = data ./ sf (or equivalently, sa = tr * ir).
%
% Example 1:
%   truetrend = 0.02*(1:200)' + 5;
%   % truecycle = sin((1:200)'*(2*pi)/20);
%   truecycle = repmat([zeros(7,1);-0.6;zeros(11,1);0.9],ceil(200/20),1);
%   truecycle = truecycle(1:200);
%   truecycle = truecycle - mean(truecycle);
%   trueresid = 0.2*randn(200,1);
%   data = truetrend + truecycle + trueresid;
%   s = fixedseas(data,20);
%   figure('Position',[78 183 505 679]);
%   subplot(3,1,1); plot([s.dat,s.sa,s.tr,truetrend]); grid on;
%   title('unadjusted and seasonally adjusted data, estimated and true trend')
%   subplot(3,1,2); plot([s.sf,truecycle]); grid on;
%   title('estimated and true seasonal factor')
%   subplot(3,1,3); plot([s.ir,trueresid]); grid on;
%   title('estimated and true irregular')
%   legend('estimated','true values');
%
% Example 2 (multiple cycles):
%   truecycle2 = 0.7 * sin((1:200)'*(2*pi)/14);
%   data = truetrend + truecycle + truecycle2 + trueresid;
%   s = fixedseas(data,[14,20],'hp');
%   figure('Position',[78 183 505 679]);
%   subplot(3,1,1); plot([s.dat,s.sa,s.tr,truetrend]); grid on;
%   title('unadjusted and seasonally adjusted data, estimated and true trend')
%   subplot(3,1,2); plot([s.sf,truecycle+truecycle2]); grid on;
%   title('estimated and true seasonal factor')
%   subplot(3,1,3); plot([s.ir,trueresid]); grid on;
%   title('estimated and true irregular')
%   legend('estimated','true values');
%
% Note that fixedseas(data,[14,20]) is not the same as
% fixedseas(data,[20,14]). The filters are applied iteratively, from left
% to right. The ordering matters, so the results differ.
%
% Detailed description of the model: Let x be some timeseries. As an
% example, we compute fixedseas(x,6).
% *** STEP 1 ***
% We compute a 6-period centered moving average,
%   trend(t) = sum(0.5x(t-3)+x(t-2)+x(t-1)+x(t)+x(t+1)+x(t+2)+0.5x(t+3))/6
% The weights on the extreme values of the window are adapted so that the
% sum of the weights is equal to period. So, for instance, if period = 7,
% the weight on x(t-3) and x(t+3) would be 1.0; if period = 6.5, the weight
% would be 0.75.
% [Note: By default the trend is computed as the centered moving average,
% and this is what is explained here. Other specifications are possible,
% namely detrend, hodrick-prescott, spline, and polynomial.]
% *** STEP 2 ***
% Compute the individual deviations of x from the trend,
%   d = x - trend.
% *** STEP 3 ***
% Compute the average deviation over all observations on a cycle of 6
% periods,
%   m(1) = mean(d(1) + d(7) + d(13) + d(19) + ...)
%   m(2) = mean(d(2) + d(8) + d(14) + d(20) + ...)
%   ...
%   m(6) = mean(d(6) + d(12) + d(18) + d(24) + ...)
% *** STEP 4 ***
% Normalize m so that its average is zero,
%   n = (m(1)+m(2)+...+m(6))/6
%   sf(1) = m(1) - n, sf(2) = m(2) - n, ..., sf(6) = m(6) - n
% These are the seasonal factors.
% *** STEP 5 ***
% Compute the seasonally adjusted time series as sa = x - sf.
% *** STEP 6 ***
% Compute the irregular as ir = sa - trend. This is the part of the
% fluctuations of x that is not explained by the seasonal factors or the
% trend (= moving average).
%
% STEP 1 as described here is for the 'moving averqage' trend type, which
% is the default. This step is different for the different trend types
% that are available. STEP 2 to 6 are, however, independent of the type of
% trend that is computed.
%
% If the multiplicative option is used, the logarithm of the data is
% processed and the exponential of the processed time series is returned.
% So, s = fixedseas(data,period,'log') is materially the same as
% s2 = fixedseas(log(data),period). Then, exp(s2.sa) = s.sa,
% exp(s2.sf) = s.sf, and exp(s2.tr) = s.tr.
%
% NOTE: This program is part of the X-13 toolbox, but it is completely
% independent of the Census X-13 program. It uses a much simpler strategy
% to filter seasonal cycles. The only advantage over the X-13 program is
% that fixedseas can be used for data with arbitrary frequency, weekly,
% daily, hourly, whatever. The X-13 program can only be used with monthly
% or quarterly data (the SEATS specification supports a few more
% frequencies). This program is just a small addition to the toolbox that
% makes it more complete.
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
% 2017-01-09    Version 1.30    First release featuring camplet.
% 2016-09-06    Version 1.18.4  breakpoints of detrend method are now given as
%                               datevectors (not as indexes indicating the
%                               positions of the breaks) if dates are given by
%                               the user.
% 2016-09-05    Version 1.18.3  Multiple tr, ir, and si when multiple periods
%                               are selected.
% 2016-07-10    Version 1.17.1  Improved guix. Bug fix in x13series relating to
%                               fixedseas.
% 2016-07-06    Version 1.17    First release featuring guix. Bug fix in the
%                               computation of 'ir' when decomposition is
%                               multiplicative.
% 2016-03-03    Version 1.16    Adapted to X-13 Version 1.1 Build 26.
% 2015-08-20    Version 1.15    Significant speed improvement. The imported
%                               time series will now be mapped to the first
%                               day of month if this is the case for the
%                               original data as well. Otherwise, they will
%                               be mapped to the last day of the month. Two
%                               new options --- 'spline' and 'polynomial'
%                               --- for fixedseas. Improvement of .arima,
%                               bugfix in .isLog.
% 2015-08-14    Version 1.14.2  Added 'spline' and 'polynomial' trend
%                               types. Added default typearg values for all
%                               trend types.
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
% 2015-05-21    Version 1.12    Several improvements: Ensuring backward
%                               compatibility back to 2012b (possibly
%                               farther); Added 'fixedseas' option to x13;
%                               Added Runsfixedseas to x13series; other
%                               improvements throughout. Changed numbering
%                               of versions to be in synch with FEX's
%                               numbering.
% 2015-05-18    Version 1.6.1   removed epanechnikov option (it was stupid
%                               to begin with)
% 2015-04-28    Version 1.6     x13as V 1.1 B 19
% 2015-03-13    Version 1.4     'detrend' with break points added
% 2015-02-14    Version 1.3     'detrend' and 'HP' are now NaN-tolerant
% 2015-02-03    Version 1.2     support for Epanechnikov, Hodrick-Prescott,
%                               and detrend
% 2015-01-30    Version 1.1     support for fractional period argument and
%                               for multiplicative decomposition
% 2015-01-26    Version 1.0d    residuals called .rsd now
% 2015-01-25    Version 1.0c    improved help
% 2015-01-24    Version 1.0b    small bugfix
% 2015-01-22    Version 1.0     first version

function s = fixedseas(data,period,varargin)

    % store original shape
    [row,col] = size(data);
    if min(row,col) > 2
        err = MException('X13TBX:fixedseas:NoVector', ...
            'fixedseas expects a vector, but you have provided a %ix%i array.', ...
            row, col);
        throw(err);
    elseif min(row,col) == 2
        if row == 2
            dates = data(1,:);
            data  = data(2,:);
            row = 1;
        else
            dates = data(:,1);
            data  = data(:,2);
            col = 1;
        end
    else
        dates = (1:numel(data))';
    end
    assert(isnumeric(period) && all(period > 0), ...
        'X13TBX:fixedseas:IllegalPeriod', ...
        'The second argument of fixedseas must be a positive number or vector.');
    % program works with column vector
    data = data(:);

    % check optional arguments
    isLog = false; TrendType = 'moving average'; secondArg = NaN;
    legal = {'ma','moving average','epanechnikov','hp','detrend', ...
        'spline','polynomial', ...
        'none','additive','logarithmic','multiplicative'};
    remove = cellfun(@(c) isempty(c),varargin);
    varargin(remove)= [];
    while ~isempty(varargin)
        validstr = validatestring(varargin{1},legal);
        loc = ismember(legal,validstr);
        if any(loc(1:7))    % a trendtype (from 'ma' to 'polynomial')
            TrendType = validstr;
            if numel(varargin) > 1
                if isnumeric(varargin{2})
                    secondArg = varargin{2};
                    if ~isnumeric(secondArg)
                        try
                            secondArg = str2num(secondArg);
                        end
                    end
                    varargin(2) = [];
                end
            end
        else
            isLog = any(loc(10:11));
        end
        varargin(1) = [];
    end
    
    % default secondArg
    if isnan(secondArg)
        switch TrendType
            case 'spline'
                h = period .* (dates(end)-dates(1)) / ...
                    (numel(dates)-1);
                secondArg = 1 ./ (1 + h.^3 .* period.^2 / 60);
            case 'polynomial'
                secondArg = floor(numel(dates) ./ period);
            case 'hp'
                slope = 5.91863781313348;
                absolute = -7.10636;
                secondArg = exp(absolute + slope * log(period));
        end
    end
    
    % make sure there is one secondArg for each period
    addArg = numel(period) - numel(secondArg);
    if addArg > 0 && ~strcmp(TrendType,'detrend')
        secondArg(end+1:end+addArg) = repmat(secondArg(end),1,addArg);
    end
    
    % multiplicative or additive
    if isLog
        assert(all(data(~isnan(data)) > 0), ...
            'X13TBX:fixedseas:NegLog', ['Data must be strictly positive ', ...
            'for multiplicative transformation.']);
        data = log(data);
    end

    % now cycle through the periods
    if strcmp(TrendType,'detrend')  % pass all secondArgs to all period-cycles if type is 'detrend'
        [sa,sf,tr,ir,si] = ...
            seas1period(dates,data,period(1),TrendType,secondArg);
        for p = 2:numel(period)
            [sa,sfnew,trnew,irnew,sinew] = ...
                seas1period(dates,sa,period(p),TrendType,secondArg);
            tr = [tr,trnew];
            ir = [ir,irnew];
            si = [si,sinew];
            sf = sf + sfnew;
        end
    else                            % pass secondArgs consecutively with all other trend types 
        [sa,sf,tr,ir,si] = ...
            seas1period(dates,data,period(1),TrendType,secondArg(1));
        for p = 2:numel(period)
            [sa,sfnew,trnew,irnew,sinew] = ...
                seas1period(dates,sa,period(p),TrendType,secondArg(p));
            tr = [tr,trnew];
            ir = [ir,irnew];
            si = [si,sinew];
            sf = sf + sfnew;
        end
    end
%    ir = repmat(sa,1,numel(period)) - tr;
%    si = sf + ir;
    % un-log?
    if isLog
        data = exp(data);
        tr   = exp(tr);
        sa   = exp(sa);
        sf   = exp(sf);
        ir   = exp(ir);
        transform = 'log';
    else
        transform = 'none';
    end
    % bring back into shape of input
    switch TrendType
        case 'hp'
            TrendType = sprintf('hp, lambda = %s',mat2str(secondArg));
        case 'spline'
            TrendType = sprintf('cubic spline, roughness = %s',mat2str(secondArg));
        case 'polynomial'
            TrendType = sprintf('polynomial, degree = %s',mat2str(secondArg));
        case 'detrend'
            if isnan(secondArg)
                TrendType = 'detrend';
            else
                TrendType = sprintf('detrend, bp = %s',mat2str(secondArg));
            end
    end
    data = reshape(data,row,col);
    tr   = reshape(tr,row,col*numel(period));
    sa   = reshape(sa,row,col);
    sf   = reshape(sf,row,col);
    ir   = reshape(ir,row,col*numel(period));
    s = struct('dat',data, 'dates',dates, 'transform',transform, ...
        'type',TrendType, 'period',period, 'tr',tr, 'sa',sa, 'sf',sf, 'ir',ir);

% compute seasonal adjustemnt for just one period
function [sa,sf,tr,ir,si] = seas1period(dates,data,period,TrendType,secondArg)

    % STEP 1
    % compute the trend
    tr = nan(size(data));
    laglead = ceil((period-1)/2);
    
    switch TrendType
        
        case {'moving average','ma'}
            data = fillholes(data);     % this is not strictly necessary,
                                        % but the result looks much more
                                        % believable
            mult = (period - (2*laglead-1)) / 2;
            w = [mult; ones(2*laglead-1,1); mult];
%            for z = laglead+1:numel(data)-laglead
%                d = data(z-laglead:z+laglead);
%                tr(z) = wmean(d,w);
%            end
            for z = 1:numel(data)
                thisw = w;
                fromIdx = z-laglead;
                toIdx = z+laglead;
                if fromIdx < 1
                    thisw = thisw(2-fromIdx:end);
                    fromIdx = 1;
                end
                if toIdx > numel(data)
                    thisw = thisw(1:end-(toIdx-numel(data)));
                    toIdx = numel(data);
                end
                d = data(fromIdx:toIdx);
                tr(z) = wmean(d,thisw);
            end
            % tr = conv(data,w,'same')/sum(w); % different behavior at the edges
            
        case 'epanechnikov'
        % This is undocumented because it does not make sense in this
        % application.
        % 'epanechnikov' : Data farther away from the center are
        %                  weighted less. The Epanechnikov weighting
        %                  function (here with bandwidth = period)
        %                  is the standard function for computing
        %                  kernels.
        % This is a local regression that smoothes the data. The problem is
        % that not the whole cycle is equally weighted in this regression,
        % so that the smoothed line (or estimated trend) still contains a
        % lot of seasonality --- if the data are seasonal. This is not
        % helpful in this application. I still keep the code here, but it
        % is not advised to use the 'epanechnikov' option.
            k = -laglead:laglead;
            w = 1-(k./((period-1)/2)).^2; w = w';
            w(w<0) = 0; w = w/sum(w);
            for z = 1:numel(data)
                thisw = w;
                fromIdx = z-laglead;
                toIdx = z+laglead;
                if fromIdx < 1
                    thisw = thisw(2-fromIdx:end);
                    fromIdx = 1;
                end
                if toIdx > numel(data)
                    thisw = thisw(1:end-(toIdx-numel(data)));
                    toIdx = numel(data);
                end
                d = data(fromIdx:toIdx);
                tr(z) = wmean(d,thisw);
            end
            
        case 'hp'
            tr = hp(data,secondArg);
            
        case 'detrend'
            datafilled = fillholes(data);
            if isnan(secondArg)
                cycle = detrend(datafilled,'linear');
            else
                for b = 1:numel(secondArg);
                    idx = find(secondArg(b)<=dates,1,'first');
                    if isempty(idx)
                        secondArg(b) = NaN;
                    else
                        secondArg(b) = idx;
                    end
                end
                secondArg(isnan(secondArg)) = [];
                cycle = detrend(datafilled,'linear',secondArg);
            end
            tr = data - cycle;
            
        case 'spline'
            pp = csaps(dates,data,secondArg);
            % pp = fnxtr(pp);
            tr = fnval(pp,dates);
            
        case 'polynomial'
            [p,~,mu] = polyfit(dates,data,secondArg);
            tr = polyval(p,dates,[],mu);
            
    end
    
    % STEP 2
    % The seasonal difference (tau) is data minus trend
    tau = data - tr;
    
    % STEP 3
    % Reorganize this as an array with period rows. (We add NaNs in the
    % beginning of the sample if mod(numel(data),period) ~= 0 to be able to
    % make an array).
    p   = ceil(numel(tau)/period);  % number of cycles covered
    tau = [nan(p*ceil(period)-numel(tau),1); tau]; % pre-append NaNs
    % tau = reshape(tau,numel(tau)/p,p);
    tau = reshape(tau,[],p);
    % The seasonal factor (sf) is the average tau for a given row
    % (= period) ... 
    meantau = meanrows(tau);
    
    % STEP 4
    % ... but normalized, so that they sum to zero over all periods.
    sf = meantau - mean(meantau);
    % Repeat seasonal factor so that we get a series that is as long as the
    % data.
    sf = repmat(sf(:),p+1,1);
    sf = sf(end-numel(data)+1:end);
    
    % STEP 5
    % sa is the data corrected for the seasonal factor
    sa = data - sf;
    ir = sa - tr;
    si = data - tr;   % = sf + ir;
    
% NaN-tolerant row-wise mean
function m = meanrows(v)
    rows = size(v,1);
    m = nan(rows,1);
    for r = 1:rows
        valid = ~isnan(v(r,:));
        m(r) = mean(v(r,valid));
    end

% NaN-tolerant weighted average
function m = wmean(d,w)
    valid = ~isnan(d);
    m = sum(d(valid) .* w(valid)) / sum(w(valid));
    
% fill NaNs
function data = fillholes(data)
    if ~any(isnan(data))
        return;
    end
    x = 1:numel(data);
    valid = ~isnan(data);
    fill = interp1(x(valid),data(valid),x(~valid));
    data(~valid) = fill;

% NaN-tolerant Hodrick-Prescott filter
function trend = hp(data,lambda)
    data = fillholes(data);
    %
    nobs = numel(data);
    %
    A = (1 + 6*lambda) * eye(nobs);
    A = A - 4*lambda*diag(ones(nobs-1,1),1);
    A = A - 4*lambda*diag(ones(nobs-1,1),-1);
    A = A + lambda*diag(ones(nobs-2,1),2);
    A = A + lambda*diag(ones(nobs-2,1),-2);
    %
    A(1, 1) = 1 + lambda;
    A(1, 2) = -2 * lambda;
    A(1, 3) = lambda;
    A(nobs,:) = fliplr(A(1,:));
    %
    A(2, 1) = -2 * lambda;
    A(2, 2) = 1 + 5 * lambda;
    A(2, 3) = -4 * lambda;
    A(2, 4) = lambda;
    A(nobs-1,:) = fliplr(A(2,:));
    %
    trend = A \ data;
