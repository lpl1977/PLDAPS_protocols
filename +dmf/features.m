function p = features(p)
%  PLDAPS FEATURES FILE
%  PACKAGE:  dmf

%
%  This function is called each trial to set features
%

p.trial.features.target_diameter = 360;
p.trial.features.target_radius = 360;
p.trial.features.target_linewidth = 8;
p.trial.features.target_color = [0.4 0.4 0.4];

p.trial.features.cue_diameter = 312;
p.trial.features.cue_radius = 360;
p.trial.features.cue_color = [1 1 1];
end

