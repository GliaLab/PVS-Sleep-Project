function param = default_parameters()
param = struct;

% Detection level after highpass filtering the traces with
% astrocyte_sigma_highpass_window_2
param.astrocyte_sigma_detection = 2.5;
% Seconds
param.astrocyte_sigma_highpass_window_1 = 0.25;
% Seconds
param.astrocyte_sigma_highpass_window_2 = 120;
% Seconds
param.astrocyte_sigma_smoothing = param.astrocyte_sigma_highpass_window_1;
% Seconds
param.astrocyte_min_peak_width = 1;
% df/f0
param.astrocyte_min_peak_height = 0.2;
% Seconds
param.astrocyte_max_peak_width = 100;
param.astrocyte_plateau_min_width = 10;
param.astrocyte_plateau_min_ratio = 0.6;

% Detection level after highpass filtering the traces with
% neuron_sigma_highpass_window_2
param.neuron_sigma_detection = 2.0;
% Seconds
param.neuron_sigma_highpass_window_1 = 0.1; 
% Seconds
param.neuron_sigma_highpass_window_2 = 120; 
% Seconds
param.neuron_sigma_smoothing = param.neuron_sigma_highpass_window_1;
% Seconds
param.neuron_min_peak_width = 0.1;
% Seconds
param.neuron_max_peak_width = 10.0;
end

