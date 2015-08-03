function [rawData] = haverpull_stata(series, startdate, enddate)
%HAVERPULL_STATA pulls a single series from Haver by creating a Stata .do
%file that fetches the data and writes it to a .csv file, reads that file
%into Matlab and deletes the created files. 
%
% data = HAVERPULL_STATA(series) pulls a single series and returns a two
% column array of the dates and the data. 
%
% data = HAVERPULL_STATA(series, startdate, enddate) returns the data
% within the date rante. Note that startdate may be specified without
% enddate

% Copyright: David Kelley, 2014

%% Preliminaries
stataLoc = 'C:\Program Files (x86)\Stata13\StataMP-64.exe';
doFile = [pwd '\haverpull.do'];
dataFile = [pwd '\temp.csv'];

if nargin == 1
    startdate = [];
    enddate = [];
elseif nargin == 2
    enddate = [];
end

validateattributes(series, {'char'}, {'row'});

%% Create and run do file
if ~isempty(startdate)
    sdate = datevec(startdate);
    startCode = [...
        'local sdate = mdy(' num2str(sdate(2)) ',' num2str(sdate(3)) ',' num2str(sdate(1)) ')\n' ...
        'drop if dailydate < `sdate''\n'];
else
    startCode = [];
end

if ~isempty(enddate)
    edate = datevec(enddate);
    endCode = [ ...
        'local edate = mdy(' num2str(edate(2)) ',' num2str(edate(3)) ',' num2str(edate(1)) ')\n' ...
        'drop if dailydate > `edate''\n'];
else
    endCode = [];
end

doText = [...
    'import haver (' series ')@USECON, clear \n' ...
    'tsset \n' ...
    'local datechar = r(unit1) \n' ...
    'gen dailydate = dof`datechar''(time) \n' ...
    'replace time = dailydate + 21916 \n' ...
    startCode ...
    endCode ...
    'drop dailydate \n' ...
    'format time %%9.0f \n' ...
    'export delimited using "' strrep(dataFile, '\', '\\') '", replace novar \n'];

fid = fopen(doFile, 'w');
fprintf(fid, doText);
fclose(fid);

cmd = ['"' stataLoc '" /e do "' doFile '"'];
status = system(cmd);

if status ~= 0
    error('haverpull_stata:stata', 'Error in calling Stata.');
end

%% Import data
rawData = csvread(dataFile);
dates = x2mdate(rawData(:,1));
rawData(:,1) = dates;

%% Clean up
delete(doFile);
delete([doFile(1:end-3) '.log']);
delete(dataFile);

end