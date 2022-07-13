clear all

%% Load tseries
ts = get_tseries();
ts = ts(ts.has_var("channel_time_series"));
ts = ts(ts.has_var("ts_metadata"));

%% Load the csv with trial_id and info about the baseline and the decay window.
tbl_path = fullfile(get_project_path(),"Data","Baseline and decay window.csv");
tbl = readtable(tbl_path);

%% Find the lowest sampling rate and use that.
ts_metadata = ts.load_var('ts_metadata');
ts_metadata = cat(1,ts_metadata{:});
fs = 1/max([ts_metadata.dt]);
fs = round(fs);

%%
processed_count = 0;
tic
for i = 1:length(ts)
    if i == 1 || i == length(ts) || toc > 5
        tic
        begonia.logging.log(1,"%d / %d",i,length(ts))
    end
    
    channel_time_series = ts(i).load_var("channel_time_series");
    
    % Compare the trial id to the filename in the table.
    trial_id = channel_time_series.trial_id(1);
    I = compare_trial_id(trial_id, tbl.FileName);
    if isempty(I); continue; end
    
    % Create baseline and decay episodes.
    baseline = table;
    baseline.ep = "Baseline";
    baseline.ep_start = tbl.Start_baseline(I) / channel_time_series.fs(1);
    baseline.ep_end = tbl.End_baseline(I) / channel_time_series.fs(1);
    decay = table;
    decay.ep = "Decay";
    decay.ep_start = tbl.AmplitudeFrame(I) / channel_time_series.fs(1);
    decay.ep_end = tbl.DecayEndFrame(I) / channel_time_series.fs(1);
    baseline_and_decay = cat(1,baseline,decay);
    baseline_and_decay.ep_duration = baseline_and_decay.ep_end - baseline_and_decay.ep_start;
    
    % Calculate the decay and baseline episode indices with resampled
    % sampling frequency.
    st = tbl.AmplitudeFrame(I) / channel_time_series.fs(1);
    st = round(st * fs) + 1;
    en = tbl.DecayEndFrame(I) / channel_time_series.fs(1);
    en = round(en * fs) + 1;
    b_st = tbl.Start_baseline(I) / channel_time_series.fs(1);
    b_st = round(b_st * fs) + 1;
    b_en = tbl.End_baseline(I) / channel_time_series.fs(1);
    b_en = round(b_en * fs) + 1;

    % Resample data to the lowest sampling frequency 
    for j = 1:height(channel_time_series)
        [y,x] = resample(channel_time_series.y{j},channel_time_series.x{j},fs);
        channel_time_series.x{j} = x;
        channel_time_series.y{j} = y;
        channel_time_series.fs(j) = fs;
    end
    
    if length(channel_time_series.x{1}) < st
        begonia.logging.log(1,"Amplitude frame outside duration of trial :  #%d %s",I,trial_id);
        continue;
    end

    % Create a new time series table with decay traces.
    decay_time_series = channel_time_series;
    for j = 1:height(channel_time_series)
        decay_time_series.f0(j) = mean(channel_time_series.y{j}(b_st:b_en));
        decay_time_series.y0(j) = mean(channel_time_series.y{j}(st)) / decay_time_series.f0(j) - 1;
        decay_time_series.y{j} = channel_time_series.y{j}(st:en) / decay_time_series.f0(j) - 1;
        decay_time_series.x{j} = channel_time_series.x{j}(1:en-st+1);
        decay_time_series.name(j) = "Channel " + j + " decay";
        decay_time_series.ylabel(j) = "df/f0";
    end

    % Create a new time series table with decay traces and some seconds before.
    decay_time_series_extended = channel_time_series;
    sec_before = 3;
    offset = round(sec_before * fs);
    for j = 1:height(channel_time_series)
        decay_time_series_extended.f0(j) = mean(channel_time_series.y{j}(b_st:b_en));
        decay_time_series_extended.y0(j) = mean(channel_time_series.y{j}(st)) / decay_time_series_extended.f0(j) - 1;
        decay_time_series_extended.y{j} = channel_time_series.y{j}(st - offset:en) / decay_time_series_extended.f0(j) - 1;
        decay_time_series_extended.x{j} = channel_time_series.x{j}(1:en - st + 1 + offset) - sec_before;
        decay_time_series_extended.name(j) = "Channel " + j + " decay";
        decay_time_series_extended.ylabel(j) = "df/f0";
    end
    
    ts(i).save_var(baseline_and_decay);
    ts(i).save_var(decay_time_series);
    ts(i).save_var(decay_time_series_extended);
    
    processed_count = processed_count + 1;
    
end

begonia.logging.log(1,"%d/%d trials in csv procssed.",processed_count,height(tbl));

function idx = compare_trial_id(trial_id, filenames)
filenames = string(filenames);

parts_1 = strsplit(trial_id);
parts_1 = fliplr(parts_1);

% Return the first filename that contains all the parts of trial_id.
for i = 1:length(filenames)
    parts_2 = strrep(filenames(i),"/"," ");
    parts_2 = strrep(parts_2,"\"," ");
    parts_2 = strsplit(parts_2);
    parts_2 = fliplr(parts_2);
    
    % Compare parts_1 and parts_2.
    for j = 1:length(parts_1)
        if ~contains(parts_2(j), parts_1(j))
            break;
        end
    end
    % Check if the loop completed: means parts_2 adequatly matches parts_1.
    if j == length(parts_1)
        idx = i;
        return;
    end
end
idx = [];

end