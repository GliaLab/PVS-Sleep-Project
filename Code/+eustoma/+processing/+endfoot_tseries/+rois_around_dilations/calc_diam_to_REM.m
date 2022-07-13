begonia.logging.set_level(1);

ts = eustoma.get_endfoot_tseries();
ts = ts(ts.has_var('diameter'));

trials = eustoma.get_endfoot_recrigs();

dloc_list = yucca.datanode.DataNodeList();
dloc_list.add(trials);
dloc_list.add(ts);

%%
sec_before_episode = 30;
sec_after_episode = 30;

for i = 1:length(ts)
    begonia.logging.log(1,"TSeries (%d/%d)",i,length(ts));
    
    diameter = ts(i).load_var('diameter');
    
    % Load sleep episodes.
    sleep_episodes = ts(i).find_dnode('recrig').load_var('sleep_episodes',[]);
    if isempty(sleep_episodes)
        continue;
    end
    % Only include REM.
    sleep_episodes = sleep_episodes(sleep_episodes.state == "REM",:);
    if isempty(sleep_episodes)
        continue;
    end
    
    % Clean up table.
    diameter.vessel_position = [];
    diameter.vessel_dx = [];
    diameter.vessel_upper = [];
    diameter.vessel_lower = [];
    
    % Calculate the number of samples in the transition.
    fs = diameter.vessel_fs(1);
        
    n = round((sec_before_episode + sec_after_episode) * fs) + 1;
    
    % Length of the diameter traces.
    N = length(diameter.diameter{1});
    
    % Make a table for each vessel and REM episode.
    diam_to_REM = yucca.util.crossjoin(sleep_episodes,diameter);
    
    %% Transition to start of REM.
    % Calculate the start and end indices for the transition to START of
    % REM.
    diam_to_REM.st = round((diam_to_REM.state_start - sec_before_episode) * fs) + 1;
    diam_to_REM.en = diam_to_REM.st + n - 1;
    diam_to_REM(diam_to_REM.st < 1,:) = [];
    diam_to_REM(diam_to_REM.en > N,:) = [];
    
    % Calculate the transition to START of REM.
    diam_to_REM.diam_to_start = zeros(height(diam_to_REM),n);
    for j = 1:height(diam_to_REM)
        diam_to_REM.diam_to_start(j,:) = diam_to_REM.diameter{j}(diam_to_REM.st(j):diam_to_REM.en(j));
    end
    
    % Calculate dilation difference around the transition. 
    transition_idx = round(sec_before_episode * fs) + 1;
    diam_to_REM.diam_to_start = diam_to_REM.diam_to_start - diam_to_REM.diam_to_start(:,transition_idx);
    
    %% Transition to end of REM.
    % Calculate the start and end indices for the transition to END of
    % REM.
    diam_to_REM.st = round((diam_to_REM.state_end - sec_before_episode) * fs) + 1;
    diam_to_REM.en = diam_to_REM.st + n - 1;
    diam_to_REM(diam_to_REM.st < 1,:) = [];
    diam_to_REM(diam_to_REM.en > N,:) = [];
    
    % Calculate the transition to END of REM.
    diam_to_REM.diam_to_end = zeros(height(diam_to_REM),n);
    for j = 1:height(diam_to_REM)
        diam_to_REM.diam_to_end(j,:) = diam_to_REM.diameter{j}(diam_to_REM.st(j):diam_to_REM.en(j));
    end
    
    % Calculate dilation difference around the transition. 
    transition_idx = round(sec_before_episode * fs) + 1;
    diam_to_REM.diam_to_end = diam_to_REM.diam_to_end - diam_to_REM.diam_to_end(:,transition_idx);
    %% Clean up the table
    diam_to_REM.st = [];
    diam_to_REM.en = [];
    diam_to_REM.diameter = [];
    %% Make a struct with metadata
    diam_to_REM_struct = struct;
    diam_to_REM_struct.fs = fs;
    diam_to_REM_struct.sec_before_episode = sec_before_episode;
    diam_to_REM_struct.sec_after_episode = sec_after_episode;
    diam_to_REM_struct.t = (0:n-1) / diam_to_REM_struct.fs - sec_before_episode;
    %% The table mighht be empty because the episodes are to close to the edges.
    if isempty(diam_to_REM)
        continue;
    end
    %%
    ts(i).save_var(diam_to_REM);
    ts(i).save_var(diam_to_REM_struct);
end

