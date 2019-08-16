function timeTable = cbd2timetable(data)
% cbd2timetable takes a cbd table and outputs a timetable
%
% INPUTS:
%   data        ~ table, a cbd-format data table
%
% OUTPUTS:
%   timeTable   ~ timetable, a cbd-table formatted as a timetable

% Santiago Sordo-Palacios, 2019

%% change date to timetable and then retime
data.date = datetime(data.Row, 'InputFormat', 'dd-MMM-yyyy');
data.Properties.RowNames = {};
timeTable = table2timetable(data);

end