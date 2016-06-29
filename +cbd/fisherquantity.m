function priceI = fisherquantity(varargin)
% Takes pairs of price-quantity data and constructs a Fisher price index
% for the aggregate quantity. 

% David Kelley, 2016

% Read inputs
assert(mod(nargin, 2) == 0, 'Must input price-quantity pairs of series.');
nDivs = nargin / 2;

prices = varargin(1:2:end);
quants = varargin(2:2:end);

% Compute components of Laspeyres & Paasche numerators and denominators
laspNumer = cell(1, nDivs);
laspDenom = cell(1, nDivs);
paasNumer = cell(1, nDivs);
paasDenom = cell(1, nDivs);
for iDiv = 1:nDivs
  laspNumer{iDiv} = cbd.expression('%d * %d', prices{iDiv}, quants{iDiv});
  laspDenom{iDiv} = cbd.expression('%d * LAG(%d)', prices{iDiv}, quants{iDiv});
  
  paasNumer{iDiv} = cbd.expression('LAG(%d) * %d', prices{iDiv}, quants{iDiv});
  paasDenom{iDiv} = cbd.expression('LAG(%d) * LAG(%d)', prices{iDiv}, quants{iDiv});
end

% Combine components to get Laspeyres & Paasche price indexes
dStr = strjoin(repmat({'%d'}, [1 nDivs]), ' + ');
laspeyeresP = cbd.expression(['(' dStr ') / (' dStr ')'], ...
  laspNumer{:}, laspDenom{:});
paascheP = cbd.expression(['(' dStr ') / (' dStr ')'], ...
  paasNumer{:}, paasDenom{:});

% Fisher Price Index
fisherGr = cbd.expression('100 * (POWER(%d*%d, 1/2)-1)', laspeyeresP, paascheP);
priceI = cbd.gr2lvl(fisherGr, 1);