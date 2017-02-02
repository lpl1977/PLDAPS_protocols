function p = features(p)
%  PLDAPS FEATURES FILE
%  PACKAGE:  joystick.trainer.horizontal_2AFC

%
%  This function is called each trial to set features
%

p.trial.features.target_diameter = 400;
p.trial.features.target_radius = 350;
p.trial.features.target_linewidth = 8;
p.trial.features.target_color = [0.4 0.4 0.4];

p.trial.features.cue_diameter = 250;
p.trial.features.cue_radius = 350;
p.trial.features.cue_color = [1 1 1];
end

