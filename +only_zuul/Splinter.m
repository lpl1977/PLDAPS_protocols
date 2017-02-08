function Splinter(p)
%  TRIAL PARAMETER FILE
%  PACKAGE:  set_trainer
%  TRIAL FUNCTION:  there_is_no_set.only_zuul
%  SUBJECT:  Splinter

%
%  TIMING
%

p.trial.task.timing.delay.duration = 0.3;

p.trial.task.timing.forward_mask.duration = 0;

p.trial.task.timing.response.grace = 15;

p.trial.task.timing.timeout.duration = 1;

p.trial.task.timing.error_penalty.duration = 1;

p.trial.task.timing.reward_delay.duration = 0;

%
%  JOYSTICK
%

%  Initialize joystick status tracking variables
%  Zone 1--joystick released
%  Zone 2--joystick engaged
%  Zone 3--joystick pressed
p.trial.joystick.threshold = [4 15];

%
%  Training flags
%
p.trial.task.training.must_repeat = true;

%
%  REWARDS
%

%  Reward amounts
p.trial.stimulus.reward_amount = 0.4;

%
%  Log contrast for release cue
%
p.trial.task.features.log10C = 0; %[-Inf -3 -2 0];
%p.trial.task.log_contrast_std = 0.05;
%p.trial.task.log_contrast_delta = 0.05;

%p.trial.task.log_contrast_support = [-2.5 -2.25 -2 -1.75 -1.5 -1.25];
