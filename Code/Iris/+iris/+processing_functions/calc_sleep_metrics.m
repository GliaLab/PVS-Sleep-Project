function calc_sleep_metrics(tr)

ecog = tr.load_var("ecog");

% Use same filter order for all filters.
ordr = 10;

% Define variables for calculating RMS.
window = 5 * ecog.fs;
spacing = 0.5 * ecog.fs;
new_fs = ecog.fs / spacing;

% Calculate filtered ecog.
aa = designfilt('bandpassiir','FilterOrder',ordr, ...
    'HalfPowerFrequency1',0.5,'HalfPowerFrequency2',30, ...
    'SampleRate',ecog.fs);
y_ecog_filt = filter(aa, ecog.y{1});
% Put into time series table.
ecog_filt = ecog;
ecog_filt.y{1} = y_ecog_filt;
ecog_filt.name = "ECoG (0.5 Hz - 30 Hz)";
% Resample to 60 Hz to save space.
ecog_filt = iris.time_series.resample(ecog_filt,60);
% Save.
tr.save_var(ecog_filt);

% Calculate Delta RMS
delta_band = designfilt('bandpassiir','FilterOrder',ordr, ...
    'HalfPowerFrequency1',0.5,'HalfPowerFrequency2',4, ...
    'SampleRate',ecog.fs);
y_delta = filter(delta_band, ecog.y{1});
% Calculate RMS.
y_delta = begonia.util.window_transform(y_delta,window,spacing);
y_delta = rms(y_delta,1);
x_delta = (0:length(y_delta)-1) / new_fs;
% Put into time series table.
delta = ecog;
delta.y{1} = y_delta;
delta.x{1} = x_delta;
delta.fs = new_fs;
delta.ylabel = "Delta RMS (a.u.)";
delta.name = "ECoG delta RMS (0.5 Hz - 4 Hz)";
% Save.
tr.save_var(delta);

% Calculate Theta RMS
theta_band = designfilt('bandpassiir','FilterOrder',ordr, ...
    'HalfPowerFrequency1',5,'HalfPowerFrequency2',9, ...
    'SampleRate',ecog.fs);
y_theta = filter(theta_band, ecog.y{1});
% Calculate RMS.
y_theta = begonia.util.window_transform(y_theta,window,spacing);
y_theta = rms(y_theta,1);
x_theta = (0:length(y_theta)-1) / new_fs;
% Put into time series table.
theta = ecog;
theta.y{1} = y_theta;
theta.x{1} = x_theta;
theta.fs = new_fs;
theta.ylabel = "Theta RMS (a.u.)";
theta.name = "ECoG theta RMS (5 Hz - 9 Hz)";
% Save.
tr.save_var(theta);

% Calculate Sigma RMS
sigma_band = designfilt('bandpassiir','FilterOrder',ordr, ...
    'HalfPowerFrequency1',10,'HalfPowerFrequency2',16, ...
    'SampleRate',ecog.fs);
y_sigma = filter(sigma_band, ecog.y{1});
% Calculate RMS.
y_sigma = begonia.util.window_transform(y_sigma,window,spacing);
y_sigma = rms(y_sigma,1);
x_sigma = (0:length(y_sigma)-1) / new_fs;
% Put into time series table.
sigma = ecog;
sigma.y{1} = y_sigma;
sigma.x{1} = x_sigma;
sigma.fs = new_fs;
sigma.ylabel = "Sigma RMS (a.u.)";
sigma.name = "ECoG sigma RMS (10 Hz - 16 Hz)";
% Save.
tr.save_var(sigma);

% Calculate theta delta ratio.
theta_ratio = delta;
theta_ratio.y{1} = theta.y{1} ./ (theta.y{1} + delta.y{1});
theta_ratio.ylabel = "Theta / delta RMS ratio";
theta_ratio.name = "Theta / delta RMS ratio";
tr.save_var(theta_ratio);

end

