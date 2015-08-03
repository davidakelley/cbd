%Chartbook Data management package
%
% See the full <a href="matlab:open('O:\PROJ_LIB\Presentations\Chartbook\Data\Dataset Creation\cbd\Chartbook Data Documentation.docx')">documentation</a> for help.
%
% Files
%   addition       - Find the sum of two series
%   agg            - Aggregates a data series to a lower frequency
%   avg            - Returns the average value of a dataset over the given period
%   bfgr           - Extends a series backward by using the growth rate of another series
%   bflvl          - Extends a series backward by using the level of another series
%   change         - Returns the change over a the given period
%   changebp       - Returns the change over a the given period multiplied by 100
%   changePct      - Returns the percent change in a window
%   chidata_save   - Saves a data series to the CHIDATA folder 
%   corr           - Finds the correlation between data series
%   data           - Get data series from Haver, FRED, or CHIDATA databases
%   day            - Get the day of month
%   difa           - Returns the annualized difference of a data series
%   difal          - Returns the log-differenced version of a data series
%   difaPct        - Returns the annualized differenced of a data series
%   diff           - Returns the differenced version of a data series
%   diffl          - Returns the log-differenced version of a data series
%   diffPct        - Returns the differenced version of a data series
%   difv           - Returns the average difference of a series
%   difvl          - Returns the acerage log-difference of a series
%   difvPct        - Returns the average difference of a series
%   disagg         - Disaggregates a data series to a higher frequency
%   division       - Find the quotient of two 
%   exp            - Returns the exponentiated version of a data series
%   export_excel   - Exports a cbd table to an Excel file
%   extend_last    - Extends the data series 
%   first          - Pulls the first non-nan value from a vector
%   indexed        - Makes an index of a series by dividing the history of the series by
%   interpNan      - Runs the interp1 function on the NaN values in a given vector. 
%   lag            - Shifts a data series by a given number of periods
%   last           - Pulls the last non-nan value from a vector
%   ld2llvl        - Takes a series of log fist differences and a series of
%   ld2lvl         - Takes a series of log fist differences and a series of
%   ln             - Returns the log version of a data series
%   max            - Returns the maximum value of a dataset over the given period
%   mean           - Returns the mean value of a dataset over the given period
%   median         - Returns the median value of a dataset over the given period
%   merge          - Combines two tables with dates as the row labels
%   min            - Returns the minnimum values of a dataset over the given period
%   month          - Get the month number
%   mova           - Calculates the annualized moving average over a given window
%   movt           - Calculates the moving sum over a given window
%   movv           - Calculates the moving average over a given window
%   multiplication - Find the product of two series
%   nan2one        - Takes a cbd table and converts the NaNs to zeros
%   nan2zero       - Takes a cbd table and converts the NaNs to zeros
%   power          - Raises a data series to a power
%   quarter        - Get the quarter number
%   stddm          - Demeans and stardardizes the input data.
%   subtraction    - Find the difference of two series
%   trim           - Returns data between given a startDate or endDate
%   xlsfile        - Class representing an Excel file.
%   year           - Get the year number
%   yryr           - Computes the year-over-year percent change in a series
%   yryrl          - Computes the year-over-year log change in a series
%   yryrPct        - Computes the year-over-year percent change in a series
