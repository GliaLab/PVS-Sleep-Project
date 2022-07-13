clear all

%% Load trials and link trials.
ts = get_tseries();
ts = ts(ts.has_var('trial_id'));
ts = ts(ts.has_var('ts_metadata'));

tr = get_labview_trials();
tr = tr(tr.has_var('labview_metadata'));

ts_metadata = ts.load_var('ts_metadata');
if iscell(ts_metadata)
    ts_metadata = [ts_metadata{:}];
end
ts_start = [ts_metadata.start_time]';
ts_start.Format = 'uuuu/MM/dd HH:mm:ss';
trial_id = string(ts.load_var('trial_id'))';

labview_metadata = tr.load_var('labview_metadata');
labview_metadata = [labview_metadata{:}];
labview_start = [labview_metadata.start_time_abs]';
labview_start.Format = 'uuuu/MM/dd HH:mm:ss';

[I_ts,I_tr] = begonia.util.align_timeinfo(ts_start,labview_start);
tr = tr(I_tr);
ts = ts(I_ts);

tic
for i = 1:length(tr)
    if i == 1 || i == length(tr) || toc > 5
        tic
        begonia.logging.log(1,"%d / %d",i,length(tr))
    end
    
    % Save trial links.
    tr(i).save_var('tseries',ts(i).uuid);
    ts(i).save_var('labview',tr(i).uuid);
    
    % Assign the same trial_id of the tseries to the labview trial.
    tr(i).save_var("trial_id", trial_id(i));
end

% Export a table with the links
ts_metadata = ts.load_var('ts_metadata');
if length(ts_metadata) > 1
    ts_metadata = [ts_metadata{:}];
end
ts_start = [ts_metadata.start_time]';
ts_start.Format = 'uuuu/MM/dd HH:mm:ss';
trial_id = string(ts.load_var('trial_id'))';
ts_duration = [ts_metadata.duration]';
ts_duration.Format = 'hh:mm:ss';

labview_metadata = tr.load_var('labview_metadata');
if iscell(labview_metadata)
    labview_metadata = [labview_metadata{:}];
end
labview_start = [labview_metadata.start_time_abs]';
labview_start.Format = 'uuuu/MM/dd HH:mm:ss';
labview_id = [labview_metadata.path]';
labview_duration = [labview_metadata.duration]';
labview_duration.Format = 'hh:mm:ss';

linescan_to_labview_delay = seconds(labview_start - ts_start);

tbl = table(trial_id,labview_id,ts_start,labview_start,linescan_to_labview_delay,ts_duration,labview_duration);

[~,I] = sort(labview_start,'descend');
tbl = tbl(I,:);

path = fullfile(get_project_path(),"Plot","TSeries - Labview links",'Linked recordings.csv');
begonia.path.make_dirs(path);
writetable(tbl,path)

%% Make a table of tseries without link
ts = get_tseries();
ts = ts(ts.has_var('ts_metadata'));
ts = ts(~ts.has_var('labview'));

if ~isempty(ts)
    ts_metadata = ts.load_var('ts_metadata');
    if iscell(ts_metadata)
        ts_metadata = [ts_metadata{:}];
    end
    ts_start = [ts_metadata.start_time]';
    ts_start.Format = 'uuuu/MM/dd HH:mm:ss';
    trial_id = string(ts.load_var('trial_id'))';
    ts_duration = [ts_metadata.duration]';
    ts_duration.Format = 'hh:mm:ss';

    tbl_scan_unlink = table(trial_id,ts_start,ts_duration);

    [~,I] = sort(ts_start,'descend');
    tbl_scan_unlink = tbl_scan_unlink(I,:);

    path = fullfile(get_project_path(),"Plot","TSeries - Labview links",'Unlinked tseries.csv');
    begonia.path.make_dirs(path);
    writetable(tbl_scan_unlink,path)
end

%% Make a table of labview trials without link
tr = get_labview_trials();
tr = tr(tr.has_var('labview_metadata'));
tr = tr(~tr.has_var('tseries'));

if ~isempty(tr)
    labview_metadata = tr.load_var('labview_metadata');
    if iscell(labview_metadata)
        labview_metadata = [labview_metadata{:}];
    end
    labview_start = [labview_metadata.start_time_abs]';
    labview_start.Format = 'uuuu/MM/dd HH:mm:ss';
    labview_id = [labview_metadata.path]';
    labview_duration = [labview_metadata.duration]';
    labview_duration.Format = 'hh:mm:ss';

    tbl_labview_unlink = table(labview_id,labview_start,labview_duration);

    [~,I] = sort(labview_start,'descend');
    tbl_labview_unlink = tbl_labview_unlink(I,:);

    path = fullfile(get_project_path(),"Plot","TSeries - Labview links",'Unlinked labview.csv');
    begonia.path.make_dirs(path);
    writetable(tbl_labview_unlink,path)
end
