
tbl_path = fullfile(eustoma.get_plot_path,'Linescan Tables','Diameter in Episodes.csv');

tbl = readtable(tbl_path);

%%

f = figure;
scatter(tbl.diameter_peri, tbl.diameter_green - tbl.diameter_red, '.')
ylabel('diameter\_green - diameter\_red');
xlabel('diameter\_pvs');

filename = fullfile(eustoma.get_plot_path,'Linescan diameter check.png');

exportgraphics(f, filename);
close(f);
