function corrs = correlate_stacks( trials, stacks, corrfunc, augment )
%CORRFUNC_BY_OFFSET Summary of this function goes here
%   Detailed explanation goes here

    % find correclates:
    corrs = [];
    for i = 1:length(trials)
        for j = 1:length(stacks)
            if corrfunc(trials(i), stacks(j))
                c = struct();
                c.trial = trials(i);
                c.stack = stacks(j);
                corrs = [corrs c];
                
            end
        end
    end
    
    % augment if asked:
    if augment
        
        % add/reset associated prop on trials and stacks:
        for i = 1:length(trials)
            if ~isprop(trials(i), 'associated_stacks')
                addprop(trials(i), 'associated_stacks');
            end
            trials(i).associated_stacks = [];
        end
        
        for i = 1:length(stacks)
            if ~isprop(stacks(i), 'associated_trials')
                addprop(stacks(i), 'associated_trials');
            end
            stacks(i).associated_trials = [];
        end
        
        % assign correlation:
        for i = 1:length(corrs)
            c = corrs(i);
            
            c.trial.associated_stacks = [c.trial.associated_stacks c.stack];
            c.stack.associated_trials = [c.stack.associated_trials c.trial];  
        end
    end
    

end

