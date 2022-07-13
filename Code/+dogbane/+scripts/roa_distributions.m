tm.reset_filters();
tm.set_filter('ignored_roa_trial','false');
tm.print_filters();
%%
% dogbane.guis.roa(tm);
% dogbane.guis.states(tm);
dogbane.guis.roa_measurements(tm);
%%
roa_events = dogbane.tables.roa.roa_events(tm);
%%
dogbane.table_plots.roa.roa_2d_histogram(roa_events);
close all
%%
dogbane.table_plots.roa.roa_proportions(roa_events);
%%
roa_dist = dogbane.tables.other.variable_to_table_tseries(tm,'roa_distributions');

dogbane.table_plots.roa.roa_size_distribution_freq(roa_dist);
dogbane.table_plots.roa.roa_duration_distribution_freq(roa_dist);
dogbane.table_plots.roa.roa_volume_distribution_freq(roa_dist);

%%