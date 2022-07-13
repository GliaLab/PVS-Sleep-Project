clear all

%%
begonia.logging.set_level(1);
scans = eustoma.get_linescans();
scans = scans(scans.has_var('clean_episodes'));
scans = scans(scans.has_var('vessels_green'));
scans = scans(scans.has_var('vessels_red'));
scans = scans(scans.has_var('vessel_wall'));

% Pick selected trials.
trial_id = scans.load_var("trial_id");
trial_id = cat(1, trial_id{:});
trial_id = [trial_id.trial_id];

I = ismember(trial_id, ["WT 06 20201008 11","WT 10 20210226 07","WT 09 20210308 03"]);
scans = scans(I);

%%
close all force
for i = 1:length(scans)
    begonia.logging.log(1,"Scan %d/%d",i,length(scans));
    
    clean_episodes = scans(i).load_var('clean_episodes');
    clean_episodes.ep_duration = clean_episodes.ep_end - clean_episodes.ep_start;
    color_table = iris.get_state_color_table();
    color_table.ep(color_table.ep == "REM") = "Clean REM";
    color_table.ep(color_table.ep == "NREM") = "Clean NREM";
    color_table.ep(color_table.ep == "IS") = "Clean IS";
    color_table.ep(color_table.ep == "Vessel Baseline") = "Clean Vessel Baseline";
    clean_episodes = innerjoin(clean_episodes, color_table);
    
    vessels_green = scans(i).load_var('vessels_green');
    vessels_red = scans(i).load_var('vessels_red');
    
    vessel_name = string(vessels_green.vessel_name(1));
    
    % Reformate linescans into one table.
    linescan = cat(1,vessels_red,vessels_green);
    clear vessels_green vessels_red
    linescan.fs = linescan.vessel_fs;
    linescan.dx = linescan.vessel_dx;
    linescan.linescan = linescan.vessel;
    linescan.vessel = [];
    
    % Reformat vessel wall time series.
    vessel_wall = scans(i).load_var('vessel_wall');
    vessel_wall = stack(vessel_wall,["endfoot_upper","endfoot_lower","lumen_upper","lumen_lower"], ...
        "NewDataVariableName","y","IndexVariableName","name");
    vessel_wall.x = vessel_wall.time;
    vessel_wall.time = [];
    
    % Calculate the diameter. This is actually done in other scripts
    % usually but it's simple to get it from the vessel wall traces here.
    tbl_diam = table();
    tbl_diam.name = ["Endfoot","Lumen"]';
    tbl_diam.x = vessel_wall.x(1:2);
    tbl_diam.y = {vessel_wall.y{2} - vessel_wall.y{1}; vessel_wall.y{4} - vessel_wall.y{3} };
    tbl_diam.color = [0,1,0;1,0,0];
    tbl_diam.ylabel(:) = "Diameter (um)";
    
    % Calculate the pvs on each side. This can be done in other scripts
    % but it's simple to get it from the vessel wall traces here.
    tbl_pvs = table();
    tbl_pvs.name = ["PVS upper", "PVS lower"]';
    tbl_pvs.x = vessel_wall.x(1:2);
    tbl_pvs.y = {vessel_wall.y{3} - vessel_wall.y{1}; vessel_wall.y{2} - vessel_wall.y{4} };
    tbl_pvs.ylabel(:) = "PVS size (um)";
    
    % Init figure.
    tiles = [3,4];
    f = figure;
    f.Position(3:4) = fliplr(tiles) * 300;
    tiledlayout(tiles(1), tiles(2), "Padding", "tight", "TileSpacing", "tight");
    
    ax(1) = nexttile([1,4]);
    iris.linescan.plot_vessel_dual_color(linescan, vessel_wall);
    title(vessel_name)
    
    ax(2) = nexttile([1,4]);
    l = iris.time_series.plot_separate(tbl_diam);
    h = iris.episodes.plot_episodes(clean_episodes);
    legend([l(:);h(:)])
    title("Diameter");
    
    ax(3) = nexttile([1,4]);
    l = iris.time_series.plot_separate(tbl_pvs);
    h = iris.episodes.plot_episodes(clean_episodes);
    legend([l(:);h(:)])
    title("PVS sizes");
    
    linkaxes(ax,'x');
    
    % Save
    filename = fullfile(eustoma.get_plot_path, "Linescan Vessel Images Figures", vessel_name);
    begonia.path.make_dirs(filename);
    exportgraphics(f,filename+".png");
    savefig(f,filename+".fig")
    close(f)
end
