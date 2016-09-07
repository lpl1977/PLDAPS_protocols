function init(diameter,colors,mix,rng_seed)
%INIT Initialize the symbol mask package
%  Prior to any other call to symbol mask functions, init generates the
%  coordinates of the symbol masks and the initial pixel color list.
%
%  Input arguments:
%  diameter--in pixels
%  colors--list
%  mix--list
%  rng_seed--from rng
%
%  Output arguments:
%  For now, none

%  Create pixel coordinates
[~,ndots] = only_zuul.symbol_masks.pixel_coords(diameter);

%  Create pixel color list for all three symbols
only_zuul.symbol_masks.pixel_color_list(ndots,colors,mix,rng_seed);
end

