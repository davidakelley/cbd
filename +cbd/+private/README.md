# +private functions
* The functions in the *+private* folder are used internally by other `cbd` functions

## Function descriptions
* `alignToDates` ~ aligns a dataset to a different set of dates
* `cbdTable` ~ creates CBD data table from components
* `endOfPer` ~ returns the last date within a period for each date in a vector
* `expression_eval` ~ evaluates a cbd expression with printf-style inpu
* `genDates` ~ creates a vector of serial dates at the end of the period type specified by freq from sDate to eDate.
* `getFreq` ~ determines the frequency of a series of serial dates
* `getpos` ~ get graphics object position in a flexible way
* `inputCBDdata` ~ takes apart a cbd table into its components
* `mdatenum` ~ converts a character array of dates in a datenum
* `mdatestr` ~ converts a date number to a string with format 'dd-mmm-yyyy'
* `midOfPer` ~ returns the middle date of a period
* `multiseriesFunction` ~ computes binary operations on cbd tables and scalars
* `parseDates` ~ transforms an input date from formatIn to formatOut
* `rename` ~ renames the table variables
* `setpos` ~ set graphics object position in a flexible way
* `startOfPer` ~ finds the first serial date of each period
* `tableDates` ~ returns the observation dates as datenum integers
