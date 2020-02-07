function results = verify()
%VERIFY checks all series in the index have data and props
%
% OUTPUTS:
%   results     ~ table, a table of the bad series in the index
%
% Santiago Sordo-Palacios, 2019

% Get the chidata directory and load the index (these functions run their
% own verification tests inside of them, so we run them first
chidataDir = cbd.chidata.dir(); %#ok<NASGU>
index = cbd.chidata.loadIndex();

% Check the results from the index
results = verifyIndex(index);

% Index out the good series
badSeries = ~results.loadIndex | ~results.loadData | ~results.loadProps;
results = results(badSeries, :);

% TODO: How can we check whether there are existing series in the data
% or prop files that do not appear in the index? The paradign 

end % function

function results = verifyIndex(index)
%VERIFINDEX checks that all series-section pairs have data and props

% Create a table to preallocate the results
Series = keys(index)';
Section = values(index)';
loadIndex = true(length(Series), 1);
loadData = true(length(Series), 1);
loadProps = true(length(Series), 1);
results = table(Series, Section, loadIndex, loadData, loadProps);
results = sortrows(results, {'Section', 'Series'});

% Check if each series-section pair is valid
msg = sprintf('Verifying CHIDATA Directory');
w = waitbar(0, msg, 'Name', msg);
nSer = length(Series);
for iSer = 1:nSer
    
    % Preallocate the loop
    thisSection = results.Section{iSer};
    thisSeries = results.Series{iSer};
    thisMsg = sprintf('%s in %s', thisSeries, thisSection);
    waitbar(iSer/nSer, w, thisMsg);
    
    % Load each series data
    try
        cbd.chidata.loadData(thisSection, thisSeries);
    catch
        results.loadData(iSer) = false;
    end % try-catch
    
    % Load each series props
    try
        cbd.chidata.loadProps(thisSection, thisSeries);
    catch
        results.loadProps(iSer) = false;
    end % try-catch
end % for-i
close(w);

end % function

