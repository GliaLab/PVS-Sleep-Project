function count_sleep_and_awakenings(tr)
tr = tr.rec_rig_trial;

tr.clear_var('sleep_and_awakenings')

tbl_episodes = tr.load_var('state_episodes_transitions');

tbl_episodes.state = tbl_episodes.State;
tbl_episodes.state_start = tbl_episodes.StateStart;
tbl_episodes.state_end = tbl_episodes.StateEnd;
tbl_episodes.state_duration = tbl_episodes.StateDuration;

tbl_episodes = tbl_episodes(:,{'state','state_start','state_end','state_duration'});

I = ismember(tbl_episodes.state,{'is','nrem','rem'});
tbl_episodes = tbl_episodes(I,:);

if isempty(tbl_episodes)
    return;
end

%%
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
%%
whisking = camera_whisker > 1.5;

whisking = begonia.stage_functions.dilate_logical(whisking, round(2.5/camera_dt));
whisking = begonia.stage_functions.erode_logical(whisking, round(2.5/camera_dt));

whisking(1) = 0;
whisking(end) = 0;
whisking = diff(whisking);

state_start = find(whisking == 1) * camera_dt;
state_end = find(whisking == -1) * camera_dt;

assert(length(state_start) == length(state_end));

state = repmat({'awakening'},length(state_start),1);
state = categorical(state);

state_duration = state_end - state_start;

tbl_whisking = table(state,state_start,state_end,state_duration);

tbl_whisking(tbl_whisking.state_duration < 3,:) = [];

tbl_episodes.has_awakening = false(height(tbl_episodes),1);
for i = 1:height(tbl_episodes)
    time_since_ep_end = tbl_whisking.state_start - tbl_episodes.state_end(i);
    I = time_since_ep_end < 5 & time_since_ep_end > 0;
    tbl_episodes.has_awakening(i) = any(I);
end

alternative_nrem_awakening_cnt = sum(tbl_episodes.has_awakening & tbl_episodes.state == 'nrem');

alternative_rem_awakening_cnt = sum(tbl_episodes.has_awakening & tbl_episodes.state == 'rem');

alternative_is_awakening_cnt = sum(tbl_episodes.has_awakening & tbl_episodes.state == 'is');

%%

tbl_episodes = tr.load_var('state_episodes_transitions');

sleep_time = seconds(tr.duration);

nrem_cnt = sum(tbl_episodes.State == 'nrem');

nrem_awakening_cnt = sum(tbl_episodes.State == 'nrem:awakening');

is_awakening_cnt = sum(tbl_episodes.State == 'is:awakening');

rem_awakening_cnt = sum(tbl_episodes.State == 'rem:awakening');

tbl_episodes(tbl_episodes.State == 'undefined',:) = [];
nrem_2_is_cnt = 0;
is_2_rem_cnt = 0;
is_2_nrem_cnt = 0;
for j = 2:height(tbl_episodes)
    % dur here is the timeperiod between the two states being counted.
    dur = tbl_episodes.StateStart(j) - tbl_episodes.StateEnd(j-1);

    if tbl_episodes.State(j-1) == 'nrem' && tbl_episodes.State(j) == 'is' && dur < 5
        nrem_2_is_cnt = nrem_2_is_cnt + 1;
    end

    if tbl_episodes.State(j-1) == 'is' && tbl_episodes.State(j) == 'rem' && dur < 12
        is_2_rem_cnt = is_2_rem_cnt + 1;
    end

    if tbl_episodes.State(j-1) == 'is' && tbl_episodes.State(j) == 'nrem' && dur < 5
        is_2_nrem_cnt = is_2_nrem_cnt + 1;
    end
end

sleep_and_awakenings = struct;
sleep_and_awakenings.sleep_time = sleep_time;
sleep_and_awakenings.nrem_cnt = nrem_cnt;
sleep_and_awakenings.nrem_2_is_cnt = nrem_2_is_cnt;
sleep_and_awakenings.nrem_awakening_cnt = nrem_awakening_cnt;
sleep_and_awakenings.is_awakening_cnt = is_awakening_cnt;
sleep_and_awakenings.rem_awakening_cnt = rem_awakening_cnt;
sleep_and_awakenings.is_2_rem_cnt = is_2_rem_cnt;
sleep_and_awakenings.is_2_nrem_cnt = is_2_nrem_cnt;

sleep_and_awakenings.alternative_nrem_awakening_cnt = alternative_nrem_awakening_cnt;
sleep_and_awakenings.alternative_rem_awakening_cnt = alternative_rem_awakening_cnt;
sleep_and_awakenings.alternative_is_awakening_cnt = alternative_is_awakening_cnt;

tr.save_var(sleep_and_awakenings);
end