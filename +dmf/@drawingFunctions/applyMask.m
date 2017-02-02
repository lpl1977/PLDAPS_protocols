function applyMask(obj,texturePointer,mask)
%  applyMask Apply alpha masking function for pattern
%
%  drawingFunctions.applyMask(texturePointer,mask)

D = 2*obj.features.symbolRadius;
bgColor = obj.features.bgColor;

Screen('DrawTexture',texturePointer,mask,[],[],[],[],[],bgColor);

end

