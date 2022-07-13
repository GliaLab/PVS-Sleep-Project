function roa_proportions(tbl_roa_events)

output_folder = '~/Desktop/sleep_project/roa_proportions/';
begonia.path.make_dirs(output_folder)
%% size
edges = [0,1,10,100,1000,10000,realmax];

[G,genotype,state] = findgroups(tbl_roa_events.genotype,tbl_roa_events.state);

N = splitapply(@(x) histcounts(x,edges),tbl_roa_events.roa_xy_size,G);

tbl = table(genotype,state,N);

N = N ./ sum(N,2) * 100;

file_name = fullfile(output_folder,'roa_size.csv');
writetable(tbl,file_name);

figure;
bar(N,'stacked')

legend({'0-1 um^2','1-10 um ^2','10-100 um ^2','100-1 000 um ^2','1 000-10 000 um ^2','10 000 > um ^2'});
set(gca,'XTickLabels',cellstr(genotype.*state))
set(gca,'XTickLabelRotation',45)
ylim([0,100]);

file_name = fullfile(output_folder,'roa_size.png');
export_fig(file_name);

%% duration
edges = [0,1,10,20,realmax];

[G,genotype,state] = findgroups(tbl_roa_events.genotype,tbl_roa_events.state);

N = splitapply(@(x) histcounts(x,edges),tbl_roa_events.roa_dur,G);

tbl = table(genotype,state,N);

N = N ./ sum(N,2) * 100;

file_name = fullfile(output_folder,'roa_duration.csv');
writetable(tbl,file_name);

figure;
bar(N,'stacked')

legend({'0-1 s','1-10 s','10-20 s','20 > s'});
set(gca,'XTickLabels',cellstr(genotype.*state))
set(gca,'XTickLabelRotation',45)
ylim([0,100]);

file_name = fullfile(output_folder,'roa_duration.png');
export_fig(file_name);

%% size
edges = [0,1,10,100,1000,10000,realmax];

[G,genotype,state] = findgroups(tbl_roa_events.genotype,tbl_roa_events.state);

N = splitapply(@(x) histcounts(x,edges),tbl_roa_events.roa_vol_size,G);

tbl = table(genotype,state,N);

N = N ./ sum(N,2) * 100;

file_name = fullfile(output_folder,'roa_volume.csv');
writetable(tbl,file_name);

figure;
bar(N,'stacked')

legend({'0-1 um^2 * s','1-10 um ^2 * s','10-100 um ^2 * s','100-1 000 um ^2 * s','1 000-10 000 um ^2 * s','10 000 > um ^2 * s'});
set(gca,'XTickLabels',cellstr(genotype.*state))
set(gca,'XTickLabelRotation',45)
ylim([0,100]);

file_name = fullfile(output_folder,'roa_volume.png');
export_fig(file_name);
end

