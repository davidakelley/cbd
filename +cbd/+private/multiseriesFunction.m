function dataOut = multiseriesFunction(dataA, dataB, fnHandle, varargin)
%MULTISERIESFUNCTION computes binary operations on cbd tables and scalars
%
% This is a private function that handles performing operations on
% cbd tables and/or scalars. This should only be called inside of
% CBD.ADDITION, CBD.SUBTRACTION, CBD.MULTIPLICATION, and CBD.DIVISION
%
% INPUTS:
%   dataA       ~ table/double, either a cbd table or a scalar
%   dataB       ~ table/double, either a cbd table or a scalar
%   fnHandle    ~ function_handle, the handle of the operation
%   ignoreNan   ~ logical, whether NaN's should be ignored in operations
%               in addition and subtraction, this means the NaN's are
%               turned into 0's and for multiplication and division
%               the NaN's are turned into 1's.
%
% OUTPUTS:
%   dataOUt     ~ table/double, the result of the binary operation where
%               the type of dataOut will depend on the inputs
%               ~ If dataA and dataB are tables, dataOut will be a table
%               ~ If dataA and dataB are scalars, dataOUt will be a scalar
%               ~ If one is a table and the other is a scalar, then
%               dataOut will be a table
%
% David Kelley, 2015
% Santiago I. Sordo-Palacios, 2019

%% Validate attributes
% Check properties to dataA
if istable(dataA)
    validateattributes(dataA, {'table'}, {'2d'});
else
    validateattributes(dataA, {'numeric'}, {'scalar'});
end

% Check properties of dataB
if istable(dataB)
    validateattributes(dataB, {'table'}, {'2d'});
else
    validateattributes(dataB, {'numeric'}, {'scalar'});
end

% Check properties of fhHandle
validateattributes(fnHandle, {'function_handle'}, {'scalar'});

% Check that the size of the data tables are the same
if istable(dataA) && istable(dataB)
    assert(size(dataA, 2) == size(dataB, 2), 'Tables must be same size');
end

% Parse the inputs
inP = inputParser;
inP.addParameter('ignoreNan', false, @islogical);
inP.parse(varargin{:});
ignoreNan = inP.Results.ignoreNan;

%% Compute operation
% Handle all of the incoming cases
if istable(dataA) && istable(dataB) % Both are tables
    % Merge the data together
    data = cbd.merge(dataA, dataB);

    % Replace NaN's  depending on input if option is specified
    if ignoreNan
        fnStr = func2str(fnHandle);
        if contains(fnStr, {'plus', 'minus'})
            data = cbd.nan2zero(data);
        elseif contains(fnStr, {'times', 'rdivide'})
            data = cbd.nan2one(data);
        else
            id = 'multiseriesFunction:badFnHandle';
            msg = 'The fnHandle "%s" is not supported with ignoreNan';
            error(id, msg, fnStr);
        end % if-contains
    end % if-ignoreNan

    % Perform the calculation
    fnResult = fnHandle(data{:, 1}, data{:, 2});
    dataOut = array2table(fnResult, ...
        'RowNames', data.Properties.RowNames, ...
        'VariableNames', {'dataseries'});
elseif istable(dataA) && ~istable(dataB) % dataB is a scalar
    fnResult = fnHandle(dataA{:, :}, dataB);
    dataOut = array2table(fnResult, ...
        'RowNames', dataA.Properties.RowNames, ...
        'VariableNames', dataA.Properties.VariableNames);
elseif ~istable(dataA) && istable(dataB) % dataA is a scalar
    fnResult = fnHandle(dataA, dataB{:, :});
    dataOut = array2table(fnResult, 'RowNames', ...
        dataB.Properties.RowNames, ...
        'VariableNames', dataB.Properties.VariableNames);
else % They are both scalars
    dataOut = fnHandle(dataA, dataB);
end

end % function