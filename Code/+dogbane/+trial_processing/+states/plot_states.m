function plot_states(trial)
trial = trial.rec_rig_trial;
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

camera_t = (0:length(camera_whisker)-1) * camera_dt;

% camera_t = reshape(camera_t,[],1);
% camera_whisker = reshape(camera_whisker,[],1);
% camera_wheel = reshape(camera_wheel,[],1);
% tbl = table(camera_t,camera_whisker,camera_wheel);
% begonia.path.make_dirs('~/Desktop/example_camera_trace.csv');
% writetable(tbl,'~/Desktop/example_camera_trace.csv');

%%
states = trial.load_var('states');
t = (0:length(states.states_trace)-1) / states.states_fs;
%%
f = figure;
f.Position(3:4) = [1500,3 * 200];

ax(1) = subplot(3,1,1);
plot(camera_t,camera_wheel);
title('Camera Wheel');

ax(2) = subplot(3,1,2);
plot(camera_t,camera_whisker);
title('Camera Whisking');

ax(3) = subplot(3,1,3);
plot(t,states.states_trace);
title('State Vector');

linkaxes(ax,'x');

end

