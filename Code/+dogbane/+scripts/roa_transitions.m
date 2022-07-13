tm.reset_filters();
tm.set_filter('ignored_roa_trial','false');
tm.print_filters();
%%
dogbane.guis.roa_transitions(tm);
%%
roa_trans = dogbane.tables.other.variable_to_table_tseries( ...
    tm,'roa_transitions');
%%
dogbane.table_plots.transitions.roa_transitions_start(roa_trans);
dogbane.table_plots.transitions.roa_transitions_end(roa_trans);

%%
% Make a new table which is a subset of the old table.
roa_sleep_tran = dogbane.table_processing.spesific_sleep_transitions(roa_trans);
roa_sleep_tran.state_transition = roa_sleep_tran.state_previous.*roa_sleep_tran.state;
%%
t = linspace(-30,30,size(roa_sleep_tran.roa_transition_strict_start,2));

output_folder = '~/Desktop/sleep_project/transitions_spesific_sleep/roa_freq';

begonia.plot.trace_with_sem(t, ...
    roa_sleep_tran.roa_transition_strict_start * 60 * 100, ...
    roa_sleep_tran.genotype.*roa_sleep_tran.state_transition, ...
    'output_folder',output_folder, ...
    'y_label','ROA / min / 100um^2', ...
    'x_label','Seconds (s)' ...
    );
%% N
[G,tbl] = findgroups(roa_sleep_tran(:,{'genotype','state_transition'}));
tbl.N_mice = splitapply(@(x)length(unique(x)),roa_sleep_tran.mouse,G);
tbl.N_trials = splitapply(@(x)length(unique(x)),roa_sleep_tran.trial,G);
tbl.N_transitons = splitapply(@length,roa_sleep_tran.trial,G);
tbl

I = ismember(roa_sleep_tran.state_transition,{'nrem is','is rem','is nrem'});
[G,tbl] = findgroups(roa_sleep_tran(I,{'genotype'}));
tbl.N_mice = splitapply(@(x)length(unique(x)),roa_sleep_tran(I,:).mouse,G);
tbl.N_trials = splitapply(@(x)length(unique(x)),roa_sleep_tran(I,:).trial,G);
tbl.N_transitons = splitapply(@length,roa_sleep_tran(I,:).trial,G);
tbl
%% N
[G,tbl] = findgroups(roa_trans(:,{'genotype','state'}));
tbl.N_mice = splitapply(@(x)length(unique(x)),roa_trans.mouse,G);
tbl.N_trials = splitapply(@(x)length(unique(x)),roa_trans.trial,G);
tbl.N_transitons = splitapply(@length,roa_trans.trial,G);
tbl