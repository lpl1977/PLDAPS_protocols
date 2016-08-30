function Murray(p)
%  PLDAPS TRIAL PARAMETER FILE
%  PACKAGE:  only_zuul
%  TRIAL FUNCTION:  trial_function
%  SUBJECT:  Murray

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

p.trial.task.timing.delay.duration = 0.75;
p.trial.task.timing.symbol.display_time = 0.75;
p.trial.task.timing.symbol.interval = 0;

%  Randomized reward / error delay duration.
p.trial.task.timing.reward_delay.duration = min(exprnd(0.25),0.5);
p.trial.task.timing.error_delay.duration = p.trial.task.timing.reward_delay.duration;

%
%  Training flags
%
p.trial.task.training.repeat_errors = 0;
p.trial.task.training.continue_symbols = true;
p.trial.task.training.release_for_reward = false;
p.trial.task.training.shuffle_aborts = false;
p.trial.task.training.shuffle_repeats = false;
p.trial.task.training.relative_response_threshold = true;
p.trial.task.training.enforce_fixation = false;


%
%  Log contrast for discriminandum
%
p.trial.task.features.log10C = sort([-2 -1.75 -1.5 -1.25 -1],'descend');

%  Set the number of mask trials per set or noset trial
%  If maskratio is 1, then there is a mask trial for every set trial AND a
%  mask trial for every notset trial.  This means that the total number of
%  mask trials is double the number of set trials, or equal to the number
%  of set+notset trials.  If maskratio is 1:2, then there is a mask trial
%  for every two set trials and a mask trial for every two notset trials.
%  In this case (maskratio < 1), I will need to increase the number of set
%  and nottset trials.
p.trial.task.features.maskratio = 4;
p.trial.task.features.ntotal = 2000;

