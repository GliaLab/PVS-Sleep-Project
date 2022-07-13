begonia.logging.set_level(1);
scans = eustoma.get_linescans();
scans = scans(scans.has_var('diameter_red_baseline') | scans.has_var('diameter_green_baseline'));
scans = scans(scans.has_var('vessel_id'));
vessel_id = scans.load_var('vessel_id');
vessel_id = str2double(vessel_id);
%%
vessel_id_duplicate = zeros(size(vessel_id));
for i = 1:length(vessel_id)
    vessel_id_duplicate(i) = sum(vessel_id(i) == vessel_id);
end
%%
f = figure;
histogram(vessel_id_duplicate,'BinMethod','integers')
xlabel("# identical vessel IDs")
ylabel("# trials")

% Save
filename = fullfile(eustoma.get_plot_path,'Linescan Tables',"Num trials with vessel_id.png");
begonia.path.make_dirs(filename);
exportgraphics(f,filename);
close(f)
