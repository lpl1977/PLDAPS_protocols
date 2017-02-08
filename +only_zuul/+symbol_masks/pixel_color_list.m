function C = pixel_color_list(varargin)
%PIXEL_COLOR_LIST Create a list of pixel colors for the three masks
%  On first call generates a list of randomly ordered pixel colors for each
%  of the three masks and on later calls returns the coordinates.
%
%  Input arguments:
%  ndots--number of dots
%  colors--list of colors
%  mix--proportion of pixels with each color
%  rng_seed--random number generator seed
%  -or-
%  indices of pixel lists to obtain
%
%  Output arguments:
%  none
%  -or-
%  pixel color list

persistent Cmat
if(nargin==4)
    ndots = varargin{1};
    colors = varargin{2};
    mix = varargin{3};
    rng_seed = varargin{4};
    
    %  Create pixel color list
    a = zeros(1,ndots);
    indx = [0 ceil(ndots*cumsum(mix))];
    for i=1:length(indx)-1
        a(indx(i)+1:indx(i+1)) = i;
    end
    
    %  Shuffle order of pixels
    rng(rng_seed);
    Cmat = zeros(3,ndots);
    for i=1:3
        Cmat(i,:) = colors(a(randperm(ndots)));
    end
    C = true;
else
    C = reshape(Cmat(varargin{1},:)',[],1)';
end
end