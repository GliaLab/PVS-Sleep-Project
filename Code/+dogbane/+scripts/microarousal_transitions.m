tm.reset_filters();
tm.set_filter('ignored_roa_trial','false');
tm.print_filters();
%%
% dogbane.guis.camera(tm);
% dogbane.guis.states(tm);
% dogbane.guis.roa_transitions(tm);
%%
micro_transitions = dogbane.tables.other.variable_to_table_tseries( ...
    tm,'microarousal_transitions');

%%
dogbane.table_plots.transitions.microarousal_transitions(micro_transitions);
%%
[G,tbl] = findgroups(micro_transitions(:,{'genotype'}));
tbl.N_mice = splitapply(@(x)length(unique(x)),micro_transitions.mouse,G);
tbl.N_trials = splitapply(@(x)length(unique(x)),micro_transitions.trial,G);
tbl.N_episodes = splitapply(@length,micro_transitions.trial,G);
tbl