function compareProps(props, oldProps, prompt)
%COMPAREPROPS is a helper function that compares old to existing props
%
% INPUTS
%   props           ~ struct, the existing props structure
%   oldProps        ~ struct, the previous props structure
%   prompt          ~ function handle, to call cbd.chidata.prompt
%
% WARNING: This function should NOT be called directly by the user
%
% Santiago Sordo-Palacios, 2019

% Remove the dynamic fields before comparing
oldProps = cbd.chidata.dynamicFields(oldProps, 'remove');

% Check if properties are udpated
newHasDiffProps = ~isequal(oldProps, props);
if newHasDiffProps
    id = 'chidata:compareProps:overwriteProps';
    msg = 'Overwriting with a revised properties structure';
    prompt(id, msg);
end

end % function
