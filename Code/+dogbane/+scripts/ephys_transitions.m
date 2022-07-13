tm.reset_filters();
tm.set_filter('ignored_roa_trial','false');
tm.print_filters();
%%
% dogbane.guis.ephys(tm);
%%
ephys_trans = dogbane.tables.other.variable_to_table_rec_rig( ...
    tm,'eeg_emg_transitions');
%%
% Make a new table which is a subset of the old table.
ephys_sleep_trans = dogbane.table_processing.spesific_sleep_transitions(ephys_trans);
%%
t = linspace(-30,30,size(ephys_sleep_trans.eeg_strict,2));

output_folder = '~/Desktop/sleep_project/transitions_spesific_sleep/eeg';

begonia.plot.trace_with_sem(t, ...
    ephys_sleep_trans.eeg_strict, ...
    ephys_sleep_trans.genotype.*ephys_sleep_trans.state_previous.*ephys_sleep_trans.state, ...
    'output_folder',output_folder, ...
    'y_label','EEG power (1-15) Hz', ...
    'x_label','Seconds (s)' ...
    );

%%
t = linspace(-30,30,size(ephys_sleep_trans.emg_strict,2));

output_folder = '~/Desktop/sleep_project/transitions_spesific_sleep/emg';

begonia.plot.trace_with_sem(t, ...
    ephys_sleep_trans.emg_strict, ...
    ephys_sleep_trans.genotype.*ephys_sleep_trans.state_previous.*ephys_sleep_trans.state, ...
    'output_folder',output_folder, ...
    'y_label','Abs. EMG', ...
    'x_label','Seconds (s)' ...
    );