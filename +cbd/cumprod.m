function data = cumprod(data)
% CUMPROD Take the cumulative product of a series
%
% dataSum = CUMPROD(data) returns the cumprod of the data
% 
% Note that nan values at the beginning of a series will result in all nan 
% values for a cumulative product. 

% David Kelley, 2017

%% Validate attributes
assert(istable(data), 'cumprod:table', 'Input must be a table.');

data{:,:} = cumprod(data{:,:});

end