% execTests.m
% EXECTESTS runs all of the tests for the cbd toolbox

% David Kelley, 2015

baseDir = 'O:\PROJ_LIB\Presentations\Chartbook\Data\Dataset Creation\cbd';
addpath(baseDir);

import matlab.unittest.TestSuite
import matlab.unittest.TestRunner
import matlab.unittest.plugins.CodeCoveragePlugin

%% Run tests
suite = TestSuite.fromFolder([baseDir '\test']);

runner = TestRunner.withTextOutput;
runner.addPlugin(CodeCoveragePlugin.forFolder([baseDir '\+cbd']));
result = runner.run(suite);

display(result);