tm.reset_filters();
tm.set_filter('ignored_roa_trial','false');
tm.print_filters();
%%
dogbane.guis.camera(tm);
%%
camera_transitions = dogbane.tables.other.variable_to_table_rec_rig( ...
    tm,'whisker_wheel_transitions');
%%
% Make a new table which is a subset of the old table.
camera_sleep_trans = dogbane.table_processing.spesific_sleep_transitions(camera_transitions);
%%
t = linspace(-30,30,size(camera_transitions.whisking,2));

output_folder = '~/Desktop/sleep_project/transitions_spesific_sleep/whisking';

begonia.plot.trace_with_sem(t, ...
    camera_sleep_trans.whisking_strict, ...
    camera_sleep_trans.genotype.*camera_sleep_trans.state_previous.*camera_sleep_trans.state, ...
    'output_folder',output_folder, ...
    'y_label','Whisking (a.u.)', ...
    'x_label','Seconds (s)' ...
    );

%%
t = linspace(-30,30,size(camera_transitions.wheel,2));

output_folder = '~/Desktop/sleep_project/transitions_spesific_sleep/wheel';

begonia.plot.trace_with_sem(t, ...
    camera_sleep_trans.wheel_strict, ...
    camera_sleep_trans.genotype.*camera_sleep_trans.state_previous.*camera_sleep_trans.state, ...
    'output_folder',output_folder, ...
    'y_label','Wheel (a.u.)', ...
    'x_label','Seconds (s)' ...
    );