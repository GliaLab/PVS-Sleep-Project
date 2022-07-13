clear all
%%
ts = eustoma.get_endfoot_tseries();
ts = ts(ts.has_var('vessel_table'));

trials = eustoma.get_endfoot_recrigs();

dloc_list = yucca.datanode.DataNodeList();
dloc_list.add(trials);
dloc_list.add(ts);
%%
for i = 1:length(ts)
    vessel_table = ts(i).load_var('vessel_table');
    diameter = ts(i).load_var("diameter",[]);
    
    % Outerjoin the diameter. If the diameter is missing for a vessel the
    % spesific value will be empty.
    if ~isempty(diameter)
        % Remove the vessel_fs from vessel_table because it is not the same
        % value as vessel_fs in the diameter table. In the diameter table
        % the vessel_fs from vessel_table is called vessel_fs_raw.
        vessel_table.vessel_fs = [];
        vessel_table = outerjoin(vessel_table,diameter,'MergeKeys',true);
    end
    
    for j = 1:height(vessel_table)
        f = figure;
        f.Position(3:4) = [1200,1200];
        
        tiledlayout(2,2,"padding","tight")
        %%
        nexttile
        
        img = ts(i).load_var("avg_glt_img");
        imagesc(img);
        colormap(gray);
        
        pos = vessel_table.vessel_position(j,:);
        pos = reshape(pos,2,2);
        l = images.roi.Line(gca, "Position", pos);
        
        title("Glt");
        %%
        nexttile
        
        img = ts(i).load_var("avg_texas_red_img");
        imagesc(img);
        colormap(gray);
        
        pos = vessel_table.vessel_position(j,:);
        pos = reshape(pos,2,2);
        l = images.roi.Line(gca, "Position", pos);
        
        title("Texas red");
        %%
        nexttile(3,[1,2]);
        
        img = vessel_table.vessel{j};
        t = (0:size(img,2)-1) / vessel_table.vessel_fs(j);
        y = (0:size(img,1)-1) * vessel_table.vessel_dx(j);
        clim = prctile(img(:),[0,97]);
        imagesc(t,y,img,clim)
        
        if ~isempty(diameter)
            hold on
            plot(t,vessel_table.vessel_upper{j} * vessel_table.vessel_dx(j),'r');
            plot(t,vessel_table.vessel_lower{j} * vessel_table.vessel_dx(j),'r');
        end
        
        xlabel("Time (s)")
        ylabel("Length (um)");
        title("Vessel ID : " + vessel_table.vessel_id(j));
        
        filename = fullfile(eustoma.get_plot_path,"Endfeet Vessel outline and linescan", ...
            sprintf("%s Vessel %d",ts(i).load_var("trial"),j));
        begonia.path.make_dirs(filename);
        exportgraphics(f,filename+".png");
        close(f)
    end
end