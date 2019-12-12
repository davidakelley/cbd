function [apiKey, fredURL, foundFRED] = connectFRED(dbID)
%CONNECTFRED establishes a connection to a FRED database
%
% INPUTS:
%   dbID        ~ char, the name of the database, expected 'FRED'
%
% OUPUTS:
%   apiKey      ~ char, The API key used for FRED
%   fredURL     ~ char, the URL of the FRED data
%   foundFRED   ~ logical, whethere FRED could be found using API Key
%
% Santiago I. Sordo-Palacios

if nargin == 1
    assert(strcmpi(dbID, 'FRED'), ...
        'fredseries:invaliddbID', ...
        'fredseries dbID "%s" is not FRED', dbID);
end % if-nargin

% Store key and url
apiKey = 'b973f7ef7fa2e9f17722a5f364c9d477';
fredURL = 'https://api.stlouisfed.org/fred/';

% Check connection to FRED with the given API Key
if nargout == 3
    requestURL = [fredURL, ...
        'series/observations?series_id=', 'GDP', ...
        '&api_key=', apiKey, ...
        '&file_type=json'];
    try
        webread(requestURL);
        foundFRED = true;
    catch ME
        id = 'fredseries:badFREDconn';
        message = 'The provided API Key failed to download GDP data';
        MEnew = MException(id, message);
        MEnew = addCause(MEnew, ME);
        throw(MEnew)
    end % try-catch
end % if-nargout

end % function-connectFRED