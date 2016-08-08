 function Meatball(p)
%  TRIAL PARAMETER FILE
%  PACKAGE:  set_trainer
%  TRIAL FUNCTION:  there_is_no_set.only_zuul
%  SUBJECT:  Meatball (aka Spaghetti)

%
%  REWARDS
%

%  Reward amounts
p.trial.stimulus.reward_amount = 0.5;

%
%  TIMING
%

p.trial.task.timing.delay.duration = 0.75;

p.trial.task.timing.symbol.duration = 0.75;

%p.trial.task.timing.reward_delay.duration = 0.75;
p.trial.task.timing.reward_delay.duration = 0;

p.trial.task.timing.error_delay.duration = p.trial.task.timing.reward_delay.duration;

%
%  Training flags
%
p.trial.task.training.repeat_priority = 1;
p.trial.task.training.use_symbol_masks = true;
p.trial.task.training.continue_symbols = true;
p.trial.task.training.release_for_reward = true;
p.trial.task.training.shuffle_aborts = false;
p.trial.task.training.shuffle_repeats = false;
p.trial.task.training.relative_response_threshold = true;


%
%  Log contrast for release cue
%
p.trial.task.features.log10C = [-2.0 -1.5 -1.0];