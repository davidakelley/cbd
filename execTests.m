function result = execTests(package)
%EXECTESTS runs all of the tests for the cbd toolbox
%
% David Kelley, 2015
% Santiago I. Sordo-Palacios, 2019

% Handle inputs
if nargin < 1 || isempty(package)
    package = 'all';
end % if-nargin

switch package
    case 'all'
        testFolder = 'test';
        codeFolder = '+cbd';
        includeSub = true;
    case 'base'
        testFolder = 'test';
        codeFolder = '+cbd';
        includeSub = false;
    case 'chidata'
        testFolder = 'test/chidata';
        codeFolder = '+cbd/+chidata';
        includeSub = false;
    case 'source'
        testFolder = 'test/source';
        codeFolder = '+cbd/+source';
        includeSub = false;
    case 'private'
        testFolder = 'test/privatefun';
        codeFolder = '+cbd/+private';
        includeSub = false;
    otherwise
        error('execTest:packageSpec', ...
            'Option "%s" as package not supported in execTests', package);
end % switch-case

% Display a message
fprintf('\nExecuting %s cbd tests\n\n', package); 

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
    fullfile(baseDir, testFolder), ...
    'IncludingSubfolders', includeSub);
runner = TestRunner.withTextOutput;
runner.addPlugin( ...
    CodeCoveragePlugin.forFolder( ...
    fullfile(baseDir , codeFolder), ...
    'IncludingSubfolders', includeSub));

% Run the test suite and print results
result = runner.run(suite);
display(result);

end % function