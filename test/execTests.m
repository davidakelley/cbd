% execTests.m
% EXECTESTS runs all of the tests for the cbd toolbox
%
% Last updated January 2015

% David Kelley, 2015

addpath('O:\PROJ_LIB\Presentations\Chartbook\Data\Dataset Creation\cbd');


%% Run tests
testfiles = {'datatest.m', ...
    'expressiontest.m', ...
    'transformationtests.m', ...
    'summarizationtests.m', ...
    'multiseriestests.m', ...
    'aggregationtests.m'};

testresults = cell(length(testfiles), 1);

for iTest = 1:length(testfiles)
    testresults{iTest} = runtests(testfiles{iTest});
end

testresults = [testresults{:}];

display(testresults);