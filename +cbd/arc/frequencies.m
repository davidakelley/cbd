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