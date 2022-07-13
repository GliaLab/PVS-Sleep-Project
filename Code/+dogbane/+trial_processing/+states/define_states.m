function define_states(trial)
%%
duration = seconds(trial.duration);

%% Camera
camera_regions = trial.load_var('camera_regions');

camera_dt = camera_regions.whisker.TimeInfo.Increment;
camera_fs = 1/camera_dt;

camera_whisker = camera_regions.whisker.Data;
camera_wheel = camera_regions.wheel.Data;

camera_wheel = round(camera_wheel,3);
camera_whisker = round(camera_whisker,3);

% Ignore samples that are too high to be the baseline.
trace_wheel_sub = camera_wheel(camera_wheel < 5);
trace_whisker_sub = camera_whisker(camera_whisker < 5);

baseline_wheel = mode(trace_wheel_sub);
baseline_whisker = mode(trace_whisker_sub);

if isnan(baseline_wheel) || isnan(baseline_whisker)
    error('Could not define baseline.')
end

camera_wheel = camera_wheel - baseline_wheel;
camera_whisker = camera_whisker - baseline_whisker;
%% Manual Sleep scoring
states_fs = 30;
states_dt = 1./states_fs;
states_N = floor(states_fs * duration);

if trial.has_var('sleep_stages')
    sleep_stages = trial.load_var('sleep_stages');
else
    sleep_stages = repmat({'pre_sleep'},1,states_N);
    sleep_stages = categorical(sleep_stages);
end
%% states
sp = dogbane.StateProcessor();
sp.preset = 'sleep_and_activity';
sp.fs = states_fs;

[states_trace,states_fs] = sp.process( ...
    duration, ...
    sleep_stages, ...
    states_dt, ...
    camera_wheel, ...
    camera_whisker, ...
    camera_dt);


states = struct; 
states.states_trace = states_trace;
states.states_fs = states_fs;
trial.save_var(states);
%% states sleep wake
sp = dogbane.StateProcessor();
sp.preset = 'sleep_and_wake';
sp.fs = states_fs;

[states_trace,states_fs] = sp.process( ...
    duration, ...
    sleep_stages, ...
    states_dt, ...
    camera_wheel, ...
    camera_whisker, ...
    camera_dt);


states_sleep_wake = struct; 
states_sleep_wake.states_trace = states_trace;
states_sleep_wake.states_fs = states_fs;
trial.save_var(states_sleep_wake);
%% states for transitions
sp = dogbane.StateProcessor();
sp.preset = 'sleep_and_activity';
sp.awakening = true;
sp.differentiate_awakening = true;
sp.quiet_wakefulness_padding_after = 0;
sp.fs = states_fs;

[states_trace,states_fs] = sp.process( ...
    duration, ...
    sleep_stages, ...
    states_dt, ...
    camera_wheel, ...
    camera_whisker, ...
    camera_dt);


states_transitions = struct; 
states_transitions.states_trace = states_trace;
states_transitions.states_fs = states_fs;
trial.save_var(states_transitions);
%% states with no limit on the duration of quiet wakefulness
sp = dogbane.StateProcessor();
sp.preset = 'sleep_and_activity';
sp.quiet_wakefulness_minimum_duration = 0;
sp.fs = states_fs;

[states_trace,states_fs] = sp.process( ...
    duration, ...
    sleep_stages, ...
    states_dt, ...
    camera_wheel, ...
    camera_whisker, ...
    camera_dt);


states_short_quiet = struct; 
states_short_quiet.states_trace = states_trace;
states_short_quiet.states_fs = states_fs;
trial.save_var(states_short_quiet);
end

