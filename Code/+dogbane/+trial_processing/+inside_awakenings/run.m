function run(tr)
% Use the awakenings in the older manual scoring to identify if the
% awakenings have movement/whisking or if they are quiet. 
tr.clear_var('inside_awakenings');
%% Read xl table
path = tr.path;
path = strsplit(path,filesep);
path = strjoin(path(1:end-1),filesep);
path = begonia.path.find_files(path,'_old.xlsx',false);

if isempty(path)
    return;
else
    path = path{1};
end

tbl = readtable(path);
%% Find the awakening episodes
trial_id = str2double(tr.name(end-2:end));
row = find(tbl.trial == trial_id);
if isempty(row)
    return;
end

awakenings = tbl.awakenings{row};
if isempty(awakenings)
    return;
end

awakenings = regexprep(awakenings,'\s','');
awakenings = strsplit(awakenings,';');
I = cellfun(@isempty,awakenings);
awakenings(I) = [];

wake_start = zeros(length(awakenings),1);
wake_end = zeros(length(awakenings),1);

for i = 1:length(awakenings)
    str = awakenings{i};
    str = strsplit(str,'-');
    ep = str2double(str);
    wake_start(i) = ep(1);
    wake_end(i) = ep(2);
end

%% camera traces
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
%% Create the trace of states
duration = seconds(tr.duration);

states_fs = 30;
states_dt = 1./states_fs;
states_N = floor(states_fs * duration);

% Create a dummy state vector with wakefulness. 
sleep_stages = repmat({'pre_sleep'},1,states_N);
sleep_stages = categorical(sleep_stages);

sp = alyssum.StateProcessor();
sp.preset = 'sleep_and_activity';
sp.fs = states_fs;
% Do not include locomotion as the wheel is often locked in the sleep
% trials.
sp.locomotion = false;

[states_trace,states_fs] = sp.process( ...
    duration, ...
    sleep_stages, ...
    states_dt, ...
    camera_wheel, ...
    camera_whisker, ...
    camera_dt);
%% Set all periods outside the awakenings as undefined
% This can lead to having episodes shorter than the minimums set in the
% StateProcessor, but oh well.
in_awake = false(1,length(states_trace));
for i = 1:length(wake_start)
    st = floor(wake_start(i)*states_fs)+1;
    en = floor(wake_end(i)*states_fs);
    in_awake(st:en) = true;
end
states_trace(~in_awake) = 'undefined';
%% Redefine states
states_trace(states_trace == 'quiet') = 'quiet_awakening';
states_trace(states_trace == 'whisking') = 'whisking_awakening';
%% Make the state trace into a table
row = 1;

state_cats = categories(states_trace);

o = struct();
for idx_state = 1:length(state_cats)
    state = state_cats{idx_state};
    [u,d] = begonia.util.consecutive_stages(states_trace == state);

    for idx_episode = 1:length(u)
        dur = d(idx_episode) - u(idx_episode) + 1;
        dur = dur/states_fs;

        t_start = u(idx_episode) - 1;
        t_start = t_start/states_fs;

        t_end = d(idx_episode);
        t_end = t_end/states_fs;

        o(row).State = state;
        o(row).StateStart = t_start;
        o(row).StateEnd = t_end;
        o(row).StateDuration = dur;

        row = row + 1;
    end
end

inside_awakenings = struct2table(o,'AsArray',true);
inside_awakenings = sortrows(inside_awakenings,'StateStart');
inside_awakenings.State = categorical(inside_awakenings.State);

inside_awakenings(inside_awakenings.State == 'undefined',:) = [];
%%
tr.save_var(inside_awakenings);
end

