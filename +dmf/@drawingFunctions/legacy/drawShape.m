function drawShape(obj,windowPointer,xpos,ypos,color,shape)
%drawShape produce shape
%
%  drawShape(windowPointer,features,x,y,color,nvert,rot)

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
    Screen('FillOval',windowPointer,color,CenterRectOnPoint([0 0 D D],xpos,ypos)');
else
    %  Get vertices of polygon
    angles = (pi/2) + linspace(0,2*pi,nvert+1)+rot;
    x = sin(angles).*R;
    y = cos(angles).*R;
    vertices = [x ; y]';    
    Screen('FillPoly',windowPointer,color,vertices+repmat([xpos ypos],size(vertices,1),1),1);
end
