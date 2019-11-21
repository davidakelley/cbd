function [extraData, extraProps] = verifySections()
%VERIFY2 checks that no extraneous sections

% Load the index and get the sections
index = cbd.chidata.loadIndex();
fromIndex = sort(unique(values(index)));

% Load all of the files in the directory 
fileList = dir(cbd.chidata.dir());
fnames = {fileList.name};

% Find the sections according to the data files
dataExt = '_data.csv';
dataIdx = contains(fnames, dataExt);
fromData = sort(strrep(fnames(dataIdx), dataExt, ''));

% Find the sections according the props files
dataExt = '_prop.csv';
propsIdx = contains(fnames, dataExt);
fromProps = sort(strrep(fnames(propsIdx), dataExt, ''));

% Check the sections
checkFun = @(x) ~ismember(x, fromIndex);
extraDataIdx = cellfun(checkFun, fromData);
extraPropsIdx = cellfun(checkFun, fromProps);

% Index to keep only the bad ones
extraData = fromData(extraDataIdx);
extraProps = fromProps(extraPropsIdx);

end % function