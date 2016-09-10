function Murray(p)
%  PLDAPS TRIAL PARAMETER FILE
%  PACKAGE:  only_zuul
%  TRIAL FUNCTION:  trial_function
%  SUBJECT:  Murray

%
%  Debug flags
%
p.trial.debug_flags.joystick_zombie = false;

%
%  Constants for Eyelink calibration
%
p.trial.stimulus.fixdotW = 100;  % Calibration target size in pixels
p.trial.stimulus.fpWin = p.trial.display.ppd*[10 10] ; % rectangular fixation window in pixels

%
%  REWARDS
%

%  Reward amounts
p.trial.stimulus.reward_amount = 0.5;

%
%  TIMING
%

p.trial.specs.timing.delay.duration = 0.75;
p.trial.specs.timing.symbol.display_time = 0.75;
p.trial.specs.timing.symbol.interval = 0;

%  Randomized reward / error delay duration.
max_delay = 1.25;
constant_part = 0.;
mean_random_part = 0;

% max_delay = 1.25;
% constant_part = 0.5;
% mean_random_part = 0.5;
random_part = min(exprnd(mean_random_part),max_delay-constant_part);
p.trial.specs.timing.reward_delay.duration = constant_part + random_part;
p.trial.specs.timing.error_delay.duration = p.trial.specs.timing.reward_delay.duration;

%
%  Training flags
%
p.trial.training_flags.repeat_errors = 0;
p.trial.training_flags.continue_symbols = true;
p.trial.training_flags.release_for_reward = false;
p.trial.training_flags.shuffle_aborts = false;
p.trial.training_flags.shuffle_repeats = false;
p.trial.training_flags.relative_response_threshold = true;
p.trial.training_flags.enforce_fixation = false;


%
%  Log contrast for discriminandum
%
%p.trial.specs.features.log10C = sort([-1 -1.25 -1.5 -1.75 -2],'descend');
p.trial.specs.features.log10C = sort([-1 -1.25 -1.5],'descend');
%p.trial.specs.features.log10C = sort(-1,'descend');


%  Set the number of mask trials per set or noset trial
%  If maskratio is 1, then there is a mask trial for every set trial AND a
%  mask trial for every notset trial.  This means that the total number of
%  mask trials is double the number of set trials, or equal to the number
%  of set+notset trials.  If maskratio is 1:2, then there is a mask trial
%  for every two set trials and a mask trial for every two notset trials.
%  In this case (maskratio < 1), I will need to increase the number of set
%  and nottset trials.
p.trial.specs.features.maskratio = 2;
p.trial.specs.features.ntotal = 2000;

