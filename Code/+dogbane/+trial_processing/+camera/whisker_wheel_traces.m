function whisker_wheel_traces(trial)
tr = trial.rec_rig_trial;

tr.clear_var('camera_wheel');
tr.clear_var('camera_whisker');
tr.clear_var('camera_fs');

camera_regions = tr.load_var('camera_regions');

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

tr.save_var(camera_wheel);
tr.save_var(camera_whisker);
tr.save_var(camera_fs);
end

