clear all

begonia.logging.set_level(1);
scans = eustoma.get_linescans();
scans = scans(scans.has_var('path'));

trials = eustoma.get_linescans_recrig();

dloc_list = yucca.datanode.DataNodeList();
dloc_list.add(trials);
dloc_list.add(scans);
%% Load data
path            = scans.load_var('path')';
path            = string(path);
vessel_id       = scans.load_var('vessel_id',"")';
vessel_id       = string(vessel_id);
vessel_type     = scans.load_var('vessel_type','Missing')';
vessel_type      = string(vessel_type);

has_labview_trial = scans.has_var('recrig')';
linescan_start  = NaT(length(scans),1);
num_channels    = nan(length(scans),1);
sleep_episodes  = false(length(scans),1);
trial_type      = repmat("Missing",length(scans),1);
genotype        = repmat("Misssing",length(scans),1);
trial_id        = repmat("Misssing",length(scans),1);
fs              = nan(length(scans),1);
duration        = nan(length(scans),1);
awakening_episodes = scans.has_var('awakening_episodes')';
clean_episodes = scans.has_var('clean_episodes')';

linescan_info   = scans.load_var('linescan_info');
for i = 1:length(scans)
    if ~isempty(linescan_info{i})
        linescan_start(i) = linescan_info{i}.start_time;
        num_channels(i) = linescan_info{i}.channels;
        fs(i) = linescan_info{i}.fs;
        duration(i) = linescan_info{i}.duration;
    end
    
    trial_ids = scans(i).load_var('trial_id',[]);
    if ~isempty(trial_ids)
        genotype(i) = trial_ids.genotype;
        trial_id(i) = trial_ids.trial_id;
    end
    
    if has_labview_trial(i)
        sleep_episodes(i) = scans(i).find_dnode('recrig').has_var('sleep_episodes');
        trial_type(i) = scans(i).find_dnode('recrig').load_var('trial_type',"Missing");
    end
end
%% Check cropping status.
cropped = scans.has_var('linescan_crop')';
cropping_finished = scans.has_var('linescan_crop_status')';
cropping_finished(cropped) = true;

%% Check crosstalk status.
crosstalk_adjusted = scans.has_var('crosstalk_factor')';
crosstalk_finished = crosstalk_adjusted;
crosstalk_finished(~cropped) = true;
crosstalk_finished(num_channels == 1) = true;

%% Check red threshold.
red_diam = scans.has_var('diameter_red_baseline')';
red_diam_finished = scans.has_var('vessels_red_threshold_status')';
red_diam_finished(~cropped) = true;
red_diam_finished(red_diam) = true;

%% Check green threshold.
green_diam = scans.has_var('diameter_green_baseline')';
green_diam_finished = scans.has_var('vessels_green_threshold_status')';
green_diam_finished(~cropped) = true;
green_diam_finished(num_channels == 1) = true;
green_diam_finished(green_diam) = true;

%% Make a table of trial ids and metadata.
tbl = table(trial_id,trial_type,vessel_type,vessel_id,duration,fs,sleep_episodes,awakening_episodes,clean_episodes,red_diam,green_diam);
% Remove ignored trials.
tbl(ismember(tbl.trial_type,["Missing","Ignore"]),:) = [];
tbl(ismember(tbl.vessel_type,["Missing","Ignore"]),:) = [];
tbl(~tbl.red_diam & ~tbl.green_diam,:) = [];

tbl.red_diam = [];
tbl.green_diam = [];

tbl = sortrows(tbl,1:width(tbl),'descend');
tbl_path = fullfile(eustoma.get_plot_path,'Linescan overview','Trial IDs.csv');
begonia.util.save_table(tbl_path,tbl);

tbl_path = fullfile(eustoma.get_plot_path,'Linescan overview','Trial IDs Awake.csv');
begonia.util.save_table(tbl_path,tbl(tbl.trial_type == "Awake",:));
%% Processing status
tbl = table(trial_type,genotype,vessel_type,num_channels,trial_id,has_labview_trial,sleep_episodes,awakening_episodes,clean_episodes,cropped,crosstalk_adjusted,red_diam,green_diam,path,linescan_start,fs,duration);
tbl = sortrows(tbl,1:width(tbl));
tbl_path = fullfile(eustoma.get_plot_path,'Linescan overview','Processing status with ignore - trial id.csv');
begonia.util.save_table(tbl_path,tbl);

[G,tbl1] = findgroups(tbl(:,["trial_type","num_channels","has_labview_trial","sleep_episodes","awakening_episodes","clean_episodes","cropped","crosstalk_adjusted","red_diam","green_diam"]));
tbl1.num_trials = splitapply(@length,tbl.path,G);
tbl1 = sortrows(tbl1,1:width(tbl1));
tbl_path = fullfile(eustoma.get_plot_path,'Linescan overview','Processing status with ignore - trial type.csv');
begonia.util.save_table(tbl_path,tbl1);

[G,tbl1] = findgroups(tbl(:,["trial_type","genotype","num_channels","has_labview_trial","sleep_episodes","awakening_episodes","clean_episodes","cropped","crosstalk_adjusted","red_diam","green_diam"]));
tbl1.num_trials = splitapply(@length,tbl.path,G);
tbl1 = sortrows(tbl1,1:width(tbl1));
tbl_path = fullfile(eustoma.get_plot_path,'Linescan overview','Processing status with ignore - genotype.csv');
begonia.util.save_table(tbl_path,tbl1);

[G,tbl1] = findgroups(tbl(:,["trial_type","genotype","vessel_type","num_channels","has_labview_trial","sleep_episodes","awakening_episodes","clean_episodes","cropped","crosstalk_adjusted","red_diam","green_diam"]));
tbl1.num_trials = splitapply(@length,tbl.path,G);
tbl1 = sortrows(tbl1,1:width(tbl1));
tbl_path = fullfile(eustoma.get_plot_path,'Linescan overview','Processing status with ignore - vessel type.csv');
begonia.util.save_table(tbl_path,tbl1);

% Remove the ignored trials.
tbl(ismember(tbl.trial_type,["Missing","Ignore"]),:) = [];
tbl(ismember(tbl.vessel_type,["Missing","Ignore"]),:) = [];
tbl(~tbl.red_diam & ~tbl.green_diam,:) = [];

tbl_path = fullfile(eustoma.get_plot_path,'Linescan overview','Processing status - trial id.csv');
begonia.util.save_table(tbl_path,tbl);

[G,tbl1] = findgroups(tbl(:,["trial_type","num_channels","has_labview_trial","sleep_episodes","awakening_episodes","clean_episodes","cropped","crosstalk_adjusted","red_diam","green_diam"]));
tbl1.num_trials = splitapply(@length,tbl.path,G);
tbl1 = sortrows(tbl1,1:width(tbl1));
tbl_path = fullfile(eustoma.get_plot_path,'Linescan overview','Processing status - trial type.csv');
begonia.util.save_table(tbl_path,tbl1);

[G,tbl1] = findgroups(tbl(:,["trial_type","genotype","num_channels","has_labview_trial","sleep_episodes","awakening_episodes","clean_episodes","cropped","crosstalk_adjusted","red_diam","green_diam"]));
tbl1.num_trials = splitapply(@length,tbl.path,G);
tbl1 = sortrows(tbl1,1:width(tbl1));
tbl_path = fullfile(eustoma.get_plot_path,'Linescan overview','Processing status - genotype.csv');
begonia.util.save_table(tbl_path,tbl1);

[G,tbl1] = findgroups(tbl(:,["trial_type","genotype","vessel_type","num_channels","has_labview_trial","sleep_episodes","awakening_episodes","clean_episodes","cropped","crosstalk_adjusted","red_diam","green_diam"]));
tbl1.num_trials = splitapply(@length,tbl.path,G);
tbl1 = sortrows(tbl1,1:width(tbl1));
tbl_path = fullfile(eustoma.get_plot_path,'Linescan overview','Processing status - vessel type.csv');
begonia.util.save_table(tbl_path,tbl1);
%% Make figures of the "valid" data from the above table.
f = figure;
histogram(tbl.fs(tbl.green_diam | tbl.red_diam))
xlabel("Sampling frequency")
% Save
filename = fullfile(eustoma.get_plot_path,'Linescan overview',"Sampling frequency histogram.png");
begonia.path.make_dirs(filename);
exportgraphics(f,filename);
close(f)

f = figure;
histogram(tbl.duration(tbl.green_diam | tbl.red_diam), "BinWidth", 10)
xlabel("Duration");
% Save
filename = fullfile(eustoma.get_plot_path,'Linescan overview',"Duration histogram.png");
begonia.path.make_dirs(filename);
exportgraphics(f,filename);
close(f)

%% Finalization status
tbl = table(trial_type,genotype,vessel_type,num_channels,trial_id,has_labview_trial,sleep_episodes,awakening_episodes,clean_episodes,cropping_finished,crosstalk_finished,red_diam_finished,green_diam_finished,path,linescan_start,fs,duration);
tbl = sortrows(tbl,1:width(tbl));
tbl_path = fullfile(eustoma.get_plot_path,'Linescan overview','Status with ignore - trial id.csv');
begonia.util.save_table(tbl_path,tbl);

% Make a another table, but include the processing state of the red and
% green diam so they can be ignored.
tbl = table(trial_type,genotype,vessel_type,num_channels,trial_id,has_labview_trial,sleep_episodes,awakening_episodes,clean_episodes,cropping_finished,crosstalk_finished,red_diam_finished,green_diam_finished,path,linescan_start,fs,duration,red_diam,green_diam);

[G,tbl1] = findgroups(tbl(:,["trial_type","num_channels","has_labview_trial","sleep_episodes","awakening_episodes","clean_episodes","cropping_finished","crosstalk_finished","red_diam_finished","green_diam_finished"]));
tbl1.num_trials = splitapply(@length,tbl.path,G);
tbl1 = sortrows(tbl1,1:width(tbl1));
tbl_path = fullfile(eustoma.get_plot_path,'Linescan overview','Status with ignore - trial type.csv');
begonia.util.save_table(tbl_path,tbl1);

[G,tbl1] = findgroups(tbl(:,["trial_type","genotype","num_channels","has_labview_trial","sleep_episodes","awakening_episodes","clean_episodes","cropping_finished","crosstalk_finished","red_diam_finished","green_diam_finished"]));
tbl1.num_trials = splitapply(@length,tbl.path,G);
tbl1 = sortrows(tbl1,1:width(tbl1));
tbl_path = fullfile(eustoma.get_plot_path,'Linescan overview','Status with ignore - genotype.csv');
begonia.util.save_table(tbl_path,tbl1);

[G,tbl1] = findgroups(tbl(:,["trial_type","genotype","vessel_type","num_channels","has_labview_trial","sleep_episodes","awakening_episodes","clean_episodes","cropping_finished","crosstalk_finished","red_diam_finished","green_diam_finished"]));
tbl1.num_trials = splitapply(@length,tbl.path,G);
tbl1 = sortrows(tbl1,1:width(tbl1));
tbl_path = fullfile(eustoma.get_plot_path,'Linescan overview','Status with ignore - vessel type.csv');
begonia.util.save_table(tbl_path,tbl1);

% Remove the ignored trials.
tbl(ismember(tbl.trial_type,["Missing","Ignore"]),:) = [];
tbl(ismember(tbl.vessel_type,["Missing","Ignore"]),:) = [];
tbl(~tbl.red_diam & ~tbl.green_diam,:) = [];

tbl_path = fullfile(eustoma.get_plot_path,'Linescan overview','Status - trial id.csv');
begonia.util.save_table(tbl_path,tbl);

[G,tbl1] = findgroups(tbl(:,["trial_type","num_channels","has_labview_trial","sleep_episodes","awakening_episodes","clean_episodes","cropping_finished","crosstalk_finished","red_diam_finished","green_diam_finished"]));
tbl1.num_trials = splitapply(@length,tbl.path,G);
tbl1 = sortrows(tbl1,1:width(tbl1));
tbl_path = fullfile(eustoma.get_plot_path,'Linescan overview','Status - trial type.csv');
begonia.util.save_table(tbl_path,tbl1);

[G,tbl1] = findgroups(tbl(:,["trial_type","genotype","num_channels","has_labview_trial","sleep_episodes","awakening_episodes","clean_episodes","cropping_finished","crosstalk_finished","red_diam_finished","green_diam_finished"]));
tbl1.num_trials = splitapply(@length,tbl.path,G);
tbl1 = sortrows(tbl1,1:width(tbl1));
tbl_path = fullfile(eustoma.get_plot_path,'Linescan overview','Status - genotype.csv');
begonia.util.save_table(tbl_path,tbl1);

[G,tbl1] = findgroups(tbl(:,["trial_type","genotype","vessel_type","num_channels","has_labview_trial","sleep_episodes","awakening_episodes","clean_episodes","cropping_finished","crosstalk_finished","red_diam_finished","green_diam_finished"]));
tbl1.num_trials = splitapply(@length,tbl.path,G);
tbl1 = sortrows(tbl1,1:width(tbl1));
tbl_path = fullfile(eustoma.get_plot_path,'Linescan overview','Status - vessel type.csv');
begonia.util.save_table(tbl_path,tbl1);
%%
begonia.logging.log(1,'Finished');