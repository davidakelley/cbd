function compareProps(props, oldProps, dynamicFields, prompt)
%COMPAREPROPS is a helper function that compares old to existing props
%
% INPUTS
%   props           ~ struct, the existing props structure
%   oldProps        ~ struct, the previous props structure
%   dynamicFields   ~ cell, the fields set dynamically
%   prompt          ~ function handle, to call cbd.chidata.prompt
%
% WARNING: This function should NOT be called directly by the user
%
% Santiago Sordo-Palacios, 2019

% Remove any dynamic fields
idx = ismember(dynamicFields, fieldnames(oldProps));
oldProps = rmfield(oldProps, dynamicFields(idx));

% Check if properties are udpated
newHasDiffProps = ~isequal(oldProps, props);
if newHasDiffProps
    id = 'chidata:compareProps:overwriteProps';
    msg = 'Overwriting with revised properties';
    prompt(id, msg);
end

end % function
