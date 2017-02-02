function applyMask(obj,windowPointer,x,y,mask)
%  applyMask Apply alpha masking function for pattern
%
%  drawingFunctions.applyMask(windowPointer,x,y,mask)

D = 2*obj.features.symbolRadius;
bgColor = obj.features.bgColor;

Screen('DrawTexture',windowPointer,obj.maskTextures.(mask),[],CenterRectOnPoint([0 0 D D],x,y)',[],[],[],bgColor);

end

