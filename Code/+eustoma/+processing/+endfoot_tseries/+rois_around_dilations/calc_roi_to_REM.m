begonia.logging.set_level(1);

ts = eustoma.get_endfoot_tseries();
ts = ts(ts.has_var('roi_signals'));

trials = eustoma.get_endfoot_recrigs();

dloc_list = yucca.datanode.DataNodeList();
dloc_list.add(trials);
dloc_list.add(ts);
%%
sec_before_episode = 30;
sec_after_episode = 30;

for i = 1:length(ts)
    begonia.logging.log(1,"TSeries (%d/%d)",i,length(ts));
    
    roi_signals = ts(i).load_var('roi_signals');
    
    sleep_episodes = ts(i).find_dnode('recrig').load_var('sleep_episodes',[]);
    if isempty(sleep_episodes)
        continue;
    end
    % Only include REM.
    sleep_episodes = sleep_episodes(sleep_episodes.state == "REM",:);
    if isempty(sleep_episodes)
        continue;
    end
    
    % Merge the ROI signals into one trace.
    roi_trace = cat(1, roi_signals.signal{:});
    roi_trace = mean(roi_trace, 1);
    
    % Make a new table that will hold signals.
    roi_to_rem = sleep_episodes;
    
    % Calculate the number of samples in the transition.
    n = round((sec_before_episode + sec_after_episode) * roi_signals.fs(1)) + 1;
    
    % Calculate start and end indices of the start of the REM episodes..
    roi_to_rem.st_to_start = round((roi_to_rem.state_start - sec_before_episode) .* roi_signals.fs(1)) + 1;
    roi_to_rem.en_to_start = roi_to_rem.st_to_start + n - 1;
    roi_to_rem(roi_to_rem.st_to_start < 1,:) = [];
    roi_to_rem(roi_to_rem.en_to_start > length(roi_trace),:) = [];
    % Calculate the signal to start of REM.
    roi_to_rem.signal_to_start = zeros(height(roi_to_rem),n);
    for j = 1:height(roi_to_rem)
        roi_to_rem.signal_to_start(j,:) = roi_trace(roi_to_rem.st_to_start(j):roi_to_rem.en_to_start(j));
    end
    % Calculate df/f0 around the transition. 
    transition_idx = round(sec_before_episode * roi_signals.fs(1)) + 1;
    roi_to_rem.signal_to_start = roi_to_rem.signal_to_start ./ roi_to_rem.signal_to_start(:,transition_idx) - 1;
    % Clean up table
    roi_to_rem.st_to_start = [];
    roi_to_rem.en_to_start = [];
    
    % Calculate start and end indices of the end of the REM episodes..
    roi_to_rem.st_to_end = round((roi_to_rem.state_end - sec_before_episode) .* roi_signals.fs(1)) + 1;
    roi_to_rem.en_to_end = roi_to_rem.st_to_end + n - 1;
    roi_to_rem(roi_to_rem.st_to_end < 1,:) = [];
    roi_to_rem(roi_to_rem.en_to_end > length(roi_trace),:) = [];
    % Calculate the signal to end of REM.
    roi_to_rem.signal_to_end = zeros(height(roi_to_rem),n);
    for j = 1:height(roi_to_rem)
        roi_to_rem.signal_to_end(j,:) = roi_trace(roi_to_rem.st_to_end(j):roi_to_rem.en_to_end(j));
    end
    % Calculate df/f0 around the transition. 
    transition_idx = round(sec_before_episode * roi_signals.fs(1)) + 1;
    roi_to_rem.signal_to_end = roi_to_rem.signal_to_end ./ roi_to_rem.signal_to_end(:,transition_idx) - 1;
    % Clean up table
    roi_to_rem.st_to_end = [];
    roi_to_rem.en_to_end = [];
    
    roi_to_rem.fs(:) = roi_signals.fs(1);
    
    roi_to_rem_struct = struct;
    roi_to_rem_struct.fs = roi_signals.fs(1);
    roi_to_rem_struct.sec_before_episode = sec_before_episode;
    roi_to_rem_struct.sec_after_episode = sec_after_episode;
    
    %% The table mighht be empty because the episodes are to close to the edges.
    if isempty(roi_to_rem)
        continue;
    end
    
    %%
    ts(i).save_var(roi_to_rem);
    ts(i).save_var(roi_to_rem_struct);
    
end

