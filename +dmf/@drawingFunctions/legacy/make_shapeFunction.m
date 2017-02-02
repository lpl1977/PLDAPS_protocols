function shapeFunction = make_shapeFunction(obj,shape,rotation)
%make_shapeFunction produce shape function prototype for symbols
%
%  shapeFunction = make_shapeFunction(obj,shape,rotation)
%
%  make_shapeFunction creates a handle to a function taking as its argument
%  the window, color, and screen position in pixels where we should draw
%  the symbol prototype. The symbol has properties specified in obj (the
%  symbol object) with the given shape

windowPointer = obj.windowPointer;
D = 2*obj.symbol.radius;
R = obj.symbol.radius;

if(nargin~=3)
    rotation = 0;
end

if(strcmpi(shape,'circle'))
    shapeFunction = @(c,x,y) Screen('FillOval',windowPointer,c,...
        CenterRectOnPoint([0 0 D D],x,y)');
else
    
    switch lower(shape)
        case 'square'
            vertices = polygon(4,R,pi/4+rotation);
        case 'diamond'
            vertices = polygon(4,R,pi/2+rotation);
        case 'triangle'
            vertices = polygon(3,R,pi/2+rotation);
        case 'pentagon'
            vertices = polygon(5,R,pi/2+rotation);
        case 'hexagon'
            vertices = polygon(6,R,pi/2+rotation);
    end
    
    shapeFunction = @(c,x,y) Screen('FillPoly',windowPointer,c,...
        vertices+repmat([x y],size(vertices,1),1),1);
end
end

%  vertices = polygon(numVertices,radius,rotationAngle)
%  vertices is a matrix with vertices in columns
%  numVertices is the number of polygon vertices
%  rotationAngle is the angle of the first vertex
function vertices = polygon(numVertices,radius,rotationAngle)
angles = (pi/2) + linspace(0,2*pi,numVertices+1)+rotationAngle;
x = sin(angles).*radius;
y = cos(angles).*radius;
vertices = [x ; y]';
end

