function whisker_wheel_transitions(trial)
tr = trial.rec_rig_trial;
%%
tr.clear_var('whisker_wheel_transitions');

if ~tr.has_var('state_episodes')
    return;
end

if ~tr.has_var('camera_wheel')
    return;
end

%%

tbl_episodes = tr.load_var('state_episodes');
tbl_episodes(tbl_episodes.State == 'undefined',:) = [];

camera_wheel = tr.load_var('camera_wheel');
camera_whisker = tr.load_var('camera_whisker');
camera_fs = tr.load_var('camera_fs');

camera_wheel = reshape(camera_wheel,[],1);
camera_whisker = reshape(camera_whisker,[],1);
camera_t = (0:length(camera_wheel)-1)/camera_fs;

% resample to 30 Hz
fs = 30;
camera_wheel = resample(camera_wheel,camera_t,fs);
camera_whisker = resample(camera_whisker,camera_t,fs);

state = tbl_episodes.State;
state_duration = tbl_episodes.StateDuration;
state_start = tbl_episodes.StateStart;
state_end = tbl_episodes.StateEnd;
 
t = (-30*fs:30*fs)/fs;

wheel = begonia.processing.extract_transitions( ...
    t,camera_wheel, ...
    tbl_episodes.StateStart)';
wheel_strict = begonia.processing.extract_transitions_strict( ...
    t,camera_wheel, ...
    tbl_episodes.StateStart, ...
    tbl_episodes.StateStart+t(1), ...
    tbl_episodes.StateEnd)';
whisking = begonia.processing.extract_transitions( ...
    t,camera_whisker, ...
    tbl_episodes.StateStart)';
whisking_strict = begonia.processing.extract_transitions_strict( ...
    t,camera_whisker, ...
    tbl_episodes.StateStart, ...
    tbl_episodes.StateStart+t(1), ...
    tbl_episodes.StateEnd)';

whisker_wheel_transitions = table(state,state_duration,state_start,state_end, ...
    wheel, ...
    wheel_strict, ...
    whisking, ...
    whisking_strict);

tr.save_var(whisker_wheel_transitions)
end

