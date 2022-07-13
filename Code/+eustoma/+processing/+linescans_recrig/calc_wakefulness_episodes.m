clear all
%%
begonia.logging.set_level(1);
trials = eustoma.get_linescans_recrig();
trials = trials(trials.has_var('trial_type'));
trials = trials(trials.has_var('trial_id'));
trials = trials(trials.has_var('wheel'));
trials = trials(trials.has_var('camera_traces'));

% Only include trials where trial type is awake. 
trial_type = trials.load_var('trial_type');
trial_type = string(trial_type);
trials = trials(trial_type == "Awake");

%%
tic
for i = 1:length(trials)
    if i == 1 || i == length(trials) || toc > 5
        tic
        begonia.logging.log(1,"%d / %d",i,length(trials))
    end
    
    % Load wheel trace.
    wheel_tbl = trials(i).load_var("wheel");
    wheel = wheel_tbl.wheel_speed;
    wheel_fs = wheel_tbl.Properties.SampleRate;
    
    % Load camera / whisking trace.
    camera_traces = trials(i).load_var("camera_traces");
    camera_whisking = camera_traces.camera_absdiff{2};
    camera_t = camera_traces.camera_t{2};
    [camera_whisking, camera_t, camera_fs] = ...
        eustoma.processing.linescans_recrig.calc_wakefulness_filter_whisking( ...
        camera_whisking, camera_t);
    
    % Make a state vector with equal length as the wheel data.
    state_vec = begonia.util.catvec(height(wheel_tbl),1);
    state_vec(:) = "Quiet";
    
    % Score whisking
    whisking = camera_whisking >= 0.5;
%     % Remove short episodes.
%     minimum_whisking_duration = 2;
%     whisking = begonia.util.erode_logical(whisking, round(minimum_whisking_duration/2 * camera_fs));
%     whisking = begonia.util.dilate_logical(whisking, round(minimum_whisking_duration/2 * camera_fs));
%     % Bridge gaps
%     whisking = begonia.util.dilate_logical(whisking, round(2.5 * camera_fs));
%     whisking = begonia.util.erode_logical(whisking, round(2.5 * camera_fs));
    % Apply whisking to the state vector.
    % Find whisking episode indices.
    data = bwconncomp(whisking);
    st = cellfun(@(x) x(1), data.PixelIdxList)';
    en = cellfun(@(x) x(end), data.PixelIdxList)';
    % Convert camera indices to wheel indices.
    st = round((st - 1) / camera_fs * wheel_fs) + 1;
    en = round((en - 1) / camera_fs * wheel_fs) + 1;
    for ep_idx = 1:length(st)
        state_vec(st(ep_idx):en(ep_idx)) = "Whisking";
    end
    
%     % Filter wheel data.
%     win_sec = 2;
%     win = round(wheel_fs * win_sec);
%     filter_vec = zeros(win * 2 + 1, 1);
%     filter_vec(win+1:end) = 1;
%     filter_vec = filter_vec / sum(filter_vec);
%     wheel = conv(wheel, filter_vec, 'same');

    % Score locomotion
    locomotion = wheel > 1;
%     % Remove short episodes.
%     minimum_locomotion_duration = 2;
%     locomotion = begonia.util.erode_logical(locomotion, round(minimum_locomotion_duration/2 * wheel_fs));
%     locomotion = begonia.util.dilate_logical(locomotion, round(minimum_locomotion_duration/2 * wheel_fs));
    % Bridge gaps
    locomotion = begonia.util.dilate_logical(locomotion, round(2.5 * wheel_fs));
    locomotion = begonia.util.erode_logical(locomotion, round(2.5 * wheel_fs));
    state_vec(locomotion) = "Locomotion";

    % Make episodes of the state vector.
    wakefulness_episodes = table;
    for c = categories(state_vec)'
        c = string(c);
        
        data = bwconncomp(state_vec == c);
        st = cellfun(@(x) x(1), data.PixelIdxList)';
        en = cellfun(@(x) x(end), data.PixelIdxList)';

        state = repmat(c,length(st),1);
        state_start = (st - 1) / wheel_tbl.Properties.SampleRate;
        state_end = (en - 0) / wheel_tbl.Properties.SampleRate;
        state_duration = state_end - state_start;
        
        tbl = table(state,state_start,state_end,state_duration);
        wakefulness_episodes = cat(1,wakefulness_episodes,tbl);
    end
    
    [~,I] = sort(wakefulness_episodes.state_start);
    wakefulness_episodes = wakefulness_episodes(I,:);
    
    trials(i).save_var(wakefulness_episodes);
end


