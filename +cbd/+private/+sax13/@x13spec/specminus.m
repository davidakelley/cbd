% SPECMINUS removes all entries in the second x13spec object from the entries in
% the first x13spec object (provided the section-key-values of the second spec
% are present in the first spec). Consequently, if the first spec is a subset of
% the second spec, an empty x13spec object is returned.
%
% NOTE: This file is part of the X-13 toolbox.
%
% see also guix, x13, makespec, x13spec, x13series, x13composite, 
% x13series.plot,x13composite.plot, x13series.seasbreaks,
% x13composite.seasbreaks, fixedseas, spr, InstallMissingCensusProgram
%
% Author  : Yvan Lengwiler
% Version : 1.18
%
% If you use this software for your publications, please reference it as
%   Yvan Lengwiler, 'X-13 Toolbox for Matlab, Version 1.18', Mathworks File
%   Exchange, 2016.

function spec1 = specminus(spec1,spec2)

    series1 = fieldnames(spec1);
    series2 = fieldnames(spec2);
    accumulKeys = {'save', 'savelog', 'print', 'variables', ...
        'aictest', 'types'};
    
    ser = intersect(series1,series2);
    for s = 1:numel(ser)
        keys1 = {}; try keys1 = fieldnames(spec1.(ser{s})); end
        keys2 = {}; try keys2 = fieldnames(spec2.(ser{s})); end
        keys = intersect(keys1,keys2);
        for k = 1:numel(keys)
            if ismember(keys{k},accumulKeys)
                val1 = spec1.ExtractRequests(spec1,ser{s},keys{k});
                val2 = spec2.ExtractRequests(spec2,ser{s},keys{k});
                val  = intersect(val1,val2);
                spec1 = spec1.RemoveRequests(ser{s},keys{k},val);
            else
                val1 = spec1.(ser{s}).(keys{k});
                val2 = spec2.(ser{s}).(keys{k});
                if isequal(val1,val2)
                    spec1 = x13spec(spec1,(ser{s}),(keys{k}),[]);
                end
            end
        end
        if ~isstruct(spec1.(ser{s}))
            spec1 = x13spec(spec1,ser{s},[],[]);
        end
    end
      
