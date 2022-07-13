function plot_roa_traces(trial)
ts = trial.tseries;
tr = trial.rec_rig_trial;


freq = ts.load_var('highpass_thresh_roa_frequency_trace');
dens = ts.load_var('highpass_thresh_roa_density_trace');

freq = reshape(freq,1,[]);
dens = reshape(dens,1,[]);
t = (0:length(freq)-1) * ts.dt;

f = figure;

ax(1) = subplot(2,1,1);
plot(t,freq);
title('ROA frequency');

ax(2) = subplot(2,1,2);
plot(t,dens);
title('ROA density');

linkaxes(ax,'x');
end

