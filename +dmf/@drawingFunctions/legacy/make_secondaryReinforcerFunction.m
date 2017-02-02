function secondaryReinforcerFunction = make_secondaryReinforcerFunction(obj)
%  make_secondaryReinforcerFunction produce a function to make the
%  secondary reinforcer

width = obj.secondary_reinforcer.width;
height = obj.secondary_reinforcer.height;
border_color = obj.secondary_reinforcer.border_color;
interior_color = obj.secondary_reinforcer.interior_color;
penwidth = obj.secondary_reinforcer.penwidth;

windowPointer = obj.windowPointer;

ydisplacement = obj.symbol.radius + obj.reward_region.buffer;

secondaryReinforcerFunction = @(ratio,x,y) draw_func(ratio,x,y);

    function draw_func(r,X,Y)
        frameRect = CenterRectOnPoint([0 0 width height],X,Y-ydisplacement);
        fillRect = frameRect;
        fillRect(1) = fillRect(1) + round((1-r)*width);

        if(fillRect(1)~=fillRect(3))
            Screen('FillRect',windowPointer,interior_color,fillRect);
        end
        
        Screen('FrameRect',windowPointer,border_color,frameRect,penwidth);
    end

end