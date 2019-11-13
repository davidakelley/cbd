function section = findSection(seriesID, index)
%FINDSECTION finds the section of a seriesID within the index
%
% INPUTS:
%   seriesID    ~ char, the name of the series
%   index       ~ char, the index of the chidata directory
%
% OUPTUS:
%   section     ~ char, the name of section containing seriesID
%
% WARNING: This function should NOT be called directly by the user
%
% David Kelley, 2015
% Santiago Sordo-Palacios, 2019

% Find the index of the series
seriesInd = strcmpi(seriesID, index.Series);

% Get the name of the section
if sum(seriesInd) == 1
    section = index.Section{seriesInd};
    assert(~isempty(section), ...
        'chidata:findSection:empty', ...
        'Series "%s" has an empty section in the index', ...
        seriesID);
elseif sum(seriesInd) > 1
    error('chidata:findSection:duplicate', ...
        'Series "%s" appears more than once in the index', ...
        seriesID);
elseif sum(seriesInd) < 1
    error('chidata:findSection:missing', ...
        'Series "%s" not found in the index', ...
        seriesID);
end % if-elseif

end % function-findSection
