begonia.logging.set_level(1);

rr = eustoma.get_endfoot_recrigs();
rr = rr(rr.has_var('trial_type'));
%%
for trial_idx = 1:length(rr)
    begonia.logging.log(1,'Calculate episodes (%d/%d)',trial_idx,length(rr));
    tr = rr(trial_idx);
    %% Load camera traces
    cam = tr.load_var('camera_traces');

    %% Define wakefulness episodes: old, sleep project way
    trial_type = tr.load_var('trial_type');
    if strcmp(trial_type,'Wake')
        duration = tr.load_var('duration');

        % Manual Sleep scoring
        states_fs = 30;
        states_dt = 1./states_fs;
        states_N = floor(states_fs * duration);

        sleep_stages = repmat({'pre_sleep'},1,states_N);
        sleep_stages = categorical(sleep_stages);

        sp = dogbane.StateProcessor();
        sp.preset = 'sleep_and_activity';
        sp.fs = states_fs;

        [states_trace,states_fs] = sp.process( ...
            duration, ...
            sleep_stages, ...
            states_dt, ...
            cam.wheel, ...
            cam.whisker, ...
            seconds(cam.Properties.TimeStep));

        %% Define episodes.
        state_cats = categories(states_trace);
        row = 1;

        state = categorical(cell(0));
        state_start = [];
        state_end = [];

        for idx_state = 1:length(state_cats)
            cur_state = state_cats{idx_state};
            [u,d] = begonia.util.consecutive_stages(states_trace == cur_state);

            for idx_episode = 1:length(u)
                dur = d(idx_episode) - u(idx_episode) + 1;
                dur = dur/states_fs;

                t_start = u(idx_episode) - 1;
                t_start = t_start/states_fs;

                t_end = d(idx_episode);
                t_end = t_end/states_fs;

                state(row,1) = cur_state;
                state_start(row,1) = t_start;
                state_end(row,1) = t_end;

                row = row + 1;
            end
        end

        episodes = table(state,state_start,state_end);
        episodes(state == 'undefined',:) = [];
        episodes.state = setcats(episodes.state,{'locomotion','whisking','quiet'});
        episodes.state = renamecats(episodes.state, ...
            {'locomotion','whisking','quiet'}, ...
            {'Locomotion','Whisking','Quiet'});
    else
        episodes = tr.load_var('sleep_episodes',[]);
        if isempty(episodes)
            continue;
        end
    end
    
    %% Include trial data
    N = height(episodes);
    mouse = rr(trial_idx).load_var('mouse');
    mouse = repmat({mouse},N,1);
    mouse = categorical(mouse);
    experiment = rr(trial_idx).load_var('experiment');
    experiment = repmat({experiment},N,1);
    experiment = categorical(experiment);
    trial = rr(trial_idx).load_var('trial');
    trial = repmat({trial},N,1);
    trial = categorical(trial);
    trial_type = tr.load_var('trial_type');
    trial_type = repmat({trial_type},N,1);
    trial_type = categorical(trial_type);
    % Create an ID of every episode. 
    episode_id = cell(N,1);
    for i = 1:N
        episode_id{i} = sprintf('%s #%d',trial(1),i);
    end
    episode_id = categorical(episode_id);
    
    % Make a new table and catenate so the trial info are in the first
    % columns.
    episodes = cat(2,table(mouse,experiment,trial,trial_type,episode_id),episodes);
    %% Define state duration
    episodes.state_duration = episodes.state_end - episodes.state_start;

    % Sort
    episodes = sortrows(episodes,'state_start');
    
    %% Calculate the average whisking and wheel value per episode.
    for i = 1:height(episodes)
        st = round(episodes.state_start(i) * cam.Properties.SampleRate) + 1;
        en = round(episodes.state_end(i) * cam.Properties.SampleRate);
        if en > height(cam)
            en = height(cam);
        end
        episodes.avg_whisk(i) = mean(cam.whisker(st:en));
        episodes.avg_wheel(i) = mean(cam.wheel(st:en));
    end

    if ~isempty(episodes)
        tr.save_var(episodes);
    end
end