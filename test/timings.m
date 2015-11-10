function timings()

% addpath('O:\PROJ_LIB\Presentations\Chartbook\Data\Dataset Creation\cbd');
maxLen = 20;

%% Timing
t1a = timeit(@() cbd.data('LR'));
t1b = timeit(@() cbd.data('GDPH'));
t2 = timeit(@() cbd.data('FCM10@DAILY'));
t3 = timeit(@() cbd.data('FCM10@CHIDATA'));

lr = cbd.data('LR');
gdph = cbd.data('GDPH');
fcm10 = cbd.data('FCM10@DAILY');

t4a = timeit(@() cbd.merge(lr, gdph));
t4b = timeit(@() cbd.merge(lr, fcm10));
t5 = timeit(@() cbd.agg(lr, 'Q', 'AVG'));
t6 = timeit(@() cbd.agg(fcm10, 'M', 'NANAVG'));

%% Print
fprintf('\nCBD BENCHMARKING\n%s\n', datestr(now()));
sectionBreak();
printTiming('data: LR', t1a);
printTiming('data: GDPH', t1b);
printTiming('data: FCM10@DAILY', t2);
printTiming('data: FCM10@CHIDATA', t3);

sectionBreak();
printTiming('merge: LR & GDPH', t4a);
printTiming('merge: LR & FCM10', t4b);
printTiming('agg: M -> Q', t5);
printTiming('agg: D -> M', t6);

sectionBreak();
printTiming('Total', sum([t1a, t1b, t2, t3, t4a, t4b, t5, t6]));


function sectionBreak()
fprintf('%s\n', repmat('=', [1 maxLen+7]));
end

function printTiming(strIn, timeIn)
fprintf('%s%s | %3.2f\n', strIn, repmat(' ', [1, maxLen - length(strIn)]), timeIn);
end

end
