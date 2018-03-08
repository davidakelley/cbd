function data = cumsum(data)
%CUMSUM Take the cumulative sum of a series
%
% dataSum = cumsum(data) returns the cumsum of the data

% David Kelley, 2017

%% Validate attributes
assert(istable(data), 'cumsum:table', 'Input must be a table.');

data{:,:} = cumsum(data{:,:});

end