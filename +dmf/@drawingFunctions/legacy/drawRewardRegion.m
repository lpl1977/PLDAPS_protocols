function drawRewardRegion(obj,windowPointer,x,y,selected)
%  drawRewardRegion draw a circle around the reward region

width = 2*obj.features.symbolRadius + obj.features.rewardRegionBuffer;
unselectedColor = obj.features.rewardRegionBorderColor;
selectedColor = obj.features.rewardRegionSelectedBorderColor;

penWidth = obj.features.rewardRegionPenWidth;

if(selected)
    Screen('FrameOval',windowPointer,selectedColor,CenterRectOnPoint([0 0 width width],x,y)',penWidth);
else
    Screen('FrameOval',windowPointer,unselectedColor,CenterRectOnPoint([0 0 width width],x,y)',penWidth);
end