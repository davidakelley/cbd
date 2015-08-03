function series = parseSeries(seriesID, dbDefault)
%PARSESERIES takes the cell input to cbd.haver and returns the structure of
%series to be pulled.
%
% The returned structure will have 4 fields: seriesID, dbID, Transform, TransformArgs
%   
% See also cbd.haver.m

% David Kelley, 2014

%% Preliminaries
validateattributes(seriesID, {'cell'}, {'row'});
nSer = length(seriesID);

structFields = {'seriesID', 'dbID', 'Transform', 'TransformArgs'};
series = struct;

for iSer = 1:nSer
    %% Set up parsing indexes
    iSeries = seriesID{iSer};

    ind{1} = 1;
    ind{2} = strfind(iSeries, '(');
    ind{3} = strfind(iSeries, '@');
    ind{4} = strfind(iSeries, ',');
    ind{5} = strfind(iSeries, ')');
    ind{6} = length(iSeries);
    
    %% Compile indexes
    found = ~cellfun(@isempty, ind);
    indMat = nan(size(ind));
    indMat(found) = cell2mat(ind);
    
    serInd = nan(4, 2);
    % Series
    serInd(1, 1) = max([indMat(1) indMat(2)+1]);            
    serInd(1, 2) = min([indMat(3:5)-1, indMat(6)]);
    % dbID
    serInd(2, 1) = indMat(3) + 1;                           
    serInd(2, 2) = min([indMat(4:5) - 1, indMat(6)]);
    if ~isnan(indMat(2))
        % Using a function
        assert(~isnan(indMat(5)), 'Unbalanced parentheses in series specification.');
        % Transformation
        serInd(3, 1) = indMat(1);                           
        serInd(3, 2) = indMat(2) - 1;
        % Transformation args.
        serInd(4, 1) = indMat(4) + 1;                       
        serInd(4, 2) = indMat(5) - 1;
    end
    
    %% Use indexes to place string parts in structure
    for iFld = 1:4
        if all(~isnan(serInd(iFld, :)))
            series(iSer).(structFields{iFld}) = lower(strtrim(iSeries(serInd(iFld, 1):serInd(iFld, 2))));
        else
            series(iSer).(structFields{iFld}) = nan;
        end
    end   
    
    %% Clean up / error checking
    assert(~any(isnan(series(iSer).seriesID)), 'Parse error. Cannot parse series ID.');
    if isnan(series(iSer).dbID)
        series(iSer).dbID = dbDefault;
    end
    if ~isnan(series(iSer).TransformArgs)
        series(iSer).TransformArgs = str2double(series(iSer).TransformArgs);
    end
    if ~isnan(series(iSer).Transform)
        series(iSer).Transform = strrep(series(iSer).Transform, '%', 'Pct');
    end
    
end