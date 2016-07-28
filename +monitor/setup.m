function p = setup(p)
%PLDAPS setup file for monitor calibration

%  Check and make sure the spectrophotometer is connected
if(~I1('IsConnected'))
    fprintf('Please connect the X-Rite i1Pro spectrophotometer and try again.\n');
    while(~I1('IsConnected'))
        pause(0.1);
    end
end
fprintf('X-Rite i1Pro spectrophotometer detected.\n');

%  Start calibration sequence
fprintf('Please place i1Pro on the ceramic tile to begin and then press a button.\n');
while(~I1('KeyPressed'))
    pause(0.1)
end
I1('Calibrate');
fprintf('Please place i1Pro on monitor then press any key to continue.\n');
pause;

%  Set trial master function
p.trial.pldaps.trialFunction = 'monitor.calibrate';

%  Fire off some defaults we need
p = defaultColors(p);
p = defaultBitNames(p);
p.trial.sound.use = false;

% Time delay for measurement starts
p.trial.stimulus.delay = 1;

%  Some other things we need
p.trial.stimulus.eyeW = 8;    % eye indicator width in pixels
p.trial.stimulus.fixdotW   = 8;    % width of the fixation dot
p.trial.stimulus.targdotW  = 8;    % width of the target dot
p.trial.stimulus.cursorW   = 8;   % cursor width in pixels

%  Trial duration information
p.trial.pldaps.maxTrialLength = 1000;
p.trial.pldaps.maxFrames = p.trial.pldaps.maxTrialLength*p.trial.display.frate;

%  Set up condition array--luminances to use
lum = linspace(0,1,128);
c = cell(1,length(lum));
for i=1:length(lum)
    c{i}.stimulus = lum(i)*ones(1,3);
    c{i}.Nr=i;
end
%c = repmat(c,1,2);
p.conditions=Shuffle(c);

%  Maximum number of trials
p.trial.pldaps.finish = length(c);
