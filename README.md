Chartbook Data
==============
Created: David Kelley, 2014-2015
Modified: 

Chartbook Data is a Matlab package that is designed for the Economic Research Department's data management. The functions within it break down into three major sections:
1. Data retrieval 
2. Data manipulation 
3. File handling & other

Data Retrieval
--------------
The cbd.data function gets data from external sources and returns it in a table with nicely formatted dates. 
* haver - Retrieve data from a Haver database. 
 Specify the series you want as a cell array of strings. Each should consist of a series name ('GDPH') that will be pulled from the default database or whatever database specified using the '@' symbol ('FRBCNAI@SURVEYS'). If you're pulling several series from the same database, used the name-value pair option 'dbID' to set a default database (USECON if not specified). 
 To restrict the dates of data being pulled, use the 'startDate' and 'endDate' name-value pairs with a datenum or string formated date. Otherwise the entire series will be pulled. 
 Each string can also contain an expression of data manipulation functions such as 'DIFA%(GDPH)'. Functions should work as defined in the next section. They can be nested, as well as take other numeric arguments, i.e., 'DIFA%(MOVV(JCBM,3),3)'. 
* fred - 

Data Manipulation 
-----------------
The data manipulation functions generally fall into two categories: transformations and summarizations. 

### Transformations
The transformation functions are based off of the Haver functions with a few extensions. All of the functions here take a table of data in and return a table with the same dimensions. Any of the Haver functions that can take a number of periods as a second input in Haver can here as well. 

The standard 15 Haver functions (diff, difa, difv, diffPct, difaPct, difvPct, yryr, yryrPct, yryrl, diffl, difal, difvl, movv, mova, movt) are all included. 

There are also the following additional functions:
* lag - computes the lag or lead of a series. Takes the series as the first input and (optionally) a second input of the number of periods. Input a negative number of periods to compute a lead.
* stddm - demeans and standardizes data
x interpNan - 

### Summarizations
The summarization functions take a table of values as an input and return a table of values that has a column for every series but only one row of values. 

* mean
* median
* max
* min
* last

### Aggregation / Disaggregation


### Misc.
* corr


File Handling & Misc.
---------------------

* xlsfile - Creates an object representing an Excel file for easier access. The Matlab functions for interacting with Excel (xlsread, xlswrite, etc.) force an Excel process to be created and shut down with each function call. Creating an object for one instead can keep the process running and make repetitious interaction with the same file much faster and simpler, especially for large files or many read-write operation on one file. There is also some added functionality included, such as exporting Excel files to PDF from Matlab. See the documentation for more information, but it should generally work the same as the Matlab functions you already know. 

There are also a date functions to get the year, quarter, or month (using those names) since the Matlab functions that do that are inexplicably in the Financial Toolbox. These are generally useful in labeling the x-axes of charts. 

To Do:
======
- [x] Make FRED function to take Haver transformations and nested Haver transformations
- [x] Write tests for data function
- [x] Data properties
	- [x] Make data function to output structure of data properties
	- [x] Determine method of combining data properties structures given multi-series functions
- [x] Write and test single-series data transformations
	- [x] lag
	- [x] diff
	- [x] difa
	- [x] diffl
	- [x] diff%
	- [x] difa%
	- [x] difal
	- [x] yryr
	- [x] yryr%
	- [x] yryrl
	- [x] difv
	- [x] difv%
	- [x] difvl
	- [x] movv
	- [x] mova
	- [x] movt
- [x] Multi-series functions
	- [x] addition
	- [x] subtraction 
	- [x] multiplication
	- [x] division
	- [x] Accept integer intpus
- [x] Other transformations
	- [x] interpNan
	- [x] stddm
- [x] Summarization functions
	- [x] last
	- [x] first
	- [x] max
	- [x] min
	- [x] mean
	- [x] median
	- [x] change%
	- [x] change
- [ ] Misc functions
	- [ ] merge
		- [x] Disaggregate before merge?
		- [ ] Join-style merges (inner, outer, left, right)
- [ ] aggregations in data pulling
	- [ ] agg
	- [x] disagg
- [x] higher frequency data

- [ ] cbd.data
	- [x] FRED API integration to know if a series pull is due to a bad name	
	- [x] Check if transformations exist explicitly
	- [x] Allow non-series strings to be entered as arguments with "double quotes.
	- [X] Enable multi-series functions to be called as operators. 
	
- [x] Create "CHIDATA" database and standard save format
	- [x] chidataseries function
	- [x] standardize Excel files
	
- [x] Remove financial toolbox calls

- [ ] Speed up merge et. al. using new datestr and datenum functions

- [ ] Add readtable to xlsfile

- [ ] array2cbdTable function 
- [ ] cbd.expression function 
	- [ ] Should takes fprintf style string along with cbd.data style functions and varargin to compute cbd functions on existing Matlab objects.
	- [ ] Potentially a replacement for datapull function in cbd.data

- [x] Enable a token to have a hash-option at the end of it. 
