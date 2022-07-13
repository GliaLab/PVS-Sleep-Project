begonia.logging.set_level(1);
scans = eustoma.get_linescans();

tbl = scans.load_var('diameter_in_episodes',[]);
tbl = cat(1,tbl{:});
[~,I] = sort(string(tbl.vessel_name));
tbl = tbl(I,:);

tbl.genotype = categorical(tbl.genotype);
tbl.mouse = categorical(tbl.mouse);
tbl.state = categorical(tbl.state);

I = ismember(string(tbl.vessel_type), ["Penetrating Arteriole","Pial Artery","Vein"]);
tbl = tbl(I,:);

% Only inlclude NREM, IS and REM
tbl = tbl(ismember(tbl.state,{'NREM','IS','REM'}),:);

% sws = tbl(ismember(tbl.state,["NREM","IS"]),:);
% sws.state(:) = "SWS";
% tbl = cat(1,tbl,sws);
%%

I = tbl.vessel_type == "Penetrating Arteriole";
tbl1 = tbl(I,:);

[estimates,p_values,model] = yucca.statistics.estimate(tbl1, ...
    'diameter_red','genotype','state', ...
    'model_function',@(x)fitlme(x,'diameter_red ~ genotype * state + (1 | vessel_id)'));

f = figure;
model.plotResiduals('probability')

filename = fullfile(eustoma.get_plot_path,"Linescan Diameter Change Statistics","Penetrating Arteriole Lumen diameter residuals");
begonia.path.make_dirs(filename);
exportgraphics(f,filename+".png");
close(f)

filename = fullfile(eustoma.get_plot_path,"Linescan Diameter Change Statistics","Penetrating Arteriole Lumen diameter estimates.csv");
begonia.path.make_dirs(filename);
begonia.util.save_table(filename, estimates)

filename = fullfile(eustoma.get_plot_path,"Linescan Diameter Change Statistics","Penetrating Arteriole Lumen diameter p-values.csv");
begonia.path.make_dirs(filename);
begonia.util.save_table(filename, p_values)

filename = fullfile(eustoma.get_plot_path,"Linescan Diameter Change Statistics","Penetrating Arteriole Lumen diameter model.txt");
begonia.path.make_dirs(filename);
t = evalc('disp(model)');
fid = fopen(filename,'wt');
fprintf(fid, t);
fclose(fid);
%%
filename = fullfile(eustoma.get_plot_path,"Linescan Diameter Change Statistics","Penetrating Arteriole Lumen diameter estimates");
begonia.path.make_dirs(filename + "/")
yucca.statistics.plot_estimates(estimates,p_values, ...
    'y_label','Diameter (um)', ...
    'output_folder', filename)
close all