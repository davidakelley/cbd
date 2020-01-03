function props = dynamicFields(propsIn, operation)
%DYNAMICFIELDS either adds or removes dynamic fields from props structure
%
% INPUTS
%   propsIn     ~ struct, the incoming properties structure
%   operation   ~ char, whether the properties should be added or removed
%
% OUTPUTS
%   props       ~ struct, the properties structure with or without fields
% 
% Santiago Sordo-Palacios, 2019

switch operation
    case 'add'
        props = addDynamicFields(propsIn);
    case 'remove'
        props = removeDynamicFields(propsIn);
    otherwise
        error('chidata:dynamicFields:badOperation', ...
            'Operation "%s" not supported in dynamicFields', operation);
end % switch-case

end % function

function props = addDynamicFields(props)
%ADDYNAMICFIELDS adds the dynamic fields to the structure
%
% NOTE: Variable names get added later on

% Find the current date and username
thisDT = datestr(now);
thisUser = getenv('username');

% Find the file that calls chidata.save
thisStack = dbstack('-completenames');
[~, loc] = ismember(mfilename(), {thisStack.name});
loc = loc + 4; % Shift up two positions to get calling file
if size(thisStack, 1) < loc
    callFile = 'N/A';
else
    callFile = thisStack(loc).file;
end

% Store the information to the properties structure
nProps = length(props);
DateTimeMod = cellstr(repmat(thisDT, nProps, 1));
UsernameMod = cellstr(repmat(thisUser, nProps, 1));
FileMod = cellstr(repmat(callFile, nProps, 1));

[props.DateTimeMod] = DateTimeMod{:};
[props.UsernameMod] = UsernameMod{:};
[props.FileMod] = FileMod{:};

end % function

function props = removeDynamicFields(props)
%REMOVEDYNAMICFIELDS removes fields from the structure

dynamicFields = {'Name', 'DateTimeMod', 'UsernameMod', 'FileMod'};
dynamicIndex = ismember(dynamicFields, fieldnames(props));
props = rmfield(props, dynamicFields(dynamicIndex));

end  % function
