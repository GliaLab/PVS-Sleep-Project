begonia.logging.set_level(1);
scans = eustoma.get_linescans();
scans = scans(scans.has_var('vessels_red'));
%%
for i = 1:length(scans)
    begonia.logging.log(1,'Calculating diameter trial %d/%d',i,length(scans));
    
    vessels_red = scans(i).load_var('vessels_red');
    vessels_red_threshold = scans(i).load_var('vessels_red_threshold',[]);
    
    N_vessels = height(vessels_red);
    
    diameter_red = vessels_red;
    diameter_red.vessel = [];
    diameter_red.diameter = cell(N_vessels,1);
    diameter_red.vessel_upper = cell(N_vessels,1);
    diameter_red.vessel_lower = cell(N_vessels,1);
        
    if isempty(vessels_red_threshold)
        for j = 1:N_vessels
            mat = vessels_red.vessel{j};
            mat = single(mat);

            fig = figure;
            fig.Position(3:4) = [1500,750];
            t = (0:size(mat,2)-1) / vessels_red.vessel_fs(j);
            imagesc(mat,'XData',t);
            xlabel('Time (seconds)');
            xlim([t(1),t(end)])
            set(gca,'FontSize',15)
            filename = fullfile(eustoma.get_plot_path,'Linescans without diameter red',string(diameter_red.vessel_name) + ".png");
            begonia.path.make_dirs(filename);
            exportgraphics(fig,filename);
            close(fig)
        end
    else
        for j = 1:N_vessels
            mat = vessels_red.vessel{j};
            mat = single(mat);
            
            I = vessels_red_threshold.vessel_index == j;

            vessel_lower = eustoma.processing.linescans.diameter.threshold_linescan(...
                mat, ...
                vessels_red_threshold.lower_frame(I), ...
                vessels_red_threshold.lower_threshold(I), ...
                "outer", "lower");

            vessel_upper = eustoma.processing.linescans.diameter.threshold_linescan(...
                mat, ...
                vessels_red_threshold.upper_frame(I), ...
                vessels_red_threshold.upper_threshold(I), ...
                "outer", "upper");
            diameter_red.vessel_upper{j} = vessel_upper;
            diameter_red.vessel_lower{j} = vessel_lower;
            diameter_red.diameter{j} = (vessel_lower - vessel_upper) * vessels_red.vessel_dx(j);
        end
        
        scans(i).save_var(diameter_red);
    end
end
begonia.logging.log(1,'Finished');