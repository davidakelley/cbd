function result = execTests()
%EXECTESTS runs all of the tests for the cbd toolbox
%
% David Kelley, 2015
% Santiago I. Sordo-Palacios, 2019

% Add the path to the testing folder
thisFile = mfilename('fullpath');
baseDir = fileparts(thisFile);
addpath(genpath(baseDir));

% Import the necessary runners of the suite
import matlab.unittest.TestSuite
import matlab.unittest.TestRunner
import matlab.unittest.plugins.CodeCoveragePlugin

% Creat the test suite
suite = TestSuite.fromFolder( ...
    fullfile(baseDir, 'test'), ...
    'IncludingSubfolders', true);
runner = TestRunner.withTextOutput;
runner.addPlugin( ...
    CodeCoveragePlugin.forFolder( ...
    fullfile(baseDir , '+cbd'), ...
    'IncludingSubfolders', true));

% Run the test suite and print results
result = runner.run(suite);
display(result);

end % function