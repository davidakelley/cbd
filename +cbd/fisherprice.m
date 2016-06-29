function priceI = fisherprice(varargin)
% Takes pairs of price-quantity data and constructs a Fisher price index
% for the aggregate quantity. 

% David Kelley, 2016

% Read inputs
assert(mod(nargin, 2) == 0, 'Must input price-quantity pairs of series.');
nDivs = nargin / 2;

prices = varargin(1:2:end);
quants = varargin(2:2:end);

% Compute components of Laspeyres & Paasche numerators and denominators
laspN = cell(1, nDivs);
laspD = cell(1, nDivs);
paasN = cell(1, nDivs);
paasD = cell(1, nDivs);
for iDiv = 1:nDivs
  laspN{iDiv} = cbd.expression('%d * LAG(%d)', prices{iDiv}, quants{iDiv});
  laspD{iDiv} = cbd.expression('LAG(%d) * LAG(%d)', prices{iDiv}, quants{iDiv});
  
  paasN{iDiv} = cbd.expression('%d * %d', prices{iDiv}, quants{iDiv});
  paasD{iDiv} = cbd.expression('LAG(%d) * %d', prices{iDiv}, quants{iDiv});
end

% Combine components to get Laspeyres & Paasche price indexes
dStr = strjoin(repmat({'%d'}, [1 nDivs]), ' + ');
laspeyeresP = cbd.expression(['(' dStr ') / (' dStr ')'], ...
  laspN{:}, laspD{:});
paascheP = cbd.expression(['(' dStr ') / (' dStr ')'], ...
  paasN{:}, paasD{:});

% Fisher Price Index
fisherGr = cbd.expression('100 * (POWER(%d*%d, 1/2)-1)', laspeyeresP, paascheP);
priceI = cbd.gr2lvl(fisherGr, 1);