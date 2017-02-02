function drawSecondaryReinforcer(obj,windowPointer,x,y,ratio)
%  drawSecondaryReinforcer draw thesecondary reinforcer

width = obj.features.secondaryReinforcerWidth;
height = obj.features.secondaryReinforcerHeight;
borderColor = obj.features.secondaryReinforcerBorderColor;
interiorColor = obj.features.secondaryReinforcerInteriorColor;
penWidth = obj.features.secondaryReinforcerPenWidth;

ydisplacement = obj.features.symbolRadius + obj.features.rewardRegionBuffer + 0.5*obj.features.rewardRegionPenWidth;

frameRect = CenterRectOnPoint([0 0 width height],x,y-ydisplacement);
fillRect = frameRect;
fillRect(1) = fillRect(1) + round((1-ratio)*width);

if(fillRect(1)~=fillRect(3))
    Screen('FillRect',windowPointer,interiorColor,fillRect);
end

Screen('FrameRect',windowPointer,borderColor,frameRect,penWidth);


end