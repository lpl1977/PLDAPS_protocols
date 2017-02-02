classdef performance < handle
    %performance class for tracking performance on task    
    
    properties(Hidden)
        F1
        F2
        correct
        total
        nCharF1
        nCharF1max
        nCharF2
        nCharF2max
    end
    
    methods
        %  Class constructor
        function obj = performance(conditions,factor1,factor2)
            F1 = cell(1,length(conditions));
            F2 = cell(1,length(conditions));
            for i=1:length(conditions)
                F1{i} = conditions{i}.(factor1);
                F2{i} = conditions{i}.(factor2);
            end
            
            obj.F1 = unique(F1);
            obj.nCharF1 = zeros(length(obj.F1),1);
            for i=1:length(obj.F1)
                obj.nCharF1(i) = length(obj.F1{i});
            end
            obj.nCharF1max = max(obj.nCharF1);
                        
            obj.F2 = unique(F2);
            obj.nCharF2 = zeros(length(obj.F2),1);
            for i=1:length(obj.F2)
                obj.nCharF2(i) = length(obj.F2{i});
            end
            obj.nCharF2max = max(obj.nCharF2);
            
            obj.correct = zeros(length(obj.F1),1);
            obj.total = zeros(length(obj.F1),length(obj.F2));            
        end
        
        function obj = update(obj,factor1,factor2,outcome)
            x = strcmpi(factor1,obj.F1);
            y = strcmpi(factor2,obj.F2);
            obj.total(x,y) = obj.total(x,y) + 1;
            obj.correct(x) = obj.correct(x) + outcome;
        end
        
        function show(obj)
            %  Show top row
            fprintf('%*s',obj.nCharF1max+5,'');
            for i=1:length(obj.F2)
                fprintf('%-*s',17,obj.F2{i});
            end
            fprintf('%-*s\n',17,'correct');
            
            %  Show response count rows
            subTotal = sum(obj.total,2);
            nDigits = size(int2str(subTotal),2);
            for i=1:length(obj.F1)
                fprintf('%*s%s: ',obj.nCharF1max-obj.nCharF1(i)+2,' ',obj.F1{i});
                for j=1:length(obj.F2)
                    fprintf(' (%*d/%*d) %.2f |',nDigits,obj.total(i,j),nDigits,subTotal(i),obj.total(i,j)/max(1,subTotal(i)));
                end
                fprintf(' (%*d/%*d) %.2f\n',nDigits,obj.correct(i),nDigits,subTotal(i),obj.correct(i)/max(1,subTotal(i)));
            end
        end
    end
end

