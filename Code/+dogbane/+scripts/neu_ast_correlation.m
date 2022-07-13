tm.reset_filters();
tm.print_filters();
%%
dogbane.guis.neu_ast_cor(tm);
%%
neu_ast = dogbane.tables.other.variable_to_table_tseries(tm,'correlate_gliopil_traces');
I = isnan(neu_ast.roa_neu_corr);
neu_ast(I,:) = [];
%%


