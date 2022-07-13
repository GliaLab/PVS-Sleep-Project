function plot_roa_gp_vs_neu_gp(trial,start_end)
if nargin < 2
    start_end = [];
end
%% 
tr = trial.rec_rig_trial;
ts = trial.tseries;

duration = seconds(tr.duration);
%% Manual Sleep scoring
states_fs = 30;
states_dt = 1./states_fs;
states_N = floor(states_fs * duration);

if tr.has_var('sleep_stages')
    sleep_stages = tr.load_var('sleep_stages');
else
    sleep_stages = repmat({'pre_sleep'},1,states_N);
    sleep_stages = categorical(sleep_stages);
end
%%
roi_array = ts.load_var('roi_array');
gliopil_fluo = ts.load_var('ca_signal_df_f0');
gliopil_fluo_t = gliopil_fluo.Time;
gliopil_fluo = gliopil_fluo.Data;

I = ismember({roi_array.group},'Gp');
gliopil_fluo = gliopil_fluo(:,I);
gliopil_fluo = mean(gliopil_fluo,2);
gliopil_fluo = convn(gliopil_fluo,begonia.util.gausswin(7),'same');
%%
camera_fs = tr.load_var('camera_fs');
camera_whisker = tr.load_var('camera_whisker');
camera_wheel = tr.load_var('camera_wheel');
camera_t = (0:length(camera_whisker)-1)/camera_fs;
camera_dt = 1/camera_fs;

%%
gliopil_roa = ts.load_var('roa_frequency_trace_Gp');
gliopil_roa = convn(gliopil_roa,begonia.util.gausswin(7)','same');
gliopil_roa = gliopil_roa * 60 * 100;

gliopil_roa_t = (0:length(gliopil_roa)-1)*ts.dt;

%%
neuropil = ts.load_var('ca_signal_Gp_neu');

neuropil = double(neuropil);
neuropil = convn(neuropil,begonia.util.gausswin(7)','same');
neuropil = round(neuropil,1);
neuropil = neuropil / mode(neuropil) - 1;

neuropil_t = (0:length(neuropil)-1)*ts.dt;
%%

sp = dogbane.StateProcessor();
sp.preset = 'sleep_and_activity';
sp.awakening = true;
sp.differentiate_awakening = true;
sp.manual_sleep = true;
% sp.ignore_activity_during_sleep = true;
sp.fs = states_fs;

[state_trace,states_fs] = sp.process( ...
    duration, ...
    sleep_stages, ...
    states_dt, ...
    camera_wheel, ...
    camera_whisker, ...
    camera_dt);

state_trace_t = (0:length(state_trace)-1) / states_fs;

% state_trace = tr.load_var('states_transitions');
% state_trace_t = (0:length(state_trace.states_trace)-1) / state_trace.states_fs;
% state_trace = state_trace.states_trace;
%%
f = figure;
f.Position(3:4) = [1200,700];

ax(1) = subplot(5,1,1);
plot(state_trace_t,state_trace);
title('State')

ax(2) = subplot(5,1,2);
plot(gliopil_roa_t,gliopil_roa);
title('ROA frequency in Gp ROIs')

ax(3) = subplot(5,1,3);
plot(neuropil_t,neuropil);
title('Neuron df/f0 in Gp ROIs')

ax(4) = subplot(5,1,4);
plot(camera_t,camera_whisker);
title('Camera whisker')

ax(5) = subplot(5,1,5);
plot(gliopil_fluo_t,gliopil_fluo);
title('Mean Gp df/f0')

set(ax,'FontSize',20);

linkaxes(ax,'x');

if ~isempty(start_end)
    xlim(start_end);
end
%%
path = '~/Desktop/sleep_project/roa_freq_vs_neuropil_plots';
filename = sprintf('%s_%s.fig',trial.genotype,trial.trial_id);
path = fullfile(path,filename);
begonia.path.make_dirs(path);
export_fig(f,path);
begonia.util.logging.vlog(1,'Saving figure to : %s',path);

path = '~/Desktop/sleep_project/roa_freq_vs_neuropil_plots';
filename = sprintf('%s_%s.png',trial.genotype,trial.trial_id);
path = fullfile(path,filename);
begonia.path.make_dirs(path);
export_fig(f,path);
%%
if ~isempty(start_end)
    fs = 30;
    
    gliopil_roa = resample(gliopil_roa,gliopil_roa_t,fs)';
    neuropil = resample(neuropil,neuropil_t,fs)';
    gliopil_fluo = resample(gliopil_fluo,gliopil_fluo_t,fs);
    
    t = (0:length(gliopil_roa)-1)/fs;
    t = t';
    
    st = start_end(1) * fs;
    en = start_end(2) * fs;
    
    t = t(st:en);
    gliopil_roa = gliopil_roa(st:en);
    neuropil = neuropil(st:en);
    gliopil_fluo = gliopil_fluo(st:en);
    
    
    tbl = table(t,gliopil_roa,gliopil_fluo,neuropil);
    
    
    path = '~/Desktop/sleep_project/roa_freq_vs_neuropil_plots';
    filename = sprintf('%s_%s_%d_%d.csv',trial.genotype,trial.trial_id,start_end(1),start_end(2));
    path = fullfile(path,filename);
    begonia.util.save_table(path,tbl);
end

end

