rr = eustoma.get_endfoot_recrigs();

vesdist = begonia.data_management.var2table(rr,'vesdist_per_ep');
vesdist.state = reordercats(vesdist.state,{'Locomotion','Whisking','Quiet','NREM','IS','REM'});
vesdist = sortrows(vesdist,'state');

begonia.logging.set_level(1);
%%
f = figure;
f.Position(3:4) = [1000,600];

vesdist.experiment_num = yucca.util.label_subgroups(vesdist.mouse,vesdist.experiment);

g = gramm('x',vesdist.state,'y',vesdist.diff_peri,'color',vesdist.experiment_num, ...
    'subset',vesdist.vessel_type == 'Artery');
g.geom_jitter();
g.set_order_options('x',0);
g.facet_wrap(vesdist.mouse,'ncols',2);
g.set_names('x','','y','Change from Baseline (um)', ...
    'column','Mouse', ...
    'color','Experiment');
g.set_title('Artery Perivascular Change from Baseline');
g.draw();

path = fullfile(eustoma.get_plot_path,'Endfeet Vesdist Overview');
begonia.path.make_dirs([path,filesep]);
warning off
g.export('file_name','Artery Perivascular Width Change.png', ...
    'export_path',path,'file_type','png');
warning on
close(f);
%%
f = figure;
f.Position(3:4) = [1000,600];

vesdist.experiment_num = yucca.util.label_subgroups(vesdist.mouse,vesdist.experiment);

g = gramm('x',vesdist.state,'y',vesdist.diff_peri,'color',vesdist.experiment_num, ...
    'subset',vesdist.vessel_type == 'Vein');
g.geom_jitter();
g.set_order_options('x',0);
g.facet_wrap(vesdist.mouse,'ncols',2);
g.set_names('x','','y','Change from Baseline (um)', ...
    'column','Mouse', ...
    'color','Experiment');
g.set_title('Vein Perivascular Change from Baseline');
g.draw();

path = fullfile(eustoma.get_plot_path,'Endfeet Vesdist Overview');
begonia.path.make_dirs([path,filesep]);
warning off
g.export('file_name','Vein Perivascular Width Change.png', ...
    'export_path',path,'file_type','png');
warning on
close(f);
%%
f = figure;
f.Position(3:4) = [1000,600];

vesdist.experiment_num = yucca.util.label_subgroups(vesdist.mouse,vesdist.experiment);

g = gramm('x',vesdist.state,'y',vesdist.diff_endfoot,'color',vesdist.experiment_num, ...
    'subset',vesdist.vessel_type == 'Artery');
g.geom_jitter();
g.set_order_options('x',0);
g.facet_wrap(vesdist.mouse,'ncols',2);
g.set_names('x','','y','Change from Baseline (um)', ...
    'column','Mouse', ...
    'color','Experiment');
g.set_title('Artery Endfoot Tube Change from Baseline');
g.draw();

path = fullfile(eustoma.get_plot_path,'Endfeet Vesdist Overview');
begonia.path.make_dirs([path,filesep]);
warning off
g.export('file_name','Artery Endfoot Diameter Change.png', ...
    'export_path',path,'file_type','png');
warning on
close(f);
%%
f = figure;
f.Position(3:4) = [1000,600];

vesdist.experiment_num = yucca.util.label_subgroups(vesdist.mouse,vesdist.experiment);

g = gramm('x',vesdist.state,'y',vesdist.diff_endfoot,'color',vesdist.experiment_num, ...
    'subset',vesdist.vessel_type == 'Vein');
g.geom_jitter();
g.set_order_options('x',0);
g.facet_wrap(vesdist.mouse,'ncols',2);
g.set_names('x','','y','Change from Baseline (um)', ...
    'column','Mouse', ...
    'color','Experiment');
g.set_title('Vein Endfoot Tube Change from Baseline');
g.draw();

path = fullfile(eustoma.get_plot_path,'Endfeet Vesdist Overview');
begonia.path.make_dirs([path,filesep]);
warning off
g.export('file_name','Vein Endfoot Diameter Change.png', ...
    'export_path',path,'file_type','png');
warning on
close(f);
%%
f = figure;
f.Position(3:4) = [1000,600];

vesdist.experiment_num = yucca.util.label_subgroups(vesdist.mouse,vesdist.experiment);

g = gramm('x',vesdist.state,'y',vesdist.diff_lumen,'color',vesdist.experiment_num, ...
    'subset',vesdist.vessel_type == 'Artery');
g.geom_jitter();
g.set_order_options('x',0);
g.facet_wrap(vesdist.mouse,'ncols',2);
g.set_names('x','','y','Change from Baseline (um)', ...
    'column','Mouse', ...
    'color','Experiment');
g.set_title('Artery Lumen Change from Baseline');
g.draw();

path = fullfile(eustoma.get_plot_path,'Endfeet Vesdist Overview');
begonia.path.make_dirs([path,filesep]);
warning off
g.export('file_name','Artery Lumen Diameter Change.png', ...
    'export_path',path,'file_type','png');
warning on
close(f);
%%
f = figure;
f.Position(3:4) = [1000,600];

vesdist.experiment_num = yucca.util.label_subgroups(vesdist.mouse,vesdist.experiment);

g = gramm('x',vesdist.state,'y',vesdist.diff_lumen,'color',vesdist.experiment_num, ...
    'subset',vesdist.vessel_type == 'Vein');
g.geom_jitter();
g.set_order_options('x',0);
g.facet_wrap(vesdist.mouse,'ncols',2);
g.set_names('x','','y','Change from Baseline (um)', ...
    'column','Mouse', ...
    'color','Experiment');
g.set_title('Vein Lumen Change from Baseline');
g.draw();

path = fullfile(eustoma.get_plot_path,'Endfeet Vesdist Overview');
begonia.path.make_dirs([path,filesep]);
warning off
g.export('file_name','Vein Lumen Diameter Change.png', ...
    'export_path',path,'file_type','png');
warning on
close(f);
%% Area difference
f = figure;
f.Position(3:4) = [1000,600];

vesdist.experiment_num = yucca.util.label_subgroups(vesdist.mouse,vesdist.experiment);

g = gramm('x',vesdist.state,'y',vesdist.area_diff_peri,'color',vesdist.experiment_num, ...
    'subset',vesdist.vessel_type == 'Artery');
g.geom_jitter();
g.set_order_options('x',0);
g.facet_wrap(vesdist.mouse,'ncols',2);
g.set_names('x','','y','Change from Baseline (um^2)', ...
    'column','Mouse', ...
    'color','Experiment');
g.set_title('Artery Perivascular Area Change from Baseline');
g.draw();

path = fullfile(eustoma.get_plot_path,'Endfeet Vesdist Overview');
begonia.path.make_dirs([path,filesep]);
warning off
g.export('file_name','Artery Perivascular Area Change.png', ...
    'export_path',path,'file_type','png');
warning on
close(f);
%% Area difference
f = figure;
f.Position(3:4) = [1000,600];

vesdist.experiment_num = yucca.util.label_subgroups(vesdist.mouse,vesdist.experiment);

g = gramm('x',vesdist.state,'y',vesdist.area_diff_peri,'color',vesdist.experiment_num, ...
    'subset',vesdist.vessel_type == 'Vein');
g.geom_jitter();
g.set_order_options('x',0);
g.facet_wrap(vesdist.mouse,'ncols',2);
g.set_names('x','','y','Change from Baseline (um^2)', ...
    'column','Mouse', ...
    'color','Experiment');
g.set_title('Vein Perivascular Area Change from Baseline');
g.draw();

path = fullfile(eustoma.get_plot_path,'Endfeet Vesdist Overview');
begonia.path.make_dirs([path,filesep]);
warning off
g.export('file_name','Vein Perivascular Area Change.png', ...
    'export_path',path,'file_type','png');
warning on
close(f);