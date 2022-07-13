function define_microarousals(trial)

tr = trial.rec_rig_trial;

%%
states = tr.load_var('states');
states_fs = states.states_fs;
states = states.states_trace;

nrem = states == 'nrem';

if ~any(nrem)
    return;
end
%%
camera_whisker = tr.load_var('camera_whisker')';
camera_fs = tr.load_var('camera_fs');
camera_t = (0:length(camera_whisker)-1)/camera_fs;

camera_whisker = resample(camera_whisker,camera_t,states_fs);

% make arrays same length
n = min(length(camera_whisker),length(nrem));
nrem = nrem(1:n);
camera_whisker = camera_whisker(1:n);

% This is the same as done in dogbane.util.state_from_camera_trace
whisking = camera_whisker >= 1.5;
% Bridge gaps
whisking = begonia.stage_functions.dilate_logical(whisking, round(2.5*states_fs));
whisking = begonia.stage_functions.erode_logical(whisking, round(2.5*states_fs));

% Microarousals are whisking less than 3 seconds.
long_whisk = begonia.stage_functions.erode_logical(whisking, round(3/2*states_fs));
long_whisk = begonia.stage_functions.dilate_logical(long_whisk, round(3/2*states_fs));
short_whisk = whisking - long_whisk;

nrem_microarousal = nrem & short_whisk;
nrem_long_whisk = nrem & long_whisk;

% figure;
% hold on
% plot(long_whisk,'DisplayName','long whisk');
% plot(nrem,'DisplayName','nrem');
% legend

% Find nrem 
[u,d] = begonia.stage_functions.consecutive_stages(nrem);
state_start = (u-1) / states_fs;
state_end = d / states_fs;
state = repmat({'nrem'},length(u),1);

% Find microarousals in nrem
[u,d] = begonia.stage_functions.consecutive_stages(nrem_microarousal);
state_start = cat(1,state_start,(u-1) / states_fs);
state_end = cat(1,state_end,d / states_fs);
state = cat(1,state,repmat({'microarousal'},length(u),1));

% Find long whisk in nrem
[u,d] = begonia.stage_functions.consecutive_stages(nrem_long_whisk);
state_start = cat(1,state_start,(u-1) / states_fs);
state_end = cat(1,state_end,d / states_fs);
state = cat(1,state,repmat({'long_whisk'},length(u),1));

state = categorical(state);
state_duration = state_end - state_start;

microarousals = table(state,state_start,state_end,state_duration);

tr.save_var(microarousals);

end