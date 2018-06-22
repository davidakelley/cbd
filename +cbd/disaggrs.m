function disaggData = disaggrs(lowFreqSeries, hiFreqSeries, type, p)
% DISAGGRS Disaggregates a series with a VAR(p) on a related series.
%
% outData = DISAGGRS(lowFreqSeries, hiFreqSeries) disaggregates lowFreqSeries to the
% frequency of hiFreqSeries using a VAR(p) at the higher frequency where the
% lower-frequency series is the aggregated version of the unobserved high-frequency series
% we take as the output.
%
% The number of lags in the VAR(p) is chosen to equal the number of high frequency periods
% in the low frequency periods (ie, 3 in a quarterly to monthly disaggregation). If
% hiFreqSeries includes multiple series, the VAR will includes more than 2 series.
%
% outData = DISAGGRS(..., type) specifies the type VAR(p) to run. The default (LEVEL) is
% to run the VAR on the levels of the data as passed. Alternatively (DIFFL), the VAR can 
% be run on the log-differences of the data before being transformed back to levels.
%
% outData = DISAGGRS(..., type, p) uses a VAR(p) for the prediction.

% David Kelley, 2018

%% Determine timing
assert(size(lowFreqSeries, 2) == 1, 'DISAGGRS only disaggregates one series at a time.');

[~, hiFPers] = cbd.private.getFreq(hiFreqSeries);
[~, loFPers] = cbd.private.getFreq(lowFreqSeries);

if nargin < 4
  p = floor(hiFPers ./ loFPers);
end
if nargin < 3
  type = 'LEVEL';
end

hiFStr = cbd.private.getFreq(hiFreqSeries);

if strcmpi(type, 'LN')
  mergeData = cbd.merge(cbd.ln(lowFreqSeries), cbd.ln(hiFreqSeries));
  roughDisaggData = cbd.ln(cbd.merge(...
    cbd.disagg(lowFreqSeries, hiFStr, 'INTERP'), ...
    hiFreqSeries));
  triangle = false; 
  accumLags = 0;

elseif strcmpi(type, 'DIFFL')
  % DIFFL multiplies by 100, correct for that:
  mergeData = cbd.merge(cbd.expression('DIFFL(%d)/100', lowFreqSeries), ...
    cbd.expression('DIFFL(%d)/100', hiFreqSeries));
  roughDisaggData = cbd.diffl(cbd.merge(...
    cbd.disagg(lowFreqSeries, hiFStr, 'GROWTH'), ...
    hiFreqSeries));
  triangle = true; 
  accumLags = floor(hiFPers ./ loFPers) - 1;
  
elseif strcmpi(type, 'LEVEL')
  mergeData = cbd.merge(lowFreqSeries, hiFreqSeries);
  roughDisaggData = cbd.merge(...
    cbd.disagg(lowFreqSeries, hiFStr, 'INTERP'), ...
    hiFreqSeries);
  triangle = false;  
  accumLags = 0;
  
else
  error('disaggrs:type', 'type must be either LEVEL, LN or DIFFL');
end
  
%% Build state space model

mdlOpts.nSeries = 1 + size(hiFreqSeries, 2);
mdlOpts.p = p;
mdlOpts.triangle = triangle;
mdlOpts.T = size(mergeData, 1);
mdlOpts.accumLags = accumLags;

parammap = @(theta) theta2mats(theta, mdlOpts);

mdl = ssm(parammap);

% Get initial values
varmdl = varm(size(mergeData, 2), p);
estData = roughDisaggData(all(~isnan(roughDisaggData{:,:}), 2), :);
vare = varmdl.estimate(estData{:,:});

phi0 = [vare.AR{:} vare.Constant(:)];
sigmaChol0 = chol(vare.Covariance, 'lower');
measurementErr0 = ones(size(hiFreqSeries, 2), 1);
theta0 = [phi0(:); sigmaChol0(tril(true(size(sigmaChol0)))); measurementErr0];

%% Estimate
warning off 'econ:statespace:estimate:SingularCov'
warning off 'MATLAB:nearlySingularMatrix'
Options = optimoptions(@fminunc,'UseParallel',true,'MaxFunctionEvaluations',5000);
mdlEst = mdl.estimate(mergeData{:,:}, theta0, 'Options', Options, 'Display', 'off');
warning on 'econ:statespace:estimate:SingularCov'
warning on 'MATLAB:nearlySingularMatrix'

%% Get smoothed estimate
fitted = mdlEst.smooth(mergeData{:,:});

if strcmpi(type, 'LN')
  disaggData = cbd.exp(mergeData(:,1));
  disaggData{:,:} = cbd.exp(fitted(:,1));
  
elseif strcmpi(type, 'DIFFL')
  % We can match the log-levels because of the way we set up the accumulator. 
  %
  % Go from log-differences back to levels so that the log-levels of the disaggregated
  % series average out to the log-level of the low-frequency series
  logDiff = mergeData(:,1);
  logDiff{:,:} = fitted(:,1);
  
  initLvl = cbd.disagg(lowFreqSeries, hiFStr, 'FILL');
  inSample = cbd.ld2lvl(cbd.trim(logDiff, 'startDate', initLvl.Properties.RowNames{1}), initLvl);

  disaggData = cbd.bfld(inSample, logDiff);
    
elseif strcmpi(type, 'LEVEL')
  disaggData = mergeData(:,1);
  disaggData{:,:} = fitted(:,1);
end

end

function [T, R, Z, Hchol] = theta2mats(theta, mdlOpts)
% Take regression parameters and map them to a state space
%
% theta is the stacked versions of [phi, sigma, measurement errors]

nPhi = mdlOpts.nSeries * (mdlOpts.p * mdlOpts.nSeries);
nConst = mdlOpts.nSeries;
nSigma = mdlOpts.nSeries * (mdlOpts.nSeries + 1) ./ 2;
nMeasurementErr = mdlOpts.nSeries - 1;

% Get parameters
phi = reshape(theta(1:nPhi), [mdlOpts.nSeries, mdlOpts.p*mdlOpts.nSeries]);

const = theta(nPhi+(1:nConst));

sigmaVec = theta(nPhi + nConst + (1:nSigma)); %#ok<BDSCI>
sigmaChol = zeros(mdlOpts.nSeries);
sigmaChol(tril(true(mdlOpts.nSeries))) = sigmaVec;

measurementErr = theta(nPhi + nConst + nSigma + (1:nMeasurementErr));

% Construct state space
% State dimension is the two latent states * number of lags for VAR and accumulator, plus
% the constant, plus the accumulator.
neededLags = max(mdlOpts.p, mdlOpts.accumLags);
nStates = neededLags * mdlOpts.nSeries + 2;

Z = [zeros(1, nStates-1) 1; 1 zeros(1, nStates-1)];
Hchol = diag([0; measurementErr]);
R = cell(mdlOpts.T, 1);
T = cell(mdlOpts.T, 1);
  
for iT = 1:mdlOpts.T
  cal = mod(iT-1, mdlOpts.p) + 1;
  
  R{iT} = [sigmaChol;
    zeros(nStates - mdlOpts.nSeries - 1, mdlOpts.nSeries);
    sigmaChol(1,:) ./ cal];
  
  phiWithZeros = [phi zeros(mdlOpts.nSeries, (neededLags - mdlOpts.p) * mdlOpts.nSeries)];
  if ~mdlOpts.triangle
    T{iT} = [phiWithZeros const zeros(mdlOpts.nSeries, 1); 
      eye(mdlOpts.nSeries * (neededLags-1)) ...
      zeros(mdlOpts.nSeries * (neededLags-1), mdlOpts.nSeries + 2);
      zeros(1, size(phiWithZeros, 2)), 1, 0;
      [phiWithZeros(1,:) const(1)]./cal (cal-1)./cal];
  else
    addLagsMat = [repmat([1 zeros(1,mdlOpts.nSeries-1)], 1, mdlOpts.accumLags) ...
      zeros(1, (neededLags - mdlOpts.accumLags) * mdlOpts.nSeries)];
    
    accumPhi = phiWithZeros (1,:) + addLagsMat;
    
    T{iT} = [phiWithZeros const zeros(mdlOpts.nSeries, 1); 
      eye(mdlOpts.nSeries * (neededLags-1)) ...
      zeros(mdlOpts.nSeries * (neededLags-1), mdlOpts.nSeries + 2);
      zeros(1, size(phiWithZeros, 2)), 1, 0;
      [accumPhi const(1)]./cal (cal-1)./cal];    
  end
end

end