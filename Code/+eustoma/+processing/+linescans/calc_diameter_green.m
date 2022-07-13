begonia.logging.set_level(1);
scans = eustoma.get_linescans();
scans = scans(scans.has_var('vessels_green'));
%%
for i = 1:length(scans)
    begonia.logging.log(1,'Calculating diameter trial %d/%d',i,length(scans));
    
    vessels_green = scans(i).load_var('vessels_green');
    vessels_green_threshold = scans(i).load_var('vessels_green_threshold', []);
    
    N_vessels = height(vessels_green);
    
    diameter_green = vessels_green;
    diameter_green.vessel = [];
    diameter_green.diameter = cell(N_vessels,1);
    diameter_green.vessel_upper = cell(N_vessels,1);
    diameter_green.vessel_lower = cell(N_vessels,1);
    
    if isempty(vessels_green_threshold)
        for j = 1:N_vessels
            mat = vessels_green.vessel{j};
            mat = single(mat);

            fig = figure;
            fig.Position(3:4) = [1500,750];
            t = (0:size(mat,2)-1) / vessels_green.vessel_fs(j);
            imagesc(mat,'XData',t);
            xlabel('Time (seconds)');
            xlim([t(1),t(end)])
            set(gca,'FontSize',15)
            filename = fullfile(eustoma.get_plot_path,'Linescans without diameter green',string(diameter_green.vessel_name) + ".png");
            begonia.path.make_dirs(filename);
            exportgraphics(fig,filename);
            close(fig)
        end
    else
        for j = 1:N_vessels
            mat = vessels_green.vessel{j};
            mat = single(mat);

            I = vessels_green_threshold.vessel_index == j;

            vessel_lower = eustoma.processing.linescans.diameter.threshold_linescan(...
                mat, ...
                vessels_green_threshold.lower_frame(I), ...
                vessels_green_threshold.lower_threshold(I), ...
                "inner", "lower");

            vessel_upper = eustoma.processing.linescans.diameter.threshold_linescan(...
                mat, ...
                vessels_green_threshold.upper_frame(I), ...
                vessels_green_threshold.upper_threshold(I), ...
                "inner", "upper");

            diameter_green.vessel_upper{j} = vessel_upper;
            diameter_green.vessel_lower{j} = vessel_lower;
            diameter_green.diameter{j} = (vessel_lower - vessel_upper) * vessels_green.vessel_dx(j);
        end
        scans(i).save_var(diameter_green);
    end
end
begonia.logging.log(1,'Finished');