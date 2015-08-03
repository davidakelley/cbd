function ast = parseHaverInput(input)
%PARSEHAVERINPUT takes the input to the HAVER function and creates a tree
%of functions that will be interpreted in the body of the HAVER function
%with calls to cbd functions. 

% David Kelley, 2014

%% 

validateattributes(seriesID, {'cell'}, {'row'});
nSer = length(seriesID);

%%
