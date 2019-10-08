function [apiKey, fredURL] = connectFRED(dbID)
%CONNECTFRED establishes a connection to a FRED database
%
%
% OUPUTS:
%   apiKey  ~ char, The API key used for FRED
%   fredURL ~ char, the URL of the FRED data
%
% Santiago I. Sordo-Palacios

if nargin == 1
    assert(isequal(dbID, 'FRED'), ...
        'fredseries:invaliddbID', ...
        'fredseries dbID "%s" is not FRED', dbID);
end % if-nargin
    
apiKey = 'b973f7ef7fa2e9f17722a5f364c9d477';
fredURL =  'https://api.stlouisfed.org/fred/';

end % function-connectFRED