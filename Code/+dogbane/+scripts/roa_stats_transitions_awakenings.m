tm.reset_filters();
tm.set_filter('ignored_roa_trial','false');
tm.set_filter('has_awakening','true');
tm.print_filters();
%%
dogbane.guis.roa_transitions(tm);
%%
tbl = dogbane.tables.other.variable_to_table_tseries( ...
    tm,'roa_stats_transitions_awakenings');
%%
% dogbane.table_plots.transitions.roa_size_transitions(size_vol_transitions);
% dogbane.table_plots.transitions.roa_volume_transitions(size_vol_transitions);
%%
fs = 30;
t = -30*fs:30*fs;
t = t / fs;

output_folder = '~/Desktop/sleep_project/transitions/awakenings_roa_size_transitions';
begonia.plot.trace_with_sem(t,tbl.roa_size_transition,tbl.genotype .* tbl.state, ...
    'output_folder',output_folder, ...
    'plot_callback',@style_size_plot);
close all
%%
fs = 30;
t = -30*fs:30*fs;
t = t / fs;

output_folder = '~/Desktop/sleep_project/transitions/awakenings_roa_dur_transitions';
begonia.plot.trace_with_sem(t,tbl.roa_duration_transition,tbl.genotype .* tbl.state, ...
    'output_folder',output_folder, ...
    'plot_callback',@style_dur_plot);
close all
%%
function style_size_plot(f,a,category)
ylabel('Mean ROA size (um^2)');
xlabel('Time since transition (seconds)');
end


function style_dur_plot(f,a,category)
ylabel('Mean ROA duration (s)');
xlabel('Time since transition (seconds)');
end