clear all

%% Load tseries
ts = get_tseries();
ts = ts(ts.has_var("average_images"));
ts = ts(ts.has_var("vessel_diameter"));
ts = ts(ts.has_var("vessel_dilations"));
ts = ts(ts.has_var("roi_df_time_series"));
ts = ts(ts.has_var("roi_df_aligned_to_dilations"));
ts = ts(ts.has_var("roi_roa_time_series"));
ts = ts(ts.has_var("roi_roa_aligned_to_dilations"));
ts = ts(ts.has_var("diameter_aligned_to_dilations"));
ts = ts(ts.has_var("episodes"));

%%
close all force
tic
for i = 1:length(ts)
    if i == 1 || i == length(ts) || toc > 5
        tic
        begonia.logging.log(1,"%d / %d",i,length(ts));
    end
    
    average_images = ts(i).load_var("average_images");
    vessel_linescan = ts(i).load_var("vessel_linescan");
    vessel_diameter = ts(i).load_var("vessel_diameter");
    episodes = ts(i).load_var("episodes");
    roi_df_aligned_to_dilations = ts(i).load_var("roi_df_aligned_to_dilations");
    roi_df_time_series = ts(i).load_var("roi_df_time_series");
    roi_roa_aligned_to_dilations = ts(i).load_var("roi_roa_aligned_to_dilations");
    roi_roa_time_series = ts(i).load_var("roi_roa_time_series");
    diameter_aligned_to_dilations = ts(i).load_var("diameter_aligned_to_dilations");
    
    % Assign a color to the vessel linescans and ROIs.
    color_table = vessel_diameter(:,"linescan_id");
    color_table.color = begonia.util.distinguishable_colors(height(vessel_diameter));
    vessel_diameter = innerjoin(vessel_diameter, color_table);
    
    % Only include ROIs associated with vessel linescans and change the ROI
    % color to the color of the linescan. Use findgroups to avoid duplicate
    % linescan_id - roi_id pairs due to multiple dilation time points on
    % the same diameter time series.
    [~,roi_linescans] = findgroups(roi_df_aligned_to_dilations(:,["linescan_id","roi_id"]));
    roi_linescans = innerjoin(roi_linescans, color_table);
    roi_df_time_series = innerjoin(roi_df_time_series, roi_linescans);
    roi_df_aligned_to_dilations = innerjoin(roi_df_aligned_to_dilations, roi_linescans);
    
    % Make a time point table at 0 for plotting.
    t0 = table;
    t0.t0 = 0;
    t0.color = [0,0,0];
    
    % Init figure.
    tiles = [3,5];
    f = figure;
    f.Position(3:4) = fliplr(tiles) * 400;
    tiledlayout(tiles(1), tiles(2), "Padding", "tight", "TileSpacing", "tight");
    
    nexttile
    iris.image.plot_image(average_images);
    iris.roi.plot_rois(roi_df_time_series);
    iris.linescan.plot_linescan_line(vessel_diameter);
    title("Average image with ROIs and linescan");
    
    nexttile([1,2])
    iris.time_series.plot_separate(vessel_diameter);
    iris.episodes.plot_episodes(episodes);
    legend("AutoUpdate","off");
    iris.time_points.plot_time_points(roi_df_aligned_to_dilations);
    
    nexttile([1,2])
    iris.time_series.plot_separate(diameter_aligned_to_dilations);
    iris.time_points.plot_time_points(t0);
    
    nexttile
    iris.linescan.plot_vessel_linescan(vessel_linescan,vessel_diameter);
    title("First vessel linescan");
    
    nexttile([1,2])
    iris.time_series.plot_separate(roi_df_time_series);
    iris.episodes.plot_episodes(episodes);
    legend("AutoUpdate","off");
    iris.time_points.plot_time_points(roi_df_aligned_to_dilations);
    
    nexttile([1,2])
    iris.time_series.plot_time_series(roi_df_aligned_to_dilations);
    iris.time_points.plot_time_points(t0);
    
    nexttile
    if height(vessel_linescan) > 1
        iris.linescan.plot_vessel_linescan(vessel_linescan(2,:),vessel_diameter(2,:));
        title("Second vessel linescan");
    end
    
    nexttile([1,2])
    iris.time_series.plot_separate(roi_roa_time_series);
    iris.episodes.plot_episodes(episodes);
    legend("AutoUpdate","off");
    iris.time_points.plot_time_points(roi_df_aligned_to_dilations);
    
    nexttile([1,2])
    iris.time_series.plot_time_series(roi_roa_aligned_to_dilations);
    iris.time_points.plot_time_points(t0);
    
    % Save
    trial_id = average_images.trial_id(1);
    filename = fullfile(get_project_path, "Plot", "ROI df and roa aligned to dilations", trial_id+".png");
    begonia.path.make_dirs(filename);
    exportgraphics(f,filename);
    close(f)
end