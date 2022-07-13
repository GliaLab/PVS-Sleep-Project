begonia.logging.set_level(1);
ts = eustoma.get_endfoot_tseries();
ts = ts(ts.has_var('diameter'));
ts = ts(ts.has_var('recrig'));
ts = ts(ts.has_var('roi_signals_raw'));

trials = eustoma.get_endfoot_recrigs();

dloc_list = yucca.datanode.DataNodeList();
dloc_list.add(trials);
dloc_list.add(ts);
%%

ep_name = ["REM","IS","NREM"]';
color = [82,28,138; ...
    177,124,246; ...
    117,208,250];
color = color / 256;
color_table = table(ep_name,color);

%%

for i = 1:length(ts)
    diameter = ts(i).load_var('diameter');
    
    sleep_episodes = ts(i).find_dnode('recrig').load_var('sleep_episodes',[]);
    
    roi_table = ts(i).load_var('roi_table',[]);
    roi_signals = ts(i).load_var('roi_signals_raw',[]);
    
    dt = ts(i).load_var('dt');
    
    
    for j = 1:height(diameter)
        
    
        % Find color of ROIs based on distance
        a = diameter.vessel_position(j,[1,3]);
        b = diameter.vessel_position(j,[2,4]);
        vessel_center = (a+b)/2;
        vessel_center = round(vessel_center);

        roi_pos = [roi_table.center_x,roi_table.center_y];
        dist = vecnorm(roi_pos - vessel_center,2,2);
        vec = linspace(min(dist),max(dist),256);
        dist_I = begonia.util.val2idx(vec,dist);
        color = turbo(256);
        dist_color = color(dist_I,:);

        % Sort ROIs based on distance
        [~,I] = sort(dist_I);
        roi_table = roi_table(I,:);
        dist_color = dist_color(I,:);
        roi_signals = roi_signals(I,:);
        %%

        trace = diameter.diameter{j};
        trace = smooth(trace,5);
        
        f = figure;
        f.Position(3:4) = [1200,1200];
        
        tiledlayout(5,5,"padding","none")
        %%
        ax = nexttile(1,[2,2]);
        hold on
        
        img = ts(i).load_var("avg_glt_img");
        imagesc(img);
        colormap(gray);
        
        pos = diameter.vessel_position(j,:);
        pos = reshape(pos,2,2);
        images.roi.Line(gca, "Position", pos);
        
        title("Glt");
        
        % Plot ROIs
        for k = 1:height(roi_table)
            [B,L] = bwboundaries(roi_table.mask{k},'noholes');
            for l = 1:length(B)
                boundary = B{l};
                plot(boundary(:,2), boundary(:,1), 'Color', dist_color(k,:), 'LineWidth', 2)
            end
        end
        
        xlim([0,size(img,2)])
        ylim([0,size(img,1)])
        %%
        ax = nexttile(4,[2,2]);
        
        img = ts(i).load_var("avg_texas_red_img");
        imagesc(img);
        colormap(gray);
        
        pos = diameter.vessel_position(j,:);
        pos = reshape(pos,2,2);
        l = images.roi.Line(gca, "Position", pos);
        
        title("Texas red");
        
        xlim([0,size(img,2)])
        ylim([0,size(img,1)])
        ax.YDir = 'normal';
        %%
        nexttile(11,[1,5]);
        t = (0:length(trace)-1) / diameter.vessel_fs(j);
        plot(t,trace);
        
        if ~isempty(sleep_episodes)
            yucca.plot.plot_episodes(sleep_episodes.state, ...
                sleep_episodes.state_start, ...
                sleep_episodes.state_end, ...
                0.6, [], color_table);
        end
        xlabel("Time (s)")
        ylabel("Diameter (um)");
        title("Diameter smoothed with 5 samples");
        
        xlim([t(1),t(end)])
        %%
        nexttile(16,[2,5]);
        hold on
        spacing = 2/height(roi_signals);
        for k = 1:height(roi_signals)
            trace = roi_signals.signal_raw{k};
            t = (0:length(trace)-1) * dt;
            
            f0 = round(mode(trace));
            trace = trace / f0 - 1;
            trace = smooth(trace,10);
            trace = trace + (k-1)*spacing;
            
            plot(t,trace,'Color',dist_color(k,:));
            
        end
%         ylim([-0.5,(k+1)*spacing + 0.5])
        title("ROI df/f0 traces")
        xlim([t(1),t(end)])
        %%
        
        filename = fullfile(eustoma.get_plot_path,"Endfeet Vessel diameter and ROI traces", ...
            sprintf("%s Vessel %d",ts(i).load_var("trial"),j));
        begonia.path.make_dirs(filename);
        exportgraphics(f,filename+".png");
        close(f)
    end
end
