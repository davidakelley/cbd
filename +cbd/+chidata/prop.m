function propStruct = prop(nSeries, varargin)
%PROP creates the properties structured used in cbd.chidata.save()
% 
% INPUTS:
%   nSeries     ~ double, the number of series being saved
%   Source      ~ char, the source of the data
%   Frequency   ~ char, the frequency of the data
%   Magnitude   ~ double, the power to raise the series to in order to 
%               return the natural number
%   AggType     ~ char, the method used when aggregating the series
%   DataType    ~ char, the type of data being stored
%
% OUTPUTS:
%   propStruct  ~ struct, the properties structure craeted
% 
% Santiago I. Sordo Palacios, 2019

%% Check the inputs
assert(isnumeric(nSeries));
inP = inputParser;
inP.addParameter('Source', '', @ischar)
inP.addParameter('Frequency', '', @ischar)
inP.addParameter('Magnitude', [], @isnumeric)
inP.addParameter('AggType', '', @ischar)
inP.addParameter('DataType', '', @ischar)
inP.parse(varargin{:})

%% Create the properties structure
propStruct = inP.Results;
if nSeries > 1
    for iSeries = 2:nSeries
        propStruct(iSeries) = propStruct(1);
    end % for-iSeries
end % if-nSeries

end % function
