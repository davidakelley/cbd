function data = cumsum(data)
% CUMSUM Take the cumulative sum of a series
%
% dataSum = CUMSUM(data) returns the cumsum of the data
%
% Note that nan values at the beginning of a series will result in all nan 
% values for a cumulative sum. 

% David Kelley, 2017

%% Validate attributes
assert(istable(data), 'cumsum:table', 'Input must be a table.');

data{:,:} = cumsum(data{:,:});

end