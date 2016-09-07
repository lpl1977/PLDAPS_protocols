function [XY,CP] = pixel_coords(varargin)
%PIXEL_COORDS create or return pixel coordinates and logical index of cue
%  On first call generates a list of pixel coordinates and on later calls
%  returns the coordinates.
%
%  Input arguments:
%  noise_dim--outer and inner diameter of noise ring
%  cue_dim--outer and inner diameter of cue ring
%  -or-
%  none
%
%  Output arguments:
%  XY--coordinates
%  CPI--cue pixel indices

persistent xy cue_pixel_indices
if(nargin==2)
    
    %  Extract arguments
    noise_dim = varargin{1};
    cue_dim = varargin{2};
    noise_outer_diameter = noise_dim(1);
    noise_inner_diameter = noise_dim(2);
    cue_outer_diameter = cue_dim(1);
    cue_inner_diameter = cue_dim(2);
    
    %  Get coordinates and radii of dots
    [x,y] = meshgrid(1:noise_outer_diameter,1:noise_outer_diameter);
    x = x(:) - noise_outer_diameter/2;
    y = y(:) - noise_outer_diameter/2;
    r = sqrt(x.^2 + y.^2);
    
    %  dots included within noise annulus
    indx = r <= noise_outer_diameter/2 & r >= noise_inner_diameter/2;
    xy = [x(indx)'; y(indx)'];
    
    %  dots within cue
    cue_pixel_indices = r(indx) <= cue_outer_diameter/2 & r(indx) >= cue_inner_diameter/2;
end

%  return the coordinates and logical index of cue dots
XY = xy;
CP = cue_pixel_indices;
end