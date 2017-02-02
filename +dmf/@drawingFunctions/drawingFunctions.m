classdef drawingFunctions < handle
    %class for producing drawing functions in dmf task
    
    properties
        
        %  vector of texture pointers
        patternMaskTexturePointers
        shapeTexturePointers

        shapes
        patternMasks
        
        
        %         symbol = struct('radius',[],'displacement',[],'nSpatialCycles',[],'nThetaCycles',[]);
        %         reward_region = struct('border_color',[],'buffer',[],'penwidth',[]);
        %         secondary_reinforcer = struct('width',[],'height',[],'border_color',[],'interior_color',[],'penwidth',[]);
        features = struct(...
            'symbolRadius',[],...
            'nSpatialCycles',[],...
            'nThetaCycles',[],...
            'rewardRegionBuffer',[],...
            'rewardRegionBorderColor',[],...
            'rewardRegionSelectedBorderColor',[],...
            'rewardRegionPenWidth',[],...
            'bgColor',[],...
            'secondaryReinforcerWidth',[],...
            'secondaryReinforcerHeight',[],...
            'secondaryReinforcerBorderColor',[],...
            'secondaryReinforcerInteriorColor',[],...
            'secondaryReinforcerPenWidth',[]);
        
    end
    
    methods
        
        %  Class constructor
        function obj = drawingFunctions(features,patternMasks,shapes)
            objFields = fieldnames(obj.features);
            inptFields = fieldnames(features);
            sharedFields = intersect(objFields,inptFields);
            for i=1:length(sharedFields)
                obj.features.(sharedFields{i}) = features.(sharedFields{i});
            end
            obj.patternMasks = patternMasks;
            obj.shapes = shapes;
        end
        
        %  insertShape
        %
        %  Function to write the requested shape into the shape template
        insertShape(obj,windowPointer,shape)
        
        
        applyMask(obj,windowPointer,x,y,mask)
        drawRewardRegion(obj,windowPointer,x,y,selected)
        
        %  generatePatternMaskTextures
        %
        %  Function to generate the pattern mask texture pointers
        function obj = generatePatternMaskTextures(obj,windowPointer)
            for i=1:length(obj.patternMasks)
                mask = obj.makePatternMask(obj.patternMasks{i});
                obj.patternMaskTexturePointers.(obj.patternMasks{i}) = Screen('MakeTexture',windowPointer,mask);
            end
        end
        
        %  generateShapeTextures
        %
        %  Function to generate the shape texture pointers
        function obj = generateShapeTextures(obj,windowPointer)            
            D = 2*obj.features.symbolRadius;
            bgColor = obj.features.bgColor;
            for i=1:length(obj.shapes)
                obj.shapeTexturePointers.(obj.shapes{i}) = Screen('OpenOffscreenWindow', windowPointer, [bgColor 0], [0 0 D D]);
                obj.insertShape(obj.shapeTexturePointers.(obj.shapes{i}),obj.shapes{i})
            end
        end
        
        %  generateSymbolTextures
        %
        %  Function to generate the symbol texture pointers
        function obj = generateSymbolTextures(obj,windowPointer,symbolCodes,features)
            D = 2*obj.features.symbolRadius;
            bgColor = obj.features.bgColor;
            
            nSymbols = size(symbolCodes,1);
            obj.symbolTexturePointers = zeros(nSymbols,1);
            for i=1:nSymbols
                
                %  Open off screen window into which we will draw; it should be
                %  fully transparent but have the regular background color.
                obj.symbolTexturePointers(i) = Screen('OpenOffScreenWindow',windowPointer,[bgColor 0],[0 0 D D]);
                
                %  Write the shape into the texture pointer
                obj.insertShape(obj.symbolTexturePointers(i),obj.shapes{i});
                %  Set the alpha blending
                
                %  Write the pattern mask into the alpha channel
            end
        end
        
        %
        %
        %             texture = Screen('OpenOffScreenWindow',windowPointer,255*[obj.features.bgColor 0],[0 0 D D]);
        %
        %             %  Draw the shape into the texture
        %             obj.drawShape(texture,color,shape);
        %
        %             %  Apply the mask
        %             mask = obj.makePatternMask(pattern);
        %             temp = Screen('MakeTexture',windowPointer,255*mask);
        %        Screen('DrawTexture',texture,temp,[],[],[],[],[],obj.features.bgColor);
        
        
        
        %Screen('DrawTexture',windowPointer,obj.maskTextures.(mask),[],CenterRectOnPoint([0 0 D D],x,y)',[],[],[],bgColor);
        
        %  drawPatternMaskTextures
        %
        %  Function to draw the texture pointer to the screen
        function obj = drawPatternMaskTextures(obj,windowPointer,pattern,xypos)
            D = 2*obj.features.symbolRadius;
            rect = repmat([0 0 D D],length(pattern),1);
            texturePointers = zeros(length(pattern),1);
            for i=1:length(pattern)
                rect(i,:) = CenterRectOnPoint(rect(i,:),xypos(i,1),xypos(i,2));
                texturePointers(i) = obj.patternMaskTexturePointers.(pattern{i});
            end
            Screen('DrawTextures',windowPointer,texturePointers,[],rect',[],[],[],obj.features.bgColor);

            %            Screen('DrawTexture',windowPointer,obj.patternMaskTexturePointers.(pattern{i}),[],rect(i,:),[],[],[],obj.features.bgColor);
%Screen('DrawTexture',windowPointer,obj.maskTextures.(mask),[],CenterRectOnPoint([0 0 D D],x,y)',[],[],[],bgColor);
        end
        
        %  drawShapeTextures
        %
        %  Function to draw the texture pointer to the screen
        function obj = drawShapeTextures(obj,windowPointer,shape,color,xypos)
            D = 2*obj.features.symbolRadius;
            rect = repmat([0 0 D D],length(shape),1);
            shapePointers = zeros(length(shape),1);
            for i=1:length(shape)
                rect(i,:) = CenterRectOnPoint(rect(i,:),xypos(i,1),xypos(i,2));
                shapePointers(i) = obj.shapeTexturePointers.(shape{i});
            end
            Screen('DrawTextures',windowPointer,shapePointers,[],rect',[],[],[],color');
                %Screen('DrawTexture', win, template, [], myrect(:,j)', [], 0, [], colors(:,j)');
            
%Screen('DrawTexture',windowPointer,obj.maskTextures.(mask),[],CenterRectOnPoint([0 0 D D],x,y)',[],[],[],bgColor);
        end
        
        
        mask = makePatternMask(obj,pattern)
    end
    
    
end

