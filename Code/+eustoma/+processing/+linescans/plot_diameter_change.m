begonia.logging.set_level(1);
scans = eustoma.get_linescans();

tbl = scans.load_var('diameter_in_episodes',[]);
tbl = cat(1,tbl{:});
[~,I] = sort(string(tbl.vessel_name));
tbl = tbl(I,:);

tbl.mouse = string(tbl.mouse);
tbl.state = string(tbl.state);

I = ismember(tbl.vessel_type, ["Penetrating Arteriole","Pial Artery","Vein"]);
tbl = tbl(I,:);

tbl(tbl.state == "Vessel Baseline",:) = [];

sws = tbl(ismember(tbl.state,["NREM","IS"]),:);
sws.state(:) = "SWS";

tbl = cat(1,tbl,sws);
%%
[G,tbl_N] = findgroups(tbl(:,["genotype","state","vessel_type"]));
tbl_N.N_green_samples = splitapply(@(x)sum(~isnan(x)),tbl.diameter_green,G);
tbl_N.N_green_trials = splitapply(@(x,y)length(unique(y(~isnan(x)))),tbl.diameter_change_green,tbl.trial_id,G);
tbl_N.N_green_mice = splitapply(@(x,y)length(unique(y(~isnan(x)))),tbl.diameter_change_green,tbl.mouse,G);
tbl_N.N_red_samples = splitapply(@(x)sum(~isnan(x)),tbl.diameter_change_red,G);
tbl_N.N_red_trials = splitapply(@(x,y)length(unique(y(~isnan(x)))),tbl.diameter_change_red,tbl.trial_id,G);
tbl_N.N_red_mice = splitapply(@(x,y)length(unique(y(~isnan(x)))),tbl.diameter_change_red,tbl.mouse,G);
tbl_N.N_peri_samples = splitapply(@(x)sum(~isnan(x)),tbl.diameter_change_peri,G);
tbl_N.N_peri_trials = splitapply(@(x,y)length(unique(y(~isnan(x)))),tbl.diameter_change_peri,tbl.trial_id,G);
tbl_N.N_peri_mice = splitapply(@(x,y)length(unique(y(~isnan(x)))),tbl.diameter_change_peri,tbl.mouse,G);
tbl_N

plot_dir = fullfile(eustoma.get_plot_path,"Linescan Diameter Change");
filename = fullfile(plot_dir,"N per genotype.csv");
begonia.path.make_dirs(filename);
writetable(tbl_N,filename);
%%
[G,tbl_N] = findgroups(tbl(:,["mouse","state","vessel_type"]));
tbl_N.N_green_samples = splitapply(@(x)sum(~isnan(x)),tbl.diameter_change_green,G);
tbl_N.N_green_trials = splitapply(@(x,y)length(unique(y(~isnan(x)))),tbl.diameter_change_green,tbl.trial_id,G);
tbl_N.N_red_samples = splitapply(@(x)sum(~isnan(x)),tbl.diameter_change_red,G);
tbl_N.N_red_trials = splitapply(@(x,y)length(unique(y(~isnan(x)))),tbl.diameter_change_red,tbl.trial_id,G);
tbl_N.N_peri_samples = splitapply(@(x)sum(~isnan(x)),tbl.diameter_change_peri,G);
tbl_N.N_peri_trials = splitapply(@(x,y)length(unique(y(~isnan(x)))),tbl.diameter_change_peri,tbl.trial_id,G);
tbl_N

plot_dir = fullfile(eustoma.get_plot_path,"Linescan Diameter Change");
filename = fullfile(plot_dir,"N per mouse.csv");
begonia.path.make_dirs(filename);
writetable(tbl_N,filename);
%% red 1
g = gramm('y',tbl.diameter_change_red,'x',categorical(tbl.state),'color',categorical(tbl.mouse));
g.geom_jitter();
g.facet_grid(categorical(tbl.genotype),categorical(tbl.vessel_type));
g.set_names('x','','y','Change from baseline (um)', 'row','','column','');
g.set_title('Lumen diameter change from baseline');
g.axe_property('TickDir','out','YGrid','on','GridColor',[0.5 0.5 0.5]);
g.draw();
f = gcf;
f.Position = [10,50,2000,1000];

filename = fullfile(eustoma.get_plot_path,"Linescan Diameter Change","Lumen diameter change from baseline");
begonia.path.make_dirs(filename);
exportgraphics(f,filename+".png");
close(f)
%% red 2
g = gramm('y',tbl.diameter_ratio_change_red *100,'x',categorical(tbl.state),'color',categorical(tbl.mouse));
g.geom_jitter();
g.facet_grid(categorical(tbl.genotype),categorical(tbl.vessel_type));
g.set_names('x','','y','Change from baseline (%)', 'row','','column','');
g.set_title('Lumen diameter percent change from baseline');
g.axe_property('TickDir','out','YGrid','on','GridColor',[0.5 0.5 0.5]);
g.draw();
f = gcf;
f.Position = [10,50,2000,1000];

filename = fullfile(eustoma.get_plot_path,"Linescan Diameter Change","Lumen diameter percent change from baseline");
begonia.path.make_dirs(filename);
exportgraphics(f,filename+".png");
close(f)
%% red 3
g = gramm('y',tbl.area_change_red,'x',categorical(tbl.state),'color',categorical(tbl.mouse));
g.geom_jitter();
g.facet_grid(categorical(tbl.genotype),categorical(tbl.vessel_type));
g.set_names('x','','y','Change from baseline (um^2)', 'row','','column','');
g.set_title('Lumen area change from baseline');
g.axe_property('TickDir','out','YGrid','on','GridColor',[0.5 0.5 0.5]);
g.draw();
f = gcf;
f.Position = [10,50,2000,1000];

filename = fullfile(eustoma.get_plot_path,"Linescan Diameter Change","Lumen area change from baseline");
begonia.path.make_dirs(filename);
exportgraphics(f,filename+".png");
close(f)
%% red 4
g = gramm('y',tbl.area_ratio_change_red *100,'x',categorical(tbl.state),'color',categorical(tbl.mouse));
g.geom_jitter();
g.facet_grid(categorical(tbl.genotype),categorical(tbl.vessel_type));
g.set_names('x','','y','Change from baseline (%)', 'row','','column','');
g.set_title('Lumen area percent change from baseline');
g.axe_property('TickDir','out','YGrid','on','GridColor',[0.5 0.5 0.5]);
g.draw();
f = gcf;
f.Position = [10,50,2000,1000];

filename = fullfile(eustoma.get_plot_path,"Linescan Diameter Change","Lumen area percent change from baseline");
begonia.path.make_dirs(filename);
exportgraphics(f,filename+".png");
close(f)
%% green 1
g = gramm('y',tbl.diameter_change_green,'x',categorical(tbl.state),'color',categorical(tbl.mouse));
g.geom_jitter();
g.facet_grid(categorical(tbl.genotype),categorical(tbl.vessel_type));
g.set_names('x','','y','Change from baseline (um)', 'row','','column','');
g.set_title('Endfoot diameter change from baseline');
g.axe_property('TickDir','out','YGrid','on','GridColor',[0.5 0.5 0.5]);
g.draw();
f = gcf;
f.Position = [10,50,2000,1000];

filename = fullfile(eustoma.get_plot_path,"Linescan Diameter Change","Endfoot diameter change from baseline");
begonia.path.make_dirs(filename);
exportgraphics(f,filename+".png");
close(f)
%% green 2
g = gramm('y',tbl.diameter_ratio_change_green *100,'x',categorical(tbl.state),'color',categorical(tbl.mouse));
g.geom_jitter();
g.facet_grid(categorical(tbl.genotype),categorical(tbl.vessel_type));
g.set_names('x','','y','Change from baseline (%)', 'row','','column','');
g.set_title('Endfoot diameter percent change from baseline');
g.axe_property('TickDir','out','YGrid','on','GridColor',[0.5 0.5 0.5]);
g.draw();
f = gcf;
f.Position = [10,50,2000,1000];

filename = fullfile(eustoma.get_plot_path,"Linescan Diameter Change","Endfoot diameter percent change from baseline");
begonia.path.make_dirs(filename);
exportgraphics(f,filename+".png");
close(f)
%% green 3
g = gramm('y',tbl.area_change_green,'x',categorical(tbl.state),'color',categorical(tbl.mouse));
g.geom_jitter();
g.facet_grid(categorical(tbl.genotype),categorical(tbl.vessel_type));
g.set_names('x','','y','Change from baseline (um^2)', 'row','','column','');
g.set_title('Endfoot area change from baseline');
g.axe_property('TickDir','out','YGrid','on','GridColor',[0.5 0.5 0.5]);
g.draw();
f = gcf;
f.Position = [10,50,2000,1000];

filename = fullfile(eustoma.get_plot_path,"Linescan Diameter Change","Endfoot area change from baseline");
begonia.path.make_dirs(filename);
exportgraphics(f,filename+".png");
close(f)
%% green 4
g = gramm('y',tbl.area_ratio_change_green *100,'x',categorical(tbl.state),'color',categorical(tbl.mouse));
g.geom_jitter();
g.facet_grid(categorical(tbl.genotype),categorical(tbl.vessel_type));
g.set_names('x','','y','Change from baseline (%)', 'row','','column','');
g.set_title('Endfoot area percent change from baseline');
g.axe_property('TickDir','out','YGrid','on','GridColor',[0.5 0.5 0.5]);
g.draw();
f = gcf;
f.Position = [10,50,2000,1000];

filename = fullfile(eustoma.get_plot_path,"Linescan Diameter Change","Endfoot area percent change from baseline");
begonia.path.make_dirs(filename);
exportgraphics(f,filename+".png");
close(f)
%% peri 1
g = gramm('y',tbl.diameter_change_peri,'x',categorical(tbl.state),'color',categorical(tbl.mouse));
g.geom_jitter();
g.facet_grid(categorical(tbl.genotype),categorical(tbl.vessel_type));
g.set_names('x','','y','Change from baseline (um)', 'row','','column','');
g.set_title('PVS change from baseline');
g.axe_property('TickDir','out','YGrid','on','GridColor',[0.5 0.5 0.5]);
g.draw();
f = gcf;
f.Position = [10,50,2000,1000];

filename = fullfile(eustoma.get_plot_path,"Linescan Diameter Change","PVS change from baseline");
begonia.path.make_dirs(filename);
exportgraphics(f,filename+".png");
close(f)
%% peri 2
g = gramm('y',tbl.diameter_ratio_change_peri *100,'x',categorical(tbl.state),'color',categorical(tbl.mouse));
g.geom_jitter();
g.facet_grid(categorical(tbl.genotype),categorical(tbl.vessel_type));
g.set_names('x','','y','Change from baseline (%)', 'row','','column','');
g.set_title('PVS percent change from baseline');
g.axe_property('TickDir','out','YGrid','on','GridColor',[0.5 0.5 0.5]);
g.draw();
f = gcf;
f.Position = [10,50,2000,1000];

filename = fullfile(eustoma.get_plot_path,"Linescan Diameter Change","PVS percent change from baseline");
begonia.path.make_dirs(filename);
exportgraphics(f,filename+".png");
close(f)
%% peri 3
g = gramm('y',tbl.area_change_peri,'x',categorical(tbl.state),'color',categorical(tbl.mouse));
g.geom_jitter();
g.facet_grid(categorical(tbl.genotype),categorical(tbl.vessel_type));
g.set_names('x','','y','Change from baseline (um^2)', 'row','','column','');
g.set_title('PVS area change from baseline');
g.axe_property('TickDir','out','YGrid','on','GridColor',[0.5 0.5 0.5]);
g.draw();
f = gcf;
f.Position = [10,50,2000,1000];

filename = fullfile(eustoma.get_plot_path,"Linescan Diameter Change","PVS area change from baseline");
begonia.path.make_dirs(filename);
exportgraphics(f,filename+".png");
close(f)
%% peri 4
g = gramm('y',tbl.area_ratio_change_peri *100,'x',categorical(tbl.state),'color',categorical(tbl.mouse));
g.geom_jitter();
g.facet_grid(categorical(tbl.genotype),categorical(tbl.vessel_type));
g.set_names('x','','y','Change from baseline (%)', 'row','','column','');
g.set_title('PVS area percent change from baseline');
g.axe_property('TickDir','out','YGrid','on','GridColor',[0.5 0.5 0.5]);
g.draw();
f = gcf;
f.Position = [10,50,2000,1000];

filename = fullfile(eustoma.get_plot_path,"Linescan Diameter Change","PVS area percent change from baseline");
begonia.path.make_dirs(filename);
exportgraphics(f,filename+".png");
close(f)