classdef indexing < handle
    %INDEXING Class for keeping track of trial indexing
    %   Trial indexing management for only_zuul
    
    properties
        current_trial = 1;
        num_trials;        
        trial_list
        block_index
    end
    
    methods
        %  Class constructor
        function obj = indexing(block_index)
            
            obj.num_trials = length(block_index);
            
            obj.block_index = block_index;
            obj.trial_list = 1:obj.num_trials;
            
            %  Shuffle trial list within blocks
            ublocks = unique(block_index);
            for i=1:length(ublocks)
                indx = block_index==ublocks(i);
                obj.trial_list(indx) = Shuffle(obj.trial_list(indx));
            end
        end
        
        function num = trial_number(obj)
            num = obj.trial_list(obj.current_trial);
        end
        
        function increment(obj)
            obj.current_trial = obj.current_trial + 1;
        end
        
        function ix = current_block(obj)
            ix = obj.block_index(obj.current_trial);
        end
        
        %  Shuffle the order of remaining trials in the current block
        function [first_trial,last_trial] = shuffle(obj)
            %  Find the trials in the block and shuffle them
            indx = obj.block_index==obj.current_block;
            indx(1:obj.current_trial-1) = false;
            obj.trial_list(indx) = Shuffle(obj.trial_list(indx));
            
            %  Return the first and last trial
            first_trial = find(indx,1,'first');
            last_trial = find(indx,1,'last');
        end
        
        function flag = conditions_complete(obj)
            flag = obj.current_trial == obj.num_trials;
        end
        
    end
    
end

