function seed = preserve_seed(varargin)
persistent rng_seed
if(nargin~=0)
    rng_seed = varargin{1};
end
seed = rng_seed;
end
