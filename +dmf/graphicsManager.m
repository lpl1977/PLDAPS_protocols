classdef graphicsManager < handle
    %graphicsManager Generate and display graphics for dmf
    %   Produce symbol textures and graphics for trials of the dmf task
    %
    %  Lee Lovejoy
    %  ll2833@columbia.edu
    %  June 2017
    
    properties
        symbolTextures
        symbolFeatures
        symbolCodes
        symbolRadius
        symbolCenters
        
        patternProperties
        
        pedestalTexture
        pedestalColor = [0.4 0.4 0.4];
        pedestalRadius
        pedestalRect
        
        colorLibrary
        backgroundColor = [0.5 0.5 0.5];
        
        windowPtr
        
        textureWidth
        
        centeredRects
        
        textures
        
        queryStates
        instructStates
        
        stateNames
        
        trainingMode = false;
        trainingAlpha = 1;
    end
    
    methods
        
        %  Class constructor
        %
        %
        function obj = graphicsManager(varargin)
            
            %  Input arguments
            for i=1:2:nargin
                obj.(varargin{i}) = varargin{i+1};
            end
            
            %  Prepare frequently used variables
            obj.textureWidth = 2*obj.pedestalRadius;
            obj.pedestalRect = [0 0 obj.textureWidth obj.textureWidth];
            obj.centeredRects = CenterRectOnPoint(obj.pedestalRect,obj.symbolCenters(:,1),obj.symbolCenters(:,2))';
            obj.stateNames = unique([obj.queryStates obj.instructStates]);
            obj.textures = zeros(length(obj.stateNames),1);
            for i=1:length(obj.textures)
                obj.textures(i) = Screen('OpenOffScreenWindow',obj.windowPtr,obj.backgroundColor);
            end

            %  Generate pedestal texture
            obj.pedestalTexture = Screen('OpenOffScreenWindow',obj.windowPtr,obj.backgroundColor,obj.pedestalRect);
            Screen('FillOval',obj.pedestalTexture,obj.pedestalColor,obj.pedestalRect);
            
            %  Generate symbol textures
            nSymbols = size(obj.symbolCodes,1);
            obj.symbolTextures = zeros(nSymbols,1);
            for i=1:nSymbols
                
                %  Symbol features
                symbolColor = obj.colorLibrary.(obj.symbolFeatures.colors{obj.symbolCodes(i,1)});
                symbolPattern = obj.symbolFeatures.patterns{obj.symbolCodes(i,2)};
                symbolShape = obj.symbolFeatures.shapes{obj.symbolCodes(i,3)};
                
                %  Create a texture into which we will write the symbol
                obj.symbolTextures(i) = Screen('OpenOffScreenWindow',obj.windowPtr,obj.backgroundColor,obj.pedestalRect);
                
                %  Write the pedestal into the texture.
                Screen('FillOval',obj.symbolTextures(i),obj.pedestalColor,obj.pedestalRect);
                
                %  Write the shape into the texture with the specified
                %  color
                Screen('FillPoly',obj.symbolTextures(i),symbolColor,polygonVertices(symbolShape));
                
                %  Create a mask texture that has the same color as the
                %  pedestal and write it into the texture.  Note that we
                %  don't want to change the destination texture's alpha
                %  channel.
                Screen('Blendfunction',obj.symbolTextures(i),'GL_SRC_ALPHA','GL_ONE_MINUS_SRC_ALPHA',[1 1 1 0]);
                Screen('DrawTexture',obj.symbolTextures(i),Screen('MakeTexture',obj.windowPtr,patternMask(symbolPattern)),[],[],[],[],[],obj.pedestalColor);
                
                %  Add an outline to the symbol
                Screen('FramePoly',obj.symbolTextures(i),symbolColor,polygonVertices(symbolShape),2);
            end
            
            %  nested function polygonVertices
            function vertices = polygonVertices(shape)
                switch shape
                    case 'square'
                        nvert = 4;
                        rot = pi/4;
                    case 'diamond'
                        nvert = 4;
                        rot = pi/2;
                    case 'triangle'
                        nvert = 3;
                        rot = pi/2;
                    case 'pentagon'
                        nvert = 5;
                        rot = pi/2;
                    case 'hexagon'
                        nvert = 6;
                        rot = pi/2;
                end
                angles = (pi/2) + linspace(0,2*pi,nvert+1)+rot;
                x = sin(angles).*obj.symbolRadius;
                y = cos(angles).*obj.symbolRadius;
                vertices = [x ; y]';
                vertices = vertices + repmat([obj.pedestalRadius obj.pedestalRadius],size(vertices,1),1);
            end
            
            %  nested function patternMask
            function mask = patternMask(pattern)
                
                d = obj.pedestalRadius/obj.symbolRadius;
                [x,y] = meshgrid(linspace(-d,d,obj.textureWidth),linspace(-d,d,obj.textureWidth));
                [~,r] = cart2pol(x,y);
                mask = ones(obj.textureWidth,obj.textureWidth,2);
                
                switch pattern
                    case 'concentricCircles'
                        mask(:,:,2) = 0.5*(1-cos(pi*obj.patternProperties(1)*r)).*(r<1);
                    case 'horizontalLines'
                        mask(:,:,2) = 0.5*(1-cos(pi*obj.patternProperties(1)*y)).*(r<1);
                    case 'verticalLines'
                        mask(:,:,2) = 0.5*(1-cos(pi*obj.patternProperties(1)*x)).*(r<1);
                    case 'waffle'
                        mask(:,:,2) = (1 - 0.5*max((1-cos(pi*obj.patternProperties(1)*x)),(1-cos(pi*obj.patternProperties(1)*y)))).*(r<1);
                    case 'solid'
                        mask(:,:,2) = 0;
                    case 'blank'
                        mask(:,:,2) = r<1;
                end
                mask = 255*max(min(mask,1),0);
            end
        end
        
        %  getTexture
        %
        %  Retrieve the texture associated with a state
        function texture = getTexture(obj,state)
            
            %  Check requested state against list
            indx = strcmpi(state,obj.stateNames);
            if(~indx)
                texture = Screen('OpenOffScreenWindow',obj.windowPtr,obj.backgroundColor);
                obj.textures(end+1) = texture;
                obj.stateNames = [obj.stateNames {state}];
            else
                texture = obj.textures(indx);
            end
        end
        
        %  prepareTextures
        %
        %  Call during trial preparation to produce textures for each state
        function obj = prepareTextures(obj,selectedSet,rewardedResponse)
            
            %  Set textureAlphas based on training mode
            textureAlphas = ones(3,1);
            if(obj.trainingMode)
                textureAlphas(~strcmp(rewardedResponse,{'left','center','right'})) = obj.trainingAlpha;
            end
            
            %  Iterate over states specified in the configuration
            for i=1:length(obj.stateNames)
                
                %  Configuration specifies in which frames the comparators
                %  and probe appear
                if(any(strcmpi(obj.stateNames{i},[obj.instructStates obj.queryStates])))
                    indx = strcmpi(obj.stateNames{i},obj.stateNames);
                    Screen('Close',obj.textures(indx));
                    obj.textures(indx) = Screen('OpenOffScreenWindow',obj.windowPtr,obj.backgroundColor);
                    texturePtrs([1 2 3]) = obj.pedestalTexture;
                    if(any(strcmpi(obj.stateNames{i},obj.instructStates)))
                        texturePtrs(1) = obj.symbolTextures(selectedSet(1));
                        texturePtrs(3) = obj.symbolTextures(selectedSet(3));
                    end
                    if(any(strcmpi(obj.stateNames{i},obj.queryStates)))
                        texturePtrs(2) = obj.symbolTextures(selectedSet(2));
                    end
                    Screen('DrawTextures',obj.textures(indx),texturePtrs,[],obj.centeredRects,[],[],textureAlphas);
                end
            end
        end 
    end
end


