function writeIndex(fname, index)
%WRITEINDEX is a helper function that writes the index file
%
% INPUTS:
%   fname   ~ char, the name of the file
%   index   ~ containers.Map, the updated index
%
% WARNING: This function should NOT be called directly by the user
%
% Santiago Sordo-Palacios, 2019

% Create a new index file if only the name is specified
if nargin < 2
    fid = fopen(fname, 'w');
    fprintf(fid, 'Series, Section\n');
    fclose(fid);
    return
end % if-nargin

% Write the index if specified
Series = transpose(keys(index));
Section = transpose(values(index));
index = table(Series, Section);
writetable(index, fname, ...
    'Delimiter', ',');

end % function