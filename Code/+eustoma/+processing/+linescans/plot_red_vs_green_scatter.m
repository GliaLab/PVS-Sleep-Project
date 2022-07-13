begonia.logging.set_level(1);
scans = eustoma.get_linescans();

tbl = scans.load_var('diameter_in_episodes',[]);
tbl = cat(1,tbl{:});
[~,I] = sort(string(tbl.vessel_name));
tbl = tbl(I,:);

tbl.mouse = string(tbl.mouse);
tbl.state = string(tbl.state);

I = ismember(tbl.vessel_type, ["Penetrating Arteriole"]);
tbl = tbl(I,:);

%%
f = figure;
g = gramm('x',tbl.diameter_red,'y',tbl.diameter_green,'color',categorical(tbl.state));
g.geom_point();
g.facet_wrap(categorical(tbl.mouse))
g.set_names('x','Endfoot diameter (um)','y','Vessel wall diameter (um)','row','', ...
    'column','Mouse', ...
    'color','State');
% g.set_title('Vessel Wall Pulsatility (Green channel)');
g.axe_property('TickDir','out','YGrid','on','XGrid','on','GridColor',[0.5 0.5 0.5]);
g.draw();
f.Position(3:4) = [1400,1000];
%%
f = figure;
g = gramm('x',tbl.diameter_peri,'y',tbl.diameter_green,'color',categorical(tbl.state));
g.geom_point();
g.facet_wrap(categorical(tbl.mouse))
g.set_names('x','PVS (um)','y','Vessel wall diameter (um)','row','', ...
    'column','Mouse', ...
    'color','State');
% g.set_title('Vessel Wall Pulsatility (Green channel)');
g.axe_property('TickDir','out','YGrid','on','XGrid','on','GridColor',[0.5 0.5 0.5]);
g.draw();
f.Position(3:4) = [1400,1000];
%%

% plot_dir = fullfile(eustoma.get_plot_path,'Linescan Pulsatility in Sleep Matlab');
% filename = fullfile(plot_dir,"Vessel Wall Pulsatility.png");
% begonia.path.make_dirs(filename);
% pause(0.5);
% warning off
% export_fig(f,filename,'-png');
% warning on
% close(f)
