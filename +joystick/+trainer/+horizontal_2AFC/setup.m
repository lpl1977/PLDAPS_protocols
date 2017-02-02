function p = setup(p)
%  PLDAPS SETUP FILE
%  PACKAGE:  joystick.trainer.horizontal_target

%  This setup file is for a joystick training protocol in which the monkey
%  must move the joystick cursor over a target to get a reward.

%  Set trial master function
p.trial.pldaps.trialFunction = 'joystick.trainer.horizontal_2AFC.trial_function';

%  Get default colors and put the default bit names
p = defaultColors(p);
p = defaultBitNames(p);

%  Custom colors
p = LovejoyDefaultColors(p);

%  Trial duration information--he'll have five minutes to figure it out per
%  trial
p.trial.pldaps.maxTrialLength = 5*60;
p.trial.pldaps.maxFrames = p.trial.pldaps.maxTrialLength*p.trial.display.frate;

%  Conditions--left or right
c = cell(1,2);
c{1}.direction = 'left';
c{2}.direction = 'right';
% c{3}.direction = 'right';
% c{4}.direction = 'right';

c = repmat(c,1,500);
p.conditions = Shuffle(c);
p.trial.pldaps.finish = length(p.conditions);

p.functionHandles.correct = 0;
p.functionHandles.incorrect = 0;
