begonia.logging.set_level(1);

ts = eustoma.get_endfoot_tseries();
ts = ts(ts.has_var('rem_dilation_eps'));
ts = ts(ts.has_var('roi_signals'));

%%
sec_before_episode = 30;
sec_after_episode = 30;
alignment_offset = -20;

for i = 1:length(ts)
    begonia.logging.log(1,"TSeries (%d/%d)",i,length(ts));
    
    roi_signals = ts(i).load_var('roi_signals');
    rem_dilation_eps = ts(i).load_var('rem_dilation_eps');
    
    % Calculate average ROI trace.
    roi_signal = cat(1, roi_signals.signal{:});
    roi_signal = mean(roi_signal,1);
    
    % Calculate the number of samples in the transition.
    fs = roi_signals.fs(1);
    n = round((sec_before_episode + sec_after_episode) * fs) + 1;
    
    % Length of the recording.
    N = length(roi_signal);
    
    % Make a table to contain the signals aligned to the dilation.
    roi_to_REM_dilation = rem_dilation_eps;
    
    %% Transition to start of REM.
    % Calculate the start and end indices for the transition to START of
    % REM.
    roi_to_REM_dilation.st = round((roi_to_REM_dilation.ep_start - sec_before_episode) * fs) + 1;
    roi_to_REM_dilation.en = roi_to_REM_dilation.st + n - 1;
    
    % Calculate the transition to START of REM.
    roi_to_REM_dilation.roi_to_start = nan(height(roi_to_REM_dilation),n);
    for j = 1:height(roi_to_REM_dilation)
        % Check if the window around the dilation is inside the trace.
        if roi_to_REM_dilation.st(j) < 1 || roi_to_REM_dilation.en(j) > N
            continue
        end
        roi_to_REM_dilation.roi_to_start(j,:) = roi_signal(roi_to_REM_dilation.st(j):roi_to_REM_dilation.en(j));
    end
    
    % Calculate ratio around the transition.
    transition_idx = round((sec_before_episode + alignment_offset) * fs) + 1;
    roi_to_REM_dilation.roi_to_start = roi_to_REM_dilation.roi_to_start ./ roi_to_REM_dilation.roi_to_start(:,transition_idx) - 1;
    
    %% Transition to end of REM.
    % Calculate the start and end indices for the transition to END of
    % REM.
    roi_to_REM_dilation.st = round((roi_to_REM_dilation.ep_end - sec_before_episode) * fs) + 1;
    roi_to_REM_dilation.en = roi_to_REM_dilation.st + n - 1;
    
    % Calculate the transition to END of REM.
    roi_to_REM_dilation.roi_to_end = nan(height(roi_to_REM_dilation),n);
    for j = 1:height(roi_to_REM_dilation)
        if roi_to_REM_dilation.st(j) < 1 || roi_to_REM_dilation.en(j) > N
            continue
        end
        roi_to_REM_dilation.roi_to_end(j,:) = roi_signal(roi_to_REM_dilation.st(j):roi_to_REM_dilation.en(j));
    end
    
    % Calculate ratio around the transition. 
    transition_idx = round((sec_before_episode + alignment_offset) * fs) + 1;
    roi_to_REM_dilation.roi_to_end = roi_to_REM_dilation.roi_to_end ./ roi_to_REM_dilation.roi_to_end(:,transition_idx) - 1;
    %% Clean up the table
    roi_to_REM_dilation.st = [];
    roi_to_REM_dilation.en = [];
    
    %% Make a struct with metadata
    roi_to_REM_dilation_struct = struct;
    roi_to_REM_dilation_struct.fs = fs;
    roi_to_REM_dilation_struct.sec_before_episode = sec_before_episode;
    roi_to_REM_dilation_struct.sec_after_episode = sec_after_episode;
    roi_to_REM_dilation_struct.t = (0:n-1) / roi_to_REM_dilation_struct.fs - sec_before_episode;
    %%
    ts(i).save_var(roi_to_REM_dilation);
    ts(i).save_var(roi_to_REM_dilation_struct);
    
end

