function plot_1(trial)

ts = trial.tseries;
tr = trial.rec_rig_trial;

dt = ts.dt;

%%
target_fs = 30;

roi_array = ts.load_var('roi_array');

%% Neuron somata traces (subtracted trace)
idx_neu = [roi_array.channel] == 2;
neu_rois = roi_array(idx_neu);
neu_ids = categorical({neu_rois.id})';

neu_traces = ts.load_var('ca_signal_neurons_subtracted',timeseries);
neu_traces = neu_traces.Data;

t = (0:size(neu_traces,1)-1) * dt;
neu_traces = resample(neu_traces,t,target_fs);

N = 10;
I = randsample(length(neu_rois),N);
neu_rois = neu_rois(I);
neu_ids = neu_ids(I);
neu_traces = neu_traces(:,I)';
neu_traces_t = (0:size(neu_traces,2)-1) / target_fs;

roi_events_param = ts.load_var('roi_events_param');
filter = begonia.util.gausswin(roi_events_param.neuron_sigma_smoothing*target_fs);
neu_traces = convn(neu_traces,filter','same');

%% ROI events (with neuron somata events)
roi_events = ts.load_var('roi_events');
%% traces from gliopil ROIs (both from the astrocyte and neuron channel)
I = strcmp({roi_array.group},'Gp');
gp_rois = roi_array(I);

gp_traces = ts.load_var('ca_signal_gliopil_traces');
gp_traces = struct2table(gp_traces);

N = 10;
I = randsample(height(gp_traces),N);
gp_traces = gp_traces.neu(I,:);
gp_traces_t = (0:size(gp_traces,2)-1) * dt;

filter = begonia.util.gausswin(3);
gp_traces = convn(gp_traces,filter','same');
%% camera_trace
camera_whisker = tr.load_var('camera_whisker');
camera_wheel = tr.load_var('camera_wheel');
camera_fs = tr.load_var('camera_fs');
camera_t = (0:length(camera_whisker)-1) / camera_fs;

%% Ecog
ecog = tr.load_var('eeg_norm');
ecog_fs = tr.load_var('eeg_fs');

order = 5;
band = [0.5,30]; % Hz
band = band * 2 / ecog_fs;
[b,a] = butter(order,band,'bandpass');

ecog = double(ecog);
ecog = filtfilt(b, a, ecog);

ecog_t = (0:length(ecog)-1) / ecog_fs;
%% EMG

emg = tr.load_var('emg');
emg_fs = tr.load_var('emg_fs');
emg_t = (0:length(emg)-1) / emg_fs;
%% States

states = tr.load_var('states');
states_fs = states.states_fs;
states = states.states_trace;
states_t = (0:length(states)-1) / states_fs;

%%
f = figure;
f.Position(3:4) = [2000,1000];

ax(1) = subplot(9,1,1);
plot(states_t,states)

ax(2) = subplot(9,1,2);
plot(camera_t,camera_whisker)
ylabel('Whisking (a.u.)');

ax(3) = subplot(9,1,3);
plot(camera_t,camera_wheel)
ylabel('Wheel (a.u.)');

ax(4) = subplot(9,1,4);
plot(ecog_t,ecog)
ylabel('ECoG (0.5 - 30 Hz)');

ax(5) = subplot(9,1,5);
plot(emg_t,emg)
ylabel('EMG (a.u.)');

ax(6) = subplot(9,1,6:7);
hold on;
for i = 1:size(gp_traces,1)
    x = gp_traces_t;
    y = gp_traces(i,:);
    y = y/mode(round(y)) - 1;
    y = y + i - 1;
    p = plot(x,y); 
    p.Color = [0,0.4470,0.7410,0.5];
    p.LineWidth = 0.5;
end
ylabel('Neuron Gp traces');

ax(7) = subplot(9,1,8:9);
offset_factor = 0.4;
hold on;
neu_events = {};
for i = 1:size(neu_traces,1)
    offset = (i-1) * offset_factor;
    
    x = neu_traces_t;
    y = neu_traces(i,:);
    y = y + offset;
    p = plot(x,y);
    p.Color = [0,0.4470,0.7410,0.5];
    p.LineWidth = 0.5;
    
    tbl = roi_events(roi_events.roi_id == neu_ids(i),:);
    s = scatter(tbl.x,tbl.y + offset);
    s.MarkerEdgeColor = 'none';
    s.MarkerFaceColor = 'r';
    
    tbl = tbl(:,{'x','y'});
    tbl.y = tbl.y + offset;
    
    neu_events{end+1} = tbl;
end
ylim([-0.2,offset+offset_factor*2]);
ylabel('Neuron Somata');
neu_events = cat(1,neu_events{:});

linkaxes(ax,'x');

xlim([0,x(end)]);
%%

plot_data = struct;
plot_data.camera_t = camera_t;
plot_data.camera_whisker = camera_whisker;
plot_data.camera_wheel = camera_wheel;
plot_data.neuron_events = neu_events;
plot_data.neuron_somata_traces = neu_traces;
plot_data.neuron_somata_traces_t = neu_traces_t;
plot_data.neuron_gp_traces = gp_traces;
plot_data.neuron_gp_traces_t = gp_traces_t;
plot_data.ecog = ecog;
plot_data.ecog_t = ecog_t;
plot_data.emg = emg;
plot_data.emg_t = emg_t;
%%
genotype = tr.load_var('genotype');
trial_id = tr.load_var('trial');
fov_id = ts.load_var('fov_id');

filename = sprintf('~/Desktop/sleep_project/traces_NS_neuropil/%s_%s_%d.mat',genotype,trial_id,fov_id);
begonia.path.make_dirs(filename);
% begonia.util.logging.vlog(1,'Exporting to %s ',filename);
save(filename,'plot_data');

filename = sprintf('~/Desktop/sleep_project/traces_NS_neuropil/%s_%s_%d.png',genotype,trial_id,fov_id);
begonia.util.logging.vlog(1,'Exporting to %s ',filename);
export_fig(f,filename);
%%

img_ast = ts.get_avg_img(1,1);
img_neu = ts.get_avg_img(1,2);

lim_ast = [0,prctile(img_ast(:),99)];
lim_neu = [0,prctile(img_neu(:),99)];

img_ast = begonia.mat_functions.normalize(img_ast,lim_ast);
img_neu = begonia.mat_functions.normalize(img_neu,lim_neu);

dim = size(img_ast);

img = zeros(dim(1),dim(2),3);

f = figure;
img(:,:,1) = img_neu;
img(:,:,3) = img_neu;
img(:,:,2) = img_ast;

imshow(img);

filename = sprintf('~/Desktop/sleep_project/traces_NS_neuropil/fov_%s_%s_%d.png',genotype,trial_id,fov_id);
export_fig(f,filename);

close all;

end

