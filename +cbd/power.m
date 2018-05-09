function data = power(data, exponent)
% POWER Raises a data series to a power
%
% powed = POWER(dataA, exponent) returns the data raised to the power of
% the exponent

% David Kelley, 2015

%% Validate attributes
assert(istable(data), 'power:table', 'Input must be a table.');

data{:,:} = data{:,:} .^ exponent;

end