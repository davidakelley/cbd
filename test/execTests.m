% execTests.m
% EXECTESTS runs all of the tests for the cbd toolbox
%
% Last updated January 2015

% David Kelley, 2015

addpath('O:\PROJ_LIB\Presentations\Chartbook\Data\Dataset Creation\cbd');

import matlab.unittest.TestSuite
import matlab.unittest.TestRunner
import matlab.unittest.plugins.CodeCoveragePlugin

%% Run tests
suite = TestSuite.fromFolder(pwd);

runner = TestRunner.withTextOutput;
runner.addPlugin(CodeCoveragePlugin.forFolder(pwd));
result = runner.run(suite);

display(testresults);