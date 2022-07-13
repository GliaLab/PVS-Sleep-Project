begonia.logging.set_level(1);
scans = eustoma.get_linescans();

tbl = scans.load_var('pulsatility_in_sleep',[]);
tbl = cat(1,tbl{:});
[~,I] = sort(string(tbl.vessel_name));
tbl = tbl(I,:);
%%
[G,tbl_N] = findgroups(tbl(:,["genotype","state","vessel_type"]));
tbl_N.N_green_samples = splitapply(@(x)sum(~isnan(x)),tbl.pulsatility_green,G);
tbl_N.N_green_trials = splitapply(@(x,y)length(unique(y(~isnan(x)))),tbl.pulsatility_green,tbl.trial_id,G);
tbl_N.N_green_mice = splitapply(@(x,y)length(unique(y(~isnan(x)))),tbl.pulsatility_green,tbl.mouse,G);
tbl_N.N_red_samples = splitapply(@(x)sum(~isnan(x)),tbl.pulsatility_red,G);
tbl_N.N_red_trials = splitapply(@(x,y)length(unique(y(~isnan(x)))),tbl.pulsatility_red,tbl.trial_id,G);
tbl_N.N_red_mice = splitapply(@(x,y)length(unique(y(~isnan(x)))),tbl.pulsatility_red,tbl.mouse,G);
tbl_N


plot_dir = fullfile(eustoma.get_plot_path,'Linescan Pulsatility in Sleep Matlab');
filename = fullfile(plot_dir,"N per genotype.csv");
begonia.path.make_dirs(filename);
writetable(tbl_N,filename);
%%
[G,tbl_N] = findgroups(tbl(:,["mouse","state","vessel_type"]));
tbl_N.N_green_samples = splitapply(@(x)sum(~isnan(x)),tbl.pulsatility_green,G);
tbl_N.N_green_trials = splitapply(@(x,y)length(unique(y(~isnan(x)))),tbl.pulsatility_green,tbl.trial_id,G);
tbl_N.N_red_samples = splitapply(@(x)sum(~isnan(x)),tbl.pulsatility_red,G);
tbl_N.N_red_trials = splitapply(@(x,y)length(unique(y(~isnan(x)))),tbl.pulsatility_red,tbl.trial_id,G);
tbl_N

plot_dir = fullfile(eustoma.get_plot_path,'Linescan Pulsatility in Sleep Matlab');
filename = fullfile(plot_dir,"N per mouse.csv");
begonia.path.make_dirs(filename);
writetable(tbl_N,filename);
%%

g = gramm('x',tbl.state,'y',tbl.pulsatility_green,'color',categorical(tbl.mouse),'subset',~isnan(tbl.pulsatility_green));
g.geom_jitter();
g.facet_grid(categorical(tbl.vessel_type),categorical(tbl.genotype));
g.set_names('x','','y','Vessel wall pulsatility (um)','row','', ...
    'column','', ...
    'color','Mouse');
g.set_title('Vessel Wall Pulsatility (Green channel)');
g.axe_property('TickDir','out','YGrid','on','GridColor',[0.5 0.5 0.5]);
g.coord_flip();
g.draw();
f = gcf;
f.Position(3:4) = [1600,700];

plot_dir = fullfile(eustoma.get_plot_path,'Linescan Pulsatility in Sleep Matlab');
filename = fullfile(plot_dir,"Vessel Wall Pulsatility.png");
begonia.path.make_dirs(filename);
pause(0.5);
warning off
export_fig(f,filename,'-png');
warning on
close(f)
%%

g = gramm('x',tbl.state,'y',tbl.pulsatility_red,'color',categorical(tbl.mouse),'subset',~isnan(tbl.pulsatility_red));
g.geom_jitter();
g.facet_grid(categorical(tbl.vessel_type),categorical(tbl.genotype));
g.set_names('x','','y','Vessel lumen pulsatility (um)','row','', ...
    'column','', ...
    'color','Mouse');
g.set_title('Vessel Lumen Pulsatility (Red channel)');
g.axe_property('TickDir','out','YGrid','on','GridColor',[0.5 0.5 0.5]);
g.coord_flip();
g.draw();
f = gcf;
f.Position(3:4) = [1600,700];

plot_dir = fullfile(eustoma.get_plot_path,'Linescan Pulsatility in Sleep Matlab');
filename = fullfile(plot_dir,"Vessel Lumen Pulsatility.png");
begonia.path.make_dirs(filename);
pause(0.5);
warning off
export_fig(f,filename,'-png');
warning on
close(f)