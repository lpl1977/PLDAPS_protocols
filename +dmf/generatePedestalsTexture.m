function pedestalsTexture = generatePedestalsTexture(p)
%generatePedestalsTexture function to generate the pedestal background frame
%
%  pedestalTexture = generatePedestalsTexture(p)
%
%  pedestalsTExture is a texture pointer

%  Extract components of input structure
symbolCenters = p.functionHandles.geometry.symbolCenters;
baseRect = [0 0 p.functionHandles.geometry.symbolRadius p.functionHandles.geometry.symbolRadius];
bgColor = p.functionHandles.colors.background;
pedestalColor = p.functionHandles.colors.pedestal;

%  Write pedestals
pedestalsTexture = Screen('OpenOffScreenWindow',p.trial.display.ptr,[bgColor 1]);

%  Write the pedestals into the texture
for i=1:3
    centeredRect = CenterRectOnPoint(baseRect,symbolCenters(i,1),symbolCenters(i,2));
    Screen('FillOval',pedestalsTexture,pedestalColor,centeredRect);
end