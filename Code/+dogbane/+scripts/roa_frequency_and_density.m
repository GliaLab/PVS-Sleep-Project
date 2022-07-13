dogbane.guis.roa(tm);
%%
tbl_roa = dogbane.tables.roa.roa_per_trial_and_state(tm);
tbl_roa(tbl_roa.state == 'undefined',:) = [];
%%
dogbane.table_plots.roa.frequency_per_state(tbl_roa);
% dogbane.table_plots.roa.density_per_state(tbl_roa);