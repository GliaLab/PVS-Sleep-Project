function roa_vs_aqua_freq(trial)
tr = trial.rec_rig_trial;
ts = trial.tseries;

aqua_data = ts.load_var('aqua_data');

merged_frames = 10;

aqua_freq = aqua_data.frequency_trace / aqua_data.fov * aqua_data.fs;

roa_freq = ts.load_var('highpass_thresh_roa_frequency_trace');
roa_freq = begonia.util.stepping_window(roa_freq,merged_frames);
roa_freq = mean(roa_freq,1);

shortest = min(length(aqua_freq),length(roa_freq));

t = (0:shortest-1)/aqua_data.fs;

roa_freq = roa_freq(1:shortest) * 60 * 100;
aqua_freq = aqua_freq(1:shortest) * 60 * 100;


states = tr.load_var('states');
states_fs = states.states_fs;
states = states.states_trace;

states_t = 0:length(states)-1;
states_t = states_t/states_fs;

state_names = categories(states);
state_names_long = alyssum.constants.state_names_short2long(state_names);
state_colors = alyssum.constants.state_names_short2colors(state_names);


figure;
ax(1) = subplot(4,1,1:3);

hold on
plot(t,roa_freq,'DisplayName','ROA');
plot(t,aqua_freq,'DisplayName','aqua');

legend

ylabel('Events / min / 100 um^2');
set(gca,'FontSize',20);


ax(2) = subplot(4,1,4);
begonia.stage_functions.plot_stages( ...
    states, ...
    states_t, ...
    0, ...
    1, ...
    state_names, ...
    state_colors);
begonia.stage_functions.plot_legend(state_colors,state_names_long)
ylim([0,1])
xlabel('Seconds');

set(gca,'FontSize',20);

linkaxes(ax,'x');
xlim([states_t(1),states_t(end)]);

end

