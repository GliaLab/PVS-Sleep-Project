function sleep_episodes = mark_sleep(ecog,ecog_t,emg,emg_t,existing_sleep_episodes, states)
if nargin < 3
    emg = [];
    emg_t = [];
    existing_sleep_episodes = [];
end
if nargin < 6
    states = {'NREM','IS','REM'};
end

ecog = reshape(ecog,1,[]);
ecog_fs = 1/(ecog_t(2) - ecog_t(1));

if ~isempty(emg)
    emg = reshape(emg,1,[]);
    emg_fs = 1/(emg_t(2) - emg_t(1));
end

%% Calculate delta, theta, sigma traces
ordr = 10;

begonia.logging.log(1,'Filtering ECoG');
aa = designfilt('bandpassiir','FilterOrder',ordr, ...
    'HalfPowerFrequency1',0.5,'HalfPowerFrequency2',30, ...
    'SampleRate',ecog_fs);
ecog_filt = filter(aa, ecog);

% Calculate Delta RMS
begonia.logging.log(1,'Filtering delta');
delta_band = designfilt('bandpassiir','FilterOrder',ordr, ...
    'HalfPowerFrequency1',0.5,'HalfPowerFrequency2',4, ...
    'SampleRate',ecog_fs);

window = 5 * ecog_fs;
spacing = 0.5 * ecog_fs;
new_fs = ecog_fs / spacing;

delta = filter(delta_band, ecog);
delta = begonia.util.window_transform(delta,window,spacing);
delta = rms(delta,1);
delta_t = (0:length(delta)-1) / new_fs;

% Calculate Theta RMS
begonia.logging.log(1,'Filtering theta');
theta_band = designfilt('bandpassiir','FilterOrder',ordr, ...
    'HalfPowerFrequency1',5,'HalfPowerFrequency2',9, ...
    'SampleRate',ecog_fs);

theta = filter(theta_band, ecog);
theta = begonia.util.window_transform(theta,window,spacing);
theta = rms(theta,1);
theta_t = (0:length(theta)-1) / new_fs;

% Calculate Sigma RMS
begonia.logging.log(1,'Filtering sigma');
sigma_band = designfilt('bandpassiir','FilterOrder',ordr, ...
    'HalfPowerFrequency1',10,'HalfPowerFrequency2',16, ...
    'SampleRate',ecog_fs);

sigma = filter(sigma_band, ecog);
sigma = begonia.util.window_transform(sigma,window,spacing);
sigma = rms(sigma,1);
sigma_t = (0:length(sigma)-1) / new_fs;

%% Create ratio trace
theta_ratio = theta ./ (theta + delta);

%% Smooth delta, theta, sigma and ratio traces
% smoothing_window = 0.5 * new_fs;
% smoothing_vec = begonia.util.gausswin(smoothing_window);
% 
% delta = conv(delta,smoothing_vec,'same');
% theta = conv(theta,smoothing_vec,'same');
% sigma = conv(sigma,smoothing_vec,'same');
% theta_ratio = conv(theta_ratio,smoothing_vec,'same');
%% Filter EMG
if ~isempty(emg)
    begonia.logging.log(1,'Filtering EMG');
    bb = designfilt('highpassiir','FilterOrder',ordr, ...
        'HalfPowerFrequency',100, ...
        'SampleRate',emg_fs);
    emg_filt = filter(bb, emg);
end

%% Downsample ECoG and EMG traces to 30 Hz
dur = ecog_t(end) - ecog_t(1);
N = 30*dur;
I = round(linspace(1,length(ecog_filt),N));
ecog_filt = ecog_filt(I);
ecog_t = ecog_t(I);

if ~isempty(emg)
    dur = emg_t(end) - emg_t(1);
    N = 30*dur;
    I = round(linspace(1,length(emg_filt),N));
    emg_filt = emg_filt(I);
    emg_t = emg_t(I);
end
%% Format the traces in a table which is used to the GUI.

if isempty(emg)
    trace = {ecog_filt,delta,theta,sigma,theta_ratio}';
    trace_name = {'Filtered ECoG (0.5 - 30 Hz)', ...
        'Delta (0.5 - 4 Hz) RMS', ...
        'Theta (5 - 9 Hz) RMS', ...
        'Sigma (10 - 16 Hz) RMS', ...
        'Theta/(Theta+Delta) Ratio'}';
    t = {ecog_t,delta_t,theta_t,sigma_t,theta_t}';
else
    trace = {ecog_filt,delta,theta,sigma,theta_ratio,emg_filt}';
    trace_name = {'Filtered ECoG (0.5 - 30 Hz)', ...
        'Delta (0.5 - 4 Hz) RMS', ...
        'Theta (5 - 9 Hz) RMS', ...
        'Sigma (10 - 16 Hz) RMS', ...
        'Theta/(Theta+Delta) Ratio', ...
        'Filtered EMG (0-100 Hz)'}';
    t = {ecog_t,delta_t,theta_t,sigma_t,theta_t,emg_t}';
end

trace_table = table(trace,trace_name,t);
%% Open GUI
gui_handle = yucca.gui.EpisodeMarker(trace_table,states,[],existing_sleep_episodes);
uiwait(gui_handle.figure);

% Get the marked episodes from the GUI.
sleep_episodes = gui_handle.episode_table;
