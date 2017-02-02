function insertShape(obj,texturePointer,shape)
%insertShape insert requested shape into the texture pointer
%
%  drawShape(obj,texturePointer,color,shape)

R = obj.features.symbolRadius;
D = 2*R;

switch shape
    case 'circle'
        nvert = Inf;
        rot = 0;
    case 'square'
        nvert = 4;
        rot = pi/4;
    case 'diamond'
        nvert = 4;
        rot = pi/2;
    case 'triangle'
        nvert = 3;
        rot = pi/2;
    case 'pentagon'
        nvert = 5;
        rot = pi/2;
    case 'hexagon'
        nvert = 6;
        rot = pi/2;
end

if(isinf(nvert))
    %  A circle is a polygon with infinite vertices...
    Screen('FillOval',texturePointer,1);
else
    %  Get vertices of polygon
    angles = (pi/2) + linspace(0,2*pi,nvert+1)+rot;
    x = sin(angles).*R;
    y = cos(angles).*R;
    vertices = [x ; y]';
    vertices = vertices + repmat([R R],size(vertices,1),1);
    
    Screen('FillPoly',texturePointer,1,vertices,1);
end
