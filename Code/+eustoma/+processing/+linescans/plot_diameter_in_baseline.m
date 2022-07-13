begonia.logging.set_level(1);
scans = eustoma.get_linescans();

tbl = scans.load_var('diameter_in_episodes',[]);
tbl = cat(1,tbl{:});
[~,I] = sort(string(tbl.vessel_name));
tbl = tbl(I,:);

tbl(tbl.vessel_type == "Unknown",:) = [];
tbl(tbl.vessel_type == "Ignore",:) = [];

I = tbl.state == "Vessel Baseline";
tbl = tbl(I,:);
%%
[G,tbl_N] = findgroups(tbl(:,["genotype","state","vessel_type"]));
tbl_N.N_green_samples = splitapply(@(x)sum(~isnan(x)),tbl.diameter_green,G);
tbl_N.N_green_trials = splitapply(@(x,y)length(unique(y(~isnan(x)))),tbl.diameter_green,tbl.trial_id,G);
tbl_N.N_green_mice = splitapply(@(x,y)length(unique(y(~isnan(x)))),tbl.diameter_green,tbl.mouse,G);
tbl_N.N_red_samples = splitapply(@(x)sum(~isnan(x)),tbl.diameter_red,G);
tbl_N.N_red_trials = splitapply(@(x,y)length(unique(y(~isnan(x)))),tbl.diameter_red,tbl.trial_id,G);
tbl_N.N_red_mice = splitapply(@(x,y)length(unique(y(~isnan(x)))),tbl.diameter_red,tbl.mouse,G);
tbl_N


plot_dir = fullfile(eustoma.get_plot_path,'Linescan Diameter in Episodes');
filename = fullfile(plot_dir,"N per genotype.csv");
begonia.path.make_dirs(filename);
writetable(tbl_N,filename);
%%
[G,tbl_N] = findgroups(tbl(:,["mouse","state","vessel_type"]));
tbl_N.N_green_samples = splitapply(@(x)sum(~isnan(x)),tbl.diameter_green,G);
tbl_N.N_green_trials = splitapply(@(x,y)length(unique(y(~isnan(x)))),tbl.diameter_green,tbl.trial_id,G);
tbl_N.N_red_samples = splitapply(@(x)sum(~isnan(x)),tbl.diameter_red,G);
tbl_N.N_red_trials = splitapply(@(x,y)length(unique(y(~isnan(x)))),tbl.diameter_red,tbl.trial_id,G);
tbl_N

plot_dir = fullfile(eustoma.get_plot_path,'Linescan Diameter in Episodes');
filename = fullfile(plot_dir,"N per mouse.csv");
begonia.path.make_dirs(filename);
writetable(tbl_N,filename);
%%

tbl = stack(tbl,["diameter_green","diameter_red","diameter_peri"], ...
    "NewDataVariableName","diameter", ...
    "IndexVariableName","vessel_structure");
tbl.vessel_structure = renamecats(categorical(tbl.vessel_structure), ...
    ["diameter_green","diameter_red","diameter_peri"], ...
    ["Endfoot wall","Lumen","PVS"]);
%%
g = gramm('x',categorical(tbl.vessel_type),'y',tbl.diameter,'subset', ~isnan(tbl.diameter), ...
    'color',categorical(tbl.mouse));
g.geom_jitter();
g.facet_grid(categorical(tbl.genotype),categorical(tbl.vessel_structure));
g.set_names('x','','y','Diameter (um)', 'row','','column','');
g.set_title('Baseline Diameter');
g.axe_property('TickDir','out','YGrid','on','GridColor',[0.5 0.5 0.5]);
g.draw();
f = gcf;
f.Position(3:4) = [1600,700];

plot_dir = fullfile(eustoma.get_plot_path,'Linescan Diameter in Episodes');
filename = fullfile(plot_dir,"Diameter genotype strip.png");
begonia.path.make_dirs(filename);
pause(2);
warning off
saveas(f,filename,'png');
warning on
close(f)
%%
g = gramm('x',categorical(tbl.mouse),'y',tbl.diameter,'subset', ~isnan(tbl.diameter));
g.geom_jitter();
g.facet_grid(categorical(tbl.vessel_type),categorical(tbl.vessel_structure));
g.set_names('x','','y','Diameter (um)', 'row','','column','');
g.set_title('Baseline Diameter');
g.axe_property('TickDir','out','YGrid','on','GridColor',[0.5 0.5 0.5]);
g.axe_property('XTickLabelRotation',45);
g.draw();
f = gcf;
f.Position(3:4) = [1600,700];

plot_dir = fullfile(eustoma.get_plot_path,'Linescan Diameter in Episodes');
filename = fullfile(plot_dir,"Diameter mouse strip.png");
begonia.path.make_dirs(filename);
pause(2);
warning off
saveas(f,filename,'png');
warning on
close(f)
%%
g = gramm('x',categorical(tbl.vessel_type),'y',tbl.diameter,'subset', ~isnan(tbl.diameter));
g.stat_boxplot();
g.facet_grid(categorical(tbl.genotype),categorical(tbl.vessel_structure));
g.set_names('x','','y','Diameter (um)', 'row','','column','');
g.set_title('Baseline Diameter');
g.axe_property('TickDir','out','YGrid','on','GridColor',[0.5 0.5 0.5]);
g.draw();
f = gcf;
f.Position(3:4) = [1600,700];

plot_dir = fullfile(eustoma.get_plot_path,'Linescan Diameter in Episodes');
filename = fullfile(plot_dir,"Diameter genotype box.png");
begonia.path.make_dirs(filename);
pause(2);
warning off
saveas(f,filename,'png');
warning on
close(f)