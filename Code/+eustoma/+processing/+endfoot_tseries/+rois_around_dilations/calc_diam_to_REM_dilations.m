begonia.logging.set_level(1);

ts = eustoma.get_endfoot_tseries();
ts = ts(ts.has_var('rem_dilation_eps'));
ts = ts(ts.has_var('diameter'));

%%
sec_before_episode = 30;
sec_after_episode = 30;
alignment_offset = -20;

for i = 1:length(ts)
    begonia.logging.log(1,"TSeries (%d/%d)",i,length(ts));
    
    diameter = ts(i).load_var('diameter');
    
    % Clean up table.
    diameter.vessel_position = [];
    diameter.vessel_dx = [];
    diameter.vessel_upper = [];
    diameter.vessel_lower = [];
    
    % Load sleep episodes.
    rem_dilation_eps = ts(i).load_var('rem_dilation_eps');
    
    % Expand the table by joining on the vessel_id.
    diam_to_REM_dilation = innerjoin(diameter, rem_dilation_eps);
    
    % Calculate the number of samples in the transition.
    fs = diameter.vessel_fs(1);
    n = round((sec_before_episode + sec_after_episode) * fs) + 1;
    
    % Length of the diameter traces.
    N = length(diameter.diameter{1});
    
    %% Transition to start of REM.
    % Calculate the start and end indices for the transition to START of
    % REM.
    diam_to_REM_dilation.st = round((diam_to_REM_dilation.ep_start - sec_before_episode) * fs) + 1;
    diam_to_REM_dilation.en = diam_to_REM_dilation.st + n - 1;
    
    % Calculate the transition to START of REM.
    diam_to_REM_dilation.diam_to_start = nan(height(diam_to_REM_dilation),n);
    for j = 1:height(diam_to_REM_dilation)
        % Check if the window around the dilation is inside the trace.
        if diam_to_REM_dilation.st(j) < 1 || diam_to_REM_dilation.en(j) > N
            continue
        end
        diam_to_REM_dilation.diam_to_start(j,:) = diam_to_REM_dilation.diameter{j}(diam_to_REM_dilation.st(j):diam_to_REM_dilation.en(j));
    end
    
    % Calculate dilation difference around the transition. 
    transition_idx = round((sec_before_episode + alignment_offset) * fs) + 1;
    diam_to_REM_dilation.diam_to_start = diam_to_REM_dilation.diam_to_start - diam_to_REM_dilation.diam_to_start(:,transition_idx);
    %% Transition to end of REM.
    % Calculate the start and end indices for the transition to END of
    % REM.
    diam_to_REM_dilation.st = round((diam_to_REM_dilation.ep_end - sec_before_episode) * fs) + 1;
    diam_to_REM_dilation.en = diam_to_REM_dilation.st + n - 1;
    
    % Calculate the transition to END of REM.
    diam_to_REM_dilation.diam_to_end = nan(height(diam_to_REM_dilation),n);
    for j = 1:height(diam_to_REM_dilation)
        if diam_to_REM_dilation.st(j) < 1 || diam_to_REM_dilation.en(j) > N
            continue
        end
        diam_to_REM_dilation.diam_to_end(j,:) = diam_to_REM_dilation.diameter{j}(diam_to_REM_dilation.st(j):diam_to_REM_dilation.en(j));
    end
    
    % Calculate dilation difference around the transition. 
    transition_idx = round((sec_before_episode + alignment_offset) * fs) + 1;
    diam_to_REM_dilation.diam_to_end = diam_to_REM_dilation.diam_to_end - diam_to_REM_dilation.diam_to_end(:,transition_idx);
    %% Clean up the table
    diam_to_REM_dilation.st = [];
    diam_to_REM_dilation.en = [];
    diam_to_REM_dilation.diameter = [];
    %% Make a struct with metadata
    diam_to_REM_dilation_struct = struct;
    diam_to_REM_dilation_struct.fs = fs;
    diam_to_REM_dilation_struct.sec_before_episode = sec_before_episode;
    diam_to_REM_dilation_struct.sec_after_episode = sec_after_episode;
    diam_to_REM_dilation_struct.t = (0:n-1) / diam_to_REM_dilation_struct.fs - sec_before_episode;
    %%
    ts(i).save_var(diam_to_REM_dilation);
    ts(i).save_var(diam_to_REM_dilation_struct);
end

