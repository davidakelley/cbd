function Prop = chidata_prop(nSeries, varargin)
%CHIDATA_PROP creates the properties structured used in CHIDATA_SAVE
% 
% INPUTS:
%   nSeries     ~ double, the number of series being saved
%   Source      ~ char, the source of the data
%   Frequency   ~ char, the frequency of the data
%   Magnitude   ~ double, the power to raise the series to in order to 
%               return the natural number
%   AggType     ~ char, the method used when aggregating the series
%   DataType    ~ char, the type of data being stored
% OUTPUTS:
%   Prop        ~ struct, the properties structure needed in chidata_save
% 
% Santiago I. Sordo Palacios, 2019

%% Check the inputs
assert(isnumeric(nSeries))
inP = inputParser;
inP.addParameter('Source', '', @ischar)
inP.addParameter('Frequency', '', @ischar)
inP.addParameter('Magnitude', [], @isnumeric)
inP.addParameter('AggType', '', @ischar)
inP.addParameter('DataType', '', @ischar)
inP.parse(varargin{:})

%% Create the properties structure
Prop = inP.Results;
for iSeries = 2:nSeries
    Prop(iSeries) = Prop(1);
end

end
