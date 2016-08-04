% execTests.m
% EXECTESTS runs all of the tests for the cbd toolbox

% David Kelley, 2015

thisFile = mfilename('fullpath');
baseDir = thisFile(1:subsref(strfind(thisFile, 'cbd'), struct('type', '()', 'subs', {{1}}))+2);

addpath(baseDir);

import matlab.unittest.TestSuite
import matlab.unittest.TestRunner
import matlab.unittest.plugins.CodeCoveragePlugin

%% Run tests
suite = TestSuite.fromFolder([baseDir '\test']);
% suite = TestSuite.fromFile([baseDir '\test\disaggregationtests.m']);

runner = TestRunner.withTextOutput;
runner.addPlugin(CodeCoveragePlugin.forFolder([baseDir '\+cbd']));
result = runner.run(suite);

display(result);