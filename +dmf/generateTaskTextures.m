function taskTextures = generateTaskTextures(p)
%generateTaskTextures function to generate the task textures
%
%  taskTextures = generateTaskTextures(p)
%
%  taskTextures is a vector of four texture pointers:
%  1--pedestals only
%  2--comparators and pedestal at probe position
%  3--pedestals at comparator position and probe present
%  4--comparators and probe present

%  Extract components of input structure
symbolCenters = p.functionHandles.geometry.symbolCenters;
selectedSet = p.trial.condition.selectedSet;
symbolTextures = p.functionHandles.symbolTextures;
baseRect = [0 0 2*p.functionHandles.geometry.symbolRadius 2*p.functionHandles.geometry.symbolRadius];
bgColor = p.functionHandles.features.bgColor;

taskTextures = zeros(4,1);
for i=1:4
    taskTextures(i) = Screen('OpenOffScreenWindow',p.trial.display.ptr,[bgColor 1]);
    for j=1:3
        centeredRect = CenterRectOnPoint(baseRect,symbolCenters(i,1),symbolCenters(i,2));
        Screen('FillOval',pedestalTexture,pedestalColor,centeredRect);
    end
end

%  texture 2--comparators present, no probe
centeredRect = CenterRectOnPoint(baseRect,symbolCenters(j,1),symbolCenters(j,2));
Screen('DrawTexture',setTextures(i),symbolTextures(selectedSet(j)),[],centeredRect,[],[],alpha);
centeredRect = CenterRectOnPoint(baseRect,symbolCenters(j,1),symbolCenters(j,2));
Screen('DrawTexture',setTextures(i),symbolTextures(selectedSet(j)),[],centeredRect,[],[],alpha);

%  texture 3--comparators absent, probe present
centeredRect = CenterRectOnPoint(baseRect,symbolCenters(j,1),symbolCenters(j,2));
Screen('DrawTexture',setTextures(i),symbolTextures(selectedSet(j)),[],centeredRect,[],[],alpha);

%  texture 4--comparators and probe present
for j=1:3
    centeredRect = CenterRectOnPoint(baseRect,symbolCenters(j,1),symbolCenters(j,2));
    Screen('DrawTexture',setTextures(i),symbolTextures(selectedSet(j)),[],centeredRect,[],[],alpha);
end