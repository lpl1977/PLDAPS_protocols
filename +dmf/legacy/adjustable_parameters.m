function adjustable_parameters(p)
%  PLDAPS ADJUSTABLE SETUP FILE
%  PACKAGE:  dmf

%  This file specifies parameters which can be adjusted during pauses
%  between trials.

switch lower(p.trial.session.subject)
    case {'murray','meatball'}
        p.trial.adjustable_parameters.deflection_threshold = 75;
    otherwise
        p.trial.adjustable_parameters.deflection_threshold = p.trial.features.symbol.displacement - 0.5*p.trial.features.symbol.diameter;
end
end

