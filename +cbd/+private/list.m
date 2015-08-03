function list(getDocs)
% List CHIDATA series

if nargin == 0 
    getDocs = false;
end

chidataDir = 'O:\PROJ_LIB\Presentations\Chartbook\Data\CHIDATA\';

seriesList = readtable([chidataDir 'index.csv']);

series = seriesList{:,1};