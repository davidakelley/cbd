function [data, dates, dataProp] = haver(seriesID, varargin)
%HAVER Get Haver data 
% Initially attempts to use the datafeed toolbox to create connection to a
%   Haver database. 
% If no Datafeed toolbox license can be found, use haverpull_stata to 
%   pull the data (limits the amount of metadata returned).
%
% INPUTS:
%   REQUIRED:
%   seriesID  ~ string or cell array of strings. Can include selected Haver
%               functions (DIFF, DIFA, YRYR, DIFF%, DIFA%, YRYR%)
%
%   OPTIONAL:   (name value pairs)
%   dbID      ~ Haver database name (default USECON)
%   startDate ~ date string of first date to get data, e.g., '01/01/1900'
%               (default fetches whole series)
%   endDate   ~ date string of last date to get data
%   disagg    ~ boolean (default false). True uses highest frequency for
%               output table, otherwise everything is aggregated to lowest frequency.
%   aggFreq   ~ specify a freqency for the data to be output at.
%
% OUTPUTS:
%   data      ~ a table of the data requested in the order of the series.
%   dates     ~ dates of observed data in a column vector.
%   dataProp  ~ structre with the data properties, including those from Haver.
%
% TODO - add support for higher frequency data (currently supports M, Q, & Y)

% Coppyright: David Kelley, 2014



%% Error checking
validateattributes(seriesID, {'cell', 'char'}, {'row'});
if ischar(seriesID)
    seriesID = {seriesID};
end

inP = inputParser;
inP.addParameter('dbID', 'USECON', @ischar);
dateValid = @(x) validateattributes(x, {'numeric', 'char'}, {'vector'});
inP.addParameter('startDate', [], dateValid);
inP.addParameter('endDate', [], @ischar);
inP.addParameter('disagg', false, @islogical);
inP.addParameter('aggFreq', [], @ischar);
inP.addParameter('lisc', true, @islogical);   % Specifies whether to use datafeed toolbox.

inP.parse(varargin{:});
opts = inP.Results;

if length(seriesID) == 1 && ~isempty(strfind(seriesID{:}, '@'))
    if ~isempty(strfind(seriesID{:}, '('))      % Using a function also
        endParen = strfind(seriesID{:}, ')');
        opts.dbID = seriesID{1}(strfind(seriesID{:}, '@')+1:endParen - 1);
        seriesID = {seriesID{1}([1:strfind(seriesID{:}, '@')-1 endParen])};
    else
        opts.dbID = seriesID{1}(strfind(seriesID{:}, '@')+1:length(seriesID{:}));
        seriesID = {seriesID{1}(1:strfind(seriesID{:}, '@')-1)};
    end
end
%% Create Connection
if opts.lisc
    try
        lisc = true;
        hav = haver(['R:\_appl\Haver\DATA\' opts.dbID '.dat']);
    catch ex 
        if strcmpi(ex.identifier, 'datafeed:haver')
            lisc = false;
        else 
            rethrow(ex);
        end
    end
else
    lisc = false;
end

if lisc && ~isconnection(hav)
    error('haverpull:invalidDB', 'Invalid database name or network error.');
end

%% Get the series names from each request
for iSeriesNum = 1:length(seriesID)
    iSeries = seriesID{iSeriesNum};
    if ~isempty(strfind(iSeries, '(')) && ~isempty(strfind(iSeries, ')'))
        cleanid{iSeriesNum} = iSeries(strfind(iSeries, '(')+1:strfind(iSeries, ')')-1); %#ok<AGROW>
        transform{iSeriesNum} = iSeries(1:strfind(iSeries, '(') -1); %#ok<AGROW>
    elseif ~isempty(strfind(iSeries, '(')) || ~isempty(strfind(iSeries, ')'))
        error('haverpull:invalidSeries', ['Invalid series name in series ' num2str(iSeries) '.']);
    else
        cleanid{iSeriesNum} = iSeries; %#ok<AGROW>
        transform{iSeriesNum} = 'na'; %#ok<AGROW>
    end
end

if lisc
    for iSeries = 1:length(cleanid)
        try
            seriesInfo(iSeries) = info(hav, cleanid(iSeries)); %#ok<AGROW>
            desc = cell(size(seriesInfo));
        catch
            error('haverpull:noPull', ['Cannot pull the series ' cleanid{iSeries} '.']);
        end
    end
    [desc{:}] = seriesInfo.Descriptor;
    cellInfo = struct2cell(seriesInfo);
else
    seriesInfo = struct('Frequency', cell(length(seriesID), 1));
    desc = [];
    cellInfo = {};
end

%% Adjust date range to be pulled
if ~isempty(opts.startDate)
    dateVec = datevec(opts.startDate);
    
    if any(strcmpi(transform, 'YRYR')) || any(strcmpi(transform, 'YRYR%'))
        newStart = dateVec - [1 0 0 0 0 0];
    elseif any(strcmpi(transform, 'DIFF')) || any(strcmpi(transform, 'DIFA')) || ...
            any(strcmpi(transform, 'DIFF%')) || any(strcmpi(transform, 'DIFA%'))
        if any([seriesInfo.Frequency] == 'Y')
            newStart = dateVec - [1 0 0 0 0 0];
        elseif any([seriesInfo.Frequency] == 'Q')
            newStart = dateVec - [0 3 0 0 0 0];
        elseif any([seriesInfo.Frequency] == 'M')
            newStart = dateVec - [0 1 0 0 0 0];
        end
    else
        newStart = datevec(opts.startDate);
    end
    
    opts.startDate = datestr(newStart, 'mm/dd/yyyy');
else
    if lisc
        opts.startDate = datestr(min(cellfun(@datenum, cellInfo(2,:,:))), 'mm/dd/yyyy');
    end
end

if isempty(opts.endDate)
    if lisc
        opts.endDate = datestr(max(cellfun(@datenum, cellInfo(3,:,:))), 'mm/dd/yyyy');
    end
end

%% Pull Data
data = cell(1, length(cleanid));
if lisc
    for iSeries = 1:length(cleanid)
        try
            data{iSeries} = fetch(hav, cleanid(iSeries), opts.startDate, opts.endDate);
        catch
            data{iSeries} = nan;
        end
    end
else
    for iSeries = 1:length(cleanid)
        try
            data{iSeries}= cbd.haverpull_stata(cleanid{iSeries}, opts.startDate, opts.endDate);
            seriesInfo(iSeries).Frequency = cbd.getFreq(data{iSeries}(:,1)); %#ok<AGROW>
            data{iSeries}(:,1) = cbd.endOfPer(data{iSeries}(:,1), seriesInfo(iSeries).Frequency);
        catch
            data{iSeries} = nan;
        end
    end
end

%% Aggregate to correct frequency

[~, loF, hiF] = frequencies(seriesInfo);

if ~strcmp(loF, hiF) && lisc
    if opts.disagg
        error('Not yet developed.');
    else
        for iSer = 1:length(cleanid)
            if ~strcmp(seriesInfo(iSer).Frequency, loF)
                [aggData, aggDates] = cbd.aggregate(data{iSer}(:,2), data{iSer}(:,1), seriesInfo(iSer).AggType, loF);
                data{iSer} = [aggDates, aggData];
            end
        end
    end
elseif ~strcmp(loF, hiF) && ~lisc
    error('haverpull:stataAgg', 'Aggregation not supported without Datafeed Toolbox license.')
end

%% Compute transformations
for iSeries = 1:length(seriesID)
    [~, freq] = cbd.getFreq(loF);
    
    switch lower(transform{iSeries})
        case 'difa%'
            dataSeries(:, 1) = data{iSeries}(2:end, 1);
            dataSeries(:, 2) = 100 * ((data{iSeries}(2:end, 2) ./ data{iSeries}(1:end -1, 2)).^freq -1);
        case 'diff%'
            dataSeries(:, 1) = data{iSeries}(2:end, 1);
            dataSeries(:, 2) = 100 * (data{iSeries}(2:end, 2) ./ data{iSeries}(1:end - 1, 2) -1);
        case 'yryr%'
            dataSeries(:, 1) = data{iSeries}(freq+1:end, 1);
            dataSeries(:, 2) = 100 * (data{iSeries}(freq+1:end, 2) ./ data{iSeries}(1:end - freq, 2) -1);
        case 'diff'
            dataSeries(:, 1) = data{iSeries}(2:end,1);
            dataSeries(:, 2) = data{iSeries}(2:end, 2) - data{iSeries}(1:end-1, 2);
        case 'difa'
            dataSeries(:, 1) = data{iSeries}(2:end,1);
            dataSeries(:, 2) = (data{iSeries}(2:end, 2) - data{iSeries}(1:end-1, 2)) * freq;
        case 'na'
            dataSeries = data{iSeries};
        otherwise
            error('haverpull:invalidTransformation', ['Invalid data transformation applide in series ' num2str(iSeries) '.']);
    end
    
    data{iSeries} = dataSeries;
    dataSeries = [];
end

%% Transform to Matrix
[seriesLengths, ~] = cellfun(@size, data);
dataLength = min(seriesLengths);

[~, dateInd] = lastFirstDate(data);

outData = zeros(dataLength, iSeries+1);
outData(:,1) = data{1}(dateInd(1):end, 1);
for iSeries = 1:length(data)
    outData(:,iSeries + 1) = data{iSeries}(dateInd(iSeries):end, 2);
end

dataID = upper(seriesID);
dataID = strrep(dataID, '%', 'pct');
dataID = strrep(dataID, '(', '_');
dataID = strrep(dataID, ')', '');

data = array2table(outData(:,2:end), 'VariableNames', dataID, 'RowNames', cellstr(datestr(outData(:,1))));

dataProp = struct;
for iSer = 1:length(cleanid)
    dataProp(iSer).IDs = cleanid{iSer};
    dataProp(iSer).Trans = transform{iSer};
    %dataProp(iSer).Freq = seriesInfo(iSer).Frequency;
    dataProp(iSer).Info = seriesInfo(iSer);
    if lisc
        dataProp(iSer).Desc = desc{iSer};
    end
end

dates = outData(:,1);

end

function [lastDate, dateInd] = lastFirstDate(data)

[dim1, ~] = cellfun(@size, data);

dates = nan(max(dim1), length(data));
for iSeries = 1:length(data)
    dates(1:dim1(iSeries), iSeries) = data{iSeries}(:,1);
end

lastDate = max(min(dates));
dateInd = nan(1, length(data));
for iSeries = 1:length(data)
    [iInd, ~] = find(dates(:,iSeries) == lastDate);
    if ~isempty(iInd)
        dateInd(iSeries) = iInd;
    end
end

end

function [freqCell, lowF, hiF] = frequencies(seriesInfo)
% Returns a cell array with indexes of the data's frequencies.
% Also returns the lowest frequency and highest frequency in the data.

freqs ='AQMWD';

freqCell = cell(size(freqs));
warn = false;
for iSeries = 1:length(seriesInfo)
    iFreq = strfind(freqs, seriesInfo(iSeries).Frequency);
    freqCell{iFreq}(length(freqCell{iFreq}) + 1) = iSeries;
    
    if ~strcmp(seriesInfo(1).Frequency, seriesInfo(iSeries).Frequency)
        warn = true;
    end
end

if warn
    warning('haverpull:dataFrequency', 'Series being pulled have different frequencies.');
end

freqInds = find(~cellfun(@isempty,freqCell));

lowF = freqs(min(freqInds));
hiF = freqs(max(freqInds));

end

