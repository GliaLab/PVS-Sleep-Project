clear all
%%
begonia.logging.set_level(1);
trials = eustoma.get_linescans_recrig();
trials = trials(trials.has_var('trial_type'));
trials = trials(trials.has_var('trial_id'));
trials = trials(trials.has_var('wakefulness_episodes'));

trial_type = trials.load_var('trial_type');
trial_type = string(trial_type);
trials = trials(trial_type == "Awake");

%%

for i = 1:length(trials)
    wakefulness_episodes = trials(i).load_var("wakefulness_episodes");
    
    trial_id = trials(i).load_var('trial_id');
    
    trial_path = trials(i).load_var('path');
    trial_path = string(trial_path);
    trial_path = eustoma.get_data_path + trial_path;
    
    camera_file = trial_path + "/camera.avi";
    camera_t_file = trial_path + "/camera_time.csv";
    
    % Calculate the time vector.
    camera_t = dlmread(camera_t_file, ',', 22, 1);
    camera_t = camera_t(:,1)'/1000;
    camera_t = camera_t - camera_t(1);
    
    % Decide which frames to show. 
    video_fps = 30;
    video_speed = 1;
    duration = camera_t(end) - camera_t(1);
    camera_dt_out = video_speed / video_fps;
    camera_t_out = 0:camera_dt_out:duration;
    camera_I = begonia.util.val2idx(camera_t, camera_t_out);
    
    % Make file.
    camera_file_out = eustoma.get_plot_path + "/Linescan camera/" + trial_id.trial_id + ".mp4"; 
    begonia.path.make_dirs(camera_file_out);
    
    % Start writing.
    v = VideoReader(camera_file);
    v_out = VideoWriter(camera_file_out, 'MPEG-4');
    v_out.FrameRate = video_fps;
    v_out.Quality = 20;
    v_out.open();
    
    % Loop through frames.
    tic
    for frame = 1:length(camera_I)
        % Print.
        if toc > 5 || frame == 1 || frame == length(camera_I)
            tic
            begonia.logging.log(1,"Reading frame %d/%d (%.f%%)", ...
                camera_I(frame), ...
                camera_I(end), ...
                camera_I(frame) / camera_I(end) * 100);
        end
        
        im = v.read(camera_I(frame));
        
        % Get the state the frame is in.
        ep_idx = wakefulness_episodes.state_start <= camera_t_out(frame) ...
            & wakefulness_episodes.state_end > camera_t_out(frame);
        text = wakefulness_episodes.state(ep_idx);
        if isempty(text)
            text = "Missing state";
        end
        
        im = insertText(im,[0,0],text,"FontSize",80);
        im = imresize(im,0.5);
        v_out.writeVideo(im);
    end
    
    v_out.close();
end


