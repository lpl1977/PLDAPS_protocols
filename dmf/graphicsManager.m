classdef graphicsManager < handle
    %graphicsManager Generate and display graphics for dmf
    %   Produce symbol textures and frames for trials of the dmf task
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
        
        nLines
        borderWidth
        
        rect
        
        colorLibrary
        backgroundColor = [0.5 0.5 0.5];
        
        windowPtr
        
        centeredRects
        
        stateTextures
        
        stateConfig
        stateNames
        
        fixationDotColor
        fixationDotWidth
        fixationDotVisible = false;
        
        coloredPixelNoiseTextures
    end
    
    methods
        
        %  Class constructor
        %
        %
        function obj = graphicsManager(varargin)
            
            %  Set properties
            for i=1:2:nargin-1
                if(isprop(obj,varargin{i}))
                    obj.(varargin{i}) = varargin{i+1};
                else
                    error('%s is not a valid property of %s',varargin{i},mfilename('class'));
                end
            end
            
            %  Create initial state configuration
            obj.stateConfig = cell2struct(obj.stateConfig(2:2:end),obj.stateConfig(1:2:end),2);
            
            %  Frequently used quantities
            obj.rect = [0 0 2*obj.symbolRadius 2*obj.symbolRadius];
            obj.centeredRects = CenterRectOnPoint(obj.rect,obj.symbolCenters(:,1),obj.symbolCenters(:,2))';
            
        end
        
        %  prepareSymbolTextures
        function prepareSymbolTextures(obj)
            
            %  Prepare frequently used variables
            textureWidth = 2*obj.symbolRadius;
            
            %  Generate symbol textures
            nSymbols = size(obj.symbolCodes,1);
            obj.symbolTextures = zeros(nSymbols,1);
            for i=1:nSymbols
                
                %  Create a texture into which we will write the symbol
                obj.symbolTextures(i) = Screen('OpenOffScreenWindow',obj.windowPtr,obj.backgroundColor,obj.rect);
                
                %  Extract symbol features
                symbolColor = obj.colorLibrary.(obj.symbolFeatures.colors{obj.symbolCodes(i,1)});
                symbolPattern = obj.symbolFeatures.patterns{obj.symbolCodes(i,2)};
                symbolShape = obj.symbolFeatures.shapes{obj.symbolCodes(i,3)};
                
                %  Write the shape into the symbol texture with the
                %  specified color
                if(strcmpi(symbolShape,'circle'))
                    Screen('FillOval',obj.symbolTextures(i),symbolColor,obj.rect);
                else
                    switch symbolShape
                        case 'square'
                            nVertices = 4;
                            rotationAngle = pi/4;
                        case 'diamond'
                            nVertices = 4;
                            rotationAngle = pi/2;
                        case 'triangle'
                            nVertices = 3;
                            rotationAngle = pi/2;
                        case 'pentagon'
                            nVertices = 5;
                            rotationAngle = pi/2;
                        case 'hexagon'
                            nVertices = 6;
                            rotationAngle = pi/2;
                    end
                    vertexAngles = (pi/2) + linspace(0,2*pi,nVertices+1)+rotationAngle;
                    vertices = [sin(vertexAngles) ; cos(vertexAngles)]';
                    Screen('FillPoly',obj.symbolTextures(i),symbolColor,obj.symbolRadius*vertices + repmat([obj.symbolRadius obj.symbolRadius],size(vertices,1),1));
                end
                
                %  Write pattern over the shape
                %  Note that if pattern is solid then nothing to do.  If
                %  hollow then no need for alpha blending.
                if(strcmpi(symbolPattern,'hollow'))
                    if(strcmpi(symbolShape,'circle'))
                        innerRadius = obj.symbolRadius * (1 - 1/obj.nLines);
                        patternRect = [2*(obj.symbolRadius - innerRadius) 2*(obj.symbolRadius - innerRadius) 2*innerRadius 2*innerRadius];
                        Screen('FillOval',obj.symbolTextures(i),obj.backgroundColor,patternRect);
                    else
                        innerRadius = obj.symbolRadius * (1 - 1/(cos(pi/nVertices)*obj.nLines));
                        Screen('FillPoly',obj.symbolTextures(i),obj.backgroundColor,innerRadius*vertices + repmat([obj.symbolRadius obj.symbolRadius],size(vertices,1),1));
                    end
                elseif(~strcmpi(symbolPattern,'solid'))
                    [x,y] = meshgrid(linspace(-1,1,textureWidth),linspace(-1,1,textureWidth));
                    [~,r] = cart2pol(x,y);
                    mask = ones(textureWidth,textureWidth,2);
                    
                    switch symbolPattern
                        case 'horizontalLines'
                            mask(:,:,2) = 0.5*(1-cos(pi*obj.nLines*y)).*(r<1);
                        case 'verticalLines'
                            mask(:,:,2) = 0.5*(1-cos(pi*obj.nLines*x)).*(r<1);
                    end
                    mask(mask>0.5) = 1;
                    mask(mask<0.5) = 0;
                    mask = 255*max(min(mask,1),0);
                    maskTexture = Screen('MakeTexture',obj.windowPtr,mask);
                    Screen('Blendfunction',obj.symbolTextures(i),'GL_SRC_ALPHA','GL_ONE_MINUS_SRC_ALPHA',[1 1 1 0]);
                    Screen('DrawTexture',obj.symbolTextures(i),maskTexture,[],[],[],[],[],obj.backgroundColor);
                    Screen('Close',maskTexture);
                end
                
                %  Add an outline to the symbol
                if(strcmpi(symbolShape,'circle'))
                    Screen('FrameOval',obj.symbolTextures(i),symbolColor,obj.rect,obj.borderWidth);
                else
                    Screen('FramePoly',obj.symbolTextures(i),symbolColor,obj.symbolRadius*vertices + repmat([obj.symbolRadius obj.symbolRadius],size(vertices,1),1),obj.borderWidth);
                end
            end
        end
        
        %  prepareColoredPixelNoiseTextures
        %
        %  Random color field (drawn from colorLibrary) with radius equal
        %  to the apothem of a triangle
        function prepareColoredPixelNoiseTextures(obj)
            colorNames = fieldnames(obj.colorLibrary);
            nColors = length(colorNames);
            colorLib = zeros(nColors,3);
            for i=1:nColors
                colorLib(i,:) = obj.colorLibrary.(colorNames{i});
            end
            textureWidth = 2*obj.symbolRadius;
            [x,y] = meshgrid(linspace(-1,1,textureWidth),linspace(-1,1,textureWidth));
            [~,r] = cart2pol(x,y);
            obj.coloredPixelNoiseTextures = zeros(3,1);
            apothem = cos(pi/3);
            for i=1:3
                coloredPixelNoise = colorLib(unidrnd(nColors,numel(r),1),:);
                coloredPixelNoise(r(:)>apothem,:) = repmat(obj.backgroundColor,sum(r(:)>apothem),1);
                coloredPixelNoise = 255*reshape(coloredPixelNoise,textureWidth,textureWidth,3);
                obj.coloredPixelNoiseTextures(i) = Screen('MakeTexture',obj.windowPtr,coloredPixelNoise);
            end
        end
        
        %  prepareStateTextures
        %
        %  Call during trial preparation to produce textures for each state
        function prepareStateTextures(obj,selectedSet)
            
            %  Make sure to include the names of any states for which we
            %  might have added the configurations after creating the
            %  object.
            obj.stateNames = fieldnames(obj.stateConfig);
            if(~isempty(obj.stateTextures))
                Screen('Close',obj.stateTextures);
            end
            obj.stateTextures = zeros(length(obj.stateNames),1);
            
            %  Make some backwards mask textures
            obj.prepareColoredPixelNoiseTextures;
            
            %  Iterate over states specified in the configuration
            for i=1:length(obj.stateNames)
                
                stateName = cell2mat(regexp(obj.stateNames{i},'[a-z,A-Z]+','match'));
                obj.stateTextures(i) = Screen('OpenOffScreenWindow',obj.windowPtr,obj.backgroundColor);
                switch stateName
                    case 'symbols'
                        textureAlphas = obj.stateConfig.(obj.stateNames{i});
                        Screen('DrawTextures',obj.stateTextures(i),obj.symbolTextures(selectedSet),[],obj.centeredRects,[],[],textureAlphas);
                    case 'response'
                        textureAlphas = [1 1 1];
                        Screen('DrawTextures',obj.stateTextures(i),obj.coloredPixelNoiseTextures,[],obj.centeredRects,[],[],textureAlphas);
                end
                
                %                 %  Configuration specifies in which frames the comparators
                %                 %  and probe appear.  Set textureAlphas based on
                %                 %  configuration and training mode
                %                 textureAlphas = obj.stateConfig.(obj.stateNames{i});
                %                 if(obj.trainingMode)
                %                     ix = ~strcmp(rewardedResponse,{'left','center','right'});
                %                     textureAlphas(ix) = obj.trainingAlpha.*textureAlphas(ix);
                %                 end
                %                 obj.stateTextures(i) = Screen('OpenOffScreenWindow',obj.windowPtr,obj.backgroundColor);
                %                 Screen('DrawTextures',obj.stateTextures(i),obj.symbolTextures(selectedSet),[],obj.centeredRects,[],[],textureAlphas);
                %                 if(strcmpi(obj.stateNames{i},'response') && any(textureAlphas==0))
                %                     ix = textureAlphas==0;
                %                     Screen('DrawTextures',obj.stateTextures(i),obj.coloredPixelNoiseTextures(ix),[],obj.centeredRects(:,ix));
                %                 end
            end
        end
        
        %  drawStateTexture
        %
        %  Retrieve the texture associated with the specified state and
        %  draw it into the specified window.  If there is not an
        %  associated state texture, do nothing (this will produce a blank
        %  screen).
        function drawStateTexture(obj,windowPtr,state)
            indx = strcmpi(state,obj.stateNames);
            if(any(indx))
                Screen('DrawTexture',windowPtr,obj.stateTextures(indx));
            end
        end
        
        %  drawFixationDot
        function drawFixationDot(obj,windowPtr,pos)
            if(obj.fixationDotVisible)
                Screen('DrawDots',windowPtr,...
                    [pos(1); pos(2)],...
                    obj.fixationDotWidth,obj.fixationDotColor,[],2);
            end
        end
        
        %  drawSelectionIndicator
        function drawSelectionIndicator(obj,windowPtr,response)
            s = sqrt(2)*obj.symbolRadius;
            switch response
                case 'left'
                    selectionRect = CenterRectOnPointd([0 0 s s],obj.symbolCenters(1,1),obj.symbolCenters(1,2));
                case 'right'
                    selectionRect = CenterRectOnPointd([0 0 s s],obj.symbolCenters(3,1),obj.symbolCenters(3,2));
                otherwise
                    selectionRect = CenterRectOnPointd([0 0 s s],obj.symbolCenters(2,1),obj.symbolCenters(2,2));
            end
            Screen('FrameRect',windowPtr,[0 0 0],selectionRect,4);
        end
    end
end
