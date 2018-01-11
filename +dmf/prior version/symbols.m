classdef symbols < handle
    %symbols object to produce symbols for dmf task
    
    properties
        windowPtr
        bgColor
        radius
        width        
        ptr
        colors
        fills
        shapes
    end
    
    methods
        
        function make(obj,indx,color,shape,fill)
            
            color = obj.colors(color,:);
            shape = obj.shapes{shape};
            fill = obj.fills{fill};
            
            obj.ptr(indx) = Screen('OpenOffScreenWindow',obj.windowPtr,obj.bgColor,obj.rect);
            
            %  Write shape into the texture pointer
            switch shape
                case 'circle'
                    Screen('FillOval',obj.ptr(indx),color,[0 0 obj.width obj.width]);
                otherwise
                    switch shape
                        case 'square'
                        case 'diamond'
                        case 'balbis'
                        case 'triangle1'
                        case 'triangle2'
                        case 'triangle3'
                        case 'traingle4'
                        case 'plus1'
                        case 'plus2'
                        case 'star1'
                        case 'star2'
                    end
            end
                case 'upTriangle'
                    vertexAngles = pi + linspace(0,2*pi,4);
                    vertices = [sin(vertexAngles) ; cos(vertexAngles)]';
                    Screen('FillPoly',obj.ptr(indx),color,obj.radius*vertices + repmat([obj.radius obj.radius],size(vertices,1),1));
            end
        end
        
    end
    
end

