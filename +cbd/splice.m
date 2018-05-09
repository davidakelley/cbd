function outData = splice(seriesA, seriesB, type)
% SPLICE Smooth between two series to create
%
% outData = SPLICE(seriesA, seriesB) creates a combined, spliced series
% from the two input seriesA and seriesB. The growth rate of both series is
% averaged and the smoothed level is returned. 

% David Kelley, 2016

if nargin < 3 || isempty(type)
  type = 'LOGS';
end
assert(any(strcmpi(type, {'LOGS', 'LEVELS'})));
switch type
  case 'LOGS'
    transf = 'DIFFL(%d)/100';
  case 'LEVELS'
    transf = 'DIFF(%d)';
end

%% Add back levels off of growth rates
% The two series should overlap for a period but should otherwise be
% continuous in opposite directions. 
assert(size(seriesA, 2) == 1, 'Data must be a single series.');
assert(size(seriesB, 2) == 1, 'Data must be a single series.');

[~,firstA] = cbd.first(seriesA);
seriesA = cbd.trim(seriesA, 'startDate', seriesA.Properties.RowNames{firstA});
[~,lastA] = cbd.last(seriesA);
seriesA = cbd.trim(seriesA, 'endDate', seriesA.Properties.RowNames{lastA});

[~,firstB] = cbd.first(seriesB);
seriesB = cbd.trim(seriesB, 'startDate', seriesB.Properties.RowNames{firstB});
[~,lastB] = cbd.last(seriesB);
seriesB = cbd.trim(seriesB, 'endDate', seriesB.Properties.RowNames{lastB});

mergeGrData = cbd.expression(transf, (cbd.merge(seriesA, seriesB)));
overlap = ~any(isnan(mergeGrData{:,:}), 2);

% Make seriesB the one that goes to present
if isnan(mergeGrData{end,2}) && ~isnan(mergeGrData{end,1})
  temp = seriesA;
  seriesA = seriesB;
  seriesB = temp;
  mergeGrData = cbd.expression(transf, (cbd.merge(seriesA, seriesB)));
end

justA = 2:find(overlap, 1, 'first')-1;
assert(~any(isnan(mergeGrData{justA,1})));

justB = find(overlap, 1, 'last')+1:size(mergeGrData, 1);
assert(~any(isnan(mergeGrData{justB,2})));

grData = mergeGrData(:,1);
grData{justB,:} = mergeGrData{justB,2};

% overlap adjustment (look first!)
nOver = sum(overlap);
weight = 1/(1+nOver);
grData{overlap,1} = (1:nOver)' * weight .* mergeGrData{overlap,2} + ...
  (nOver:-1:1)' * weight .* mergeGrData{overlap,1};

outData = grData;
outData{1,1} = seriesA{1,1};
switch type
  case 'LOGS'
    outData{2:end,:} = exp(cumsum(grData{2:end,:})) * seriesA{1,1};
  case 'LEVELS'
    outData{2:end,:} = cumsum(grData{2:end,:}) + seriesA{1,1};
end

outData.Properties.VariableNames = {[seriesA.Properties.VariableNames{1} ...
  'SPLICE' seriesB.Properties.VariableNames{1}]};

