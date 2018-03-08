function data = cumprod(data)
%CUMPROD Take the cumulative product of a series
%
% dataSum = cumprod(data) returns the cumprod of the data

% David Kelley, 2017

%% Validate attributes
assert(istable(data), 'cumprod:table', 'Input must be a table.');

data{:,:} = cumprod(data{:,:});

end