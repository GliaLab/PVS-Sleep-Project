%%
tm.reset_filters();
tm.set_filter('ignored_roa_trial','false');
tm.print_filters();
%%
dogbane.guis.roa_transitions(tm);
%%
tbl = dogbane.tables.other.variable_to_table_tseries( ...
    tm,'roa_stats_transitions');
%%
% dogbane.table_plots.transitions.roa_size_transitions(tbl);
% dogbane.table_plots.transitions.roa_volume_transitions(tbl);
dogbane.table_plots.transitions.roa_duration_transitions(tbl);
