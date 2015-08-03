cbd.private functions
=====================
These functions are used internally by other cbd functions. There should be no reason to use them instead of the outer function that they are being used by. This sections is here only for documentation purposes. 
* alignToDates - Used by the merge function to alter the tables before concatenating.
* endOfPer - Returns dates shifted to the last day of the period (convention for cbd). Used to adjust Stata dates. 
* haverpull - Takes a single string of Haver series and transformations and returns a table with a single series. 
* haverseries - Takes a string of a Haver series (with no transformations!) and returns the level data. 
* haverpull_stata - Pulls data using a Stata batch job insead of with the Matlab Haver API if the datafeed toolbox licenses are all used (somewhat slower). 
* getFreq - Returns a string indicator of the frequency of a series based on the gaps in the dates. 
* parse_json - Used to parse the JSON response from FRED. Taken from FEX.
* rename - Renames a series in a table 