function outData = bfrs(series, relatedSeries, p)
%BFRS Extends a series backward with a VAR(p) on a related series.
%
% outData = bfrs(series, backfillLevels) extends SERIES as far back as
% backfillLevels using the predictions of a VAR(3). Note that relatedSeries may be a
% table, in which case the VAR is simply multivariate. 
%
% outData = bfrs(series, backfillLevels, p) uses a VAR(p) for the prediction.

% David Kelley, 2018

%% Add back levels off of growth rates
assert(size(series, 2) == 1, 'BFRS extends only one series');
if nargin < 3
  p = 3;
end

mergeData = cbd.merge(series, relatedSeries);

mdl = varm(size(mergeData, 2), p);
estData = mergeData(all(~isnan(mergeData{:,:}), 2), :);
mdle = mdl.estimate(estData{:,:});
ss = varm2ssm(mdle);
fitted = ss.smooth(mergeData{:,:});

[~, seriesEnd] = cbd.last(mergeData(:,1));
outData = mergeData(:,1);
outData{1:seriesEnd,:} = fitted(1:seriesEnd,1);

end

function SSM = varm2ssm(Mdl)
% Transform a VAR model into state space representation

% P = size(Y0,1) at this point
p = Mdl.P;
k = Mdl.NumSeries;

%  Format a time-invariant state transition matrix A.
A1 = [[Mdl.AR{:}] Mdl.Constant(:)];
A2 = [eye(k*(p-1)), zeros(k*(p-1),k+1)];
A3 = [zeros(1,k*p), 1];
A  = [A1 ; A2 ; A3];

% Create the state disturbance loading matrix B.
covariance = 0.5 * (Mdl.Covariance + Mdl.Covariance');
B1 = cholcov(covariance)';
B2  = zeros(k*(p-1)+1,size(B1,2));
B = [B1; B2];

% Create the observation sensitivity matrix C.
C = [eye(k)  zeros(k,k*(p-1)+1)];

% Create the state-space model (SSM).
SSM = ssm(A, B, C, 'Mean0', [], 'Cov0', []);

end