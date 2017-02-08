function [XY,N] = pixel_coords(varargin)
%PIXEL_COORDS Create or return pixel coordinates
%  On first call generates a list of pixel coordinates and on later calls
%  returns the coordinates.
%
%  Input arguments:
%  diameter--diameter of circle; forces generation of the coordiantes
%
%  Output arguments:
%  XY--pixel coordinates
%  N--number of pixels

persistent xy n
if(nargin~=0)
    d = varargin{1};

    %  Set coordinates of pixels
    [x,y] = meshgrid(1:d,1:d);
    x = x(:) - d/2;
    y = y(:) - d/2;
    
    %  Include only pixels within the diameter
    r = sqrt(x.^2 + y.^2);
    ix = r <= d/2;
    xy = [x(ix)'; y(ix)'];
    n = size(xy,2);
    XY = xy;
    N = n;
else
    XY = xy;
    N = n;
end
end