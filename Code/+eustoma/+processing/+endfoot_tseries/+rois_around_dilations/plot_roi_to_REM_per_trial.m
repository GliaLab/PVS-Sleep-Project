begonia.logging.set_level(1);

ts = eustoma.get_endfoot_tseries();
ts = ts(ts.has_var('roi_to_rem'));
ts = ts(ts.has_var('diam_to_REM'));

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
sleep_color_table = table(ep_name,color);

%%

for i = 1:length(ts)
    %% Load
    roi_to_rem = ts(i).load_var('roi_to_rem');
    roi_to_rem_struct = ts(i).load_var('roi_to_rem_struct');
    
    roi_signals = ts(i).load_var('roi_signals');
    
    diameter = ts(i).load_var('diameter');
    
    sleep_episodes = ts(i).find_dnode('recrig').load_var('sleep_episodes');
    
    roi_table = ts(i).load_var('roi_table');
    
    diam_to_REM = ts(i).load_var('diam_to_REM');
    diam_to_REM_struct = ts(i).load_var('diam_to_REM_struct');
    %% Process
    % Add color to the vessels.
    diameter.color = lines(height(diameter));
    
    % Add the same vessel color to the diameter transitions.
    diam_to_REM = innerjoin(diam_to_REM, diameter(:,["vessel_id","color"]));
    
    % Merge the ROI signals into one trace.
    roi_trace = cat(1, roi_signals.signal{:});
    roi_trace = mean(roi_trace, 1);
    roi_t = (0:length(roi_trace)-1) / roi_signals.fs(1);
    
    % Calculate average ROI to REM.
    roi_to_rem_start = mean(roi_to_rem.signal_to_start,1);
    roi_to_rem_end = mean(roi_to_rem.signal_to_end,1);
    roi_to_rem_t = (0:length(roi_to_rem_end)-1) / roi_to_rem.fs(1);
    roi_to_rem_t = roi_to_rem_t - roi_to_rem_struct.sec_before_episode;
    
    %% Figure
    f = figure;
    f.Position(3:4) = [1200,1200];

    tiledlayout(5,5,"padding","none")

    ax1 = nexttile(2,[1,1]);
    hold on

    img = ts(i).load_var("avg_glt_img");
    imagesc(img);
    colormap(gray);
    xlim([0,size(img,2)])
    ylim([0,size(img,1)])
    ax1.YDir = 'normal';
        
    % Plot ROIs
    for k = 1:height(roi_table)
        [B,L] = bwboundaries(roi_table.mask{k},'noholes');
        for l = 1:length(B)
            boundary = B{l};
            plot(boundary(:,2), boundary(:,1), 'Color','b', 'LineWidth', 2)
        end
    end

    % Plot vessels
    for j = 1:height(diameter)
        pos = diameter.vessel_position(j,:);
        pos = reshape(pos,2,2);
        images.roi.Line(gca, "Position", pos, "Color",diameter.color(j,:));
    end
    
    ax2 = nexttile(4,[1,1]);
    img = ts(i).load_var("avg_texas_red_img");
    imagesc(img);
    colormap(gray);
    
    xlim([0,size(img,2)])
    ylim([0,size(img,1)])
    ax2.YDir = 'normal';
    for j = 1:height(diameter)
        pos = diameter.vessel_position(j,:);
        pos = reshape(pos,2,2);
        l = images.roi.Line(gca, "Position", pos, "Color",diameter.color(j,:));
    end
    
    ax3 = nexttile(6,[1,5]);
    hold on
    smooth_win = 10;
    for j = 1:height(diameter)
        trace = diameter.diameter{j};
        trace = smooth(trace,smooth_win);
        t = (0:length(trace)-1) / diameter.vessel_fs(j);
        plot(t,trace,"Color", diameter.color(j,:),'LineWidth',1);
    end
    
    if ~isempty(sleep_episodes)
        sleep_marks = yucca.plot.plot_episodes(sleep_episodes.state, ...
            sleep_episodes.state_start, ...
            sleep_episodes.state_end, ...
            0.6, [], sleep_color_table);
    end
    xlabel("Time (s)")
    ylabel("Diameter (um)");
    title(sprintf("Diameter smoothed with %d samples",smooth_win));
    xlim([t(1),t(end)])
    
    % Plot average ROI trace
    ax4 = nexttile(11,[1,5]);
    plot(roi_t, roi_trace, 'green');
    if ~isempty(sleep_episodes)
        sleep_marks = yucca.plot.plot_episodes(sleep_episodes.state, ...
            sleep_episodes.state_start, ...
            sleep_episodes.state_end, ...
            0.6, [], sleep_color_table);
    end
    xlabel("Time (s)")
    ylabel("Fluo.");
    title("Average ROI trace");
    xlim([t(1),t(end)])
    
    %% Plot vessel and ROI transition to start of REM.
    % Vessel
    ax5 = nexttile(16,[1,5]);
    cla
    hold on
    for j = 1:height(diam_to_REM)
        plot(diam_to_REM_struct.t,diam_to_REM.diam_to_start(j,:),"Color",diam_to_REM.color(j,:))
    end
    y = ylim;
    plot([0,0],[y(1),y(2)],'--k');
    title('Diameter to REM start transition')
    ylabel('Diameter (um)');
    xlim([roi_to_rem_t(1),roi_to_rem_t(end)]);
    
    % ROI
    ax6 = nexttile(21,[1,5]);
    cla
    plot(roi_to_rem_t,roi_to_rem_start,'green')
    hold on
    y = ylim;
    plot([0,0],[y(1),y(2)],'--k');
    title('Average ROI to REM start transition')
    ylabel('Ratio difference from transition');
    xlim([roi_to_rem_t(1),roi_to_rem_t(end)]);
    
    filename = fullfile(eustoma.get_plot_path,"Endfeet ROI to REM start per trial", ...
        ts(i).load_var("trial"));
    begonia.path.make_dirs(filename);
    exportgraphics(f,filename+".png");
    
    %% Plot vessel and ROI transition to end of REM.
    % Vessel
    ax5 = nexttile(16,[1,5]);
    cla
    hold on
    for j = 1:height(diam_to_REM)
        plot(diam_to_REM_struct.t,diam_to_REM.diam_to_end(j,:),"Color",diam_to_REM.color(j,:))
    end
    y = ylim;
    plot([0,0],[y(1),y(2)],'--k');
    title('Diameter to REM end transition')
    ylabel('Diameter (um)');
    xlim([roi_to_rem_t(1),roi_to_rem_t(end)]);
    
    % ROI
    ax6 = nexttile(21,[1,5]);
    cla
    plot(roi_to_rem_t,roi_to_rem_end,'green')
    hold on
    y = ylim;
    plot([0,0],[y(1),y(2)],'--k');
    title('Average ROI to REM end transition')
    ylabel('Ratio difference from transition');
    xlim([roi_to_rem_t(1),roi_to_rem_t(end)]);
    
    filename = fullfile(eustoma.get_plot_path,"Endfeet ROI to REM end per trial", ...
        ts(i).load_var("trial"));
    begonia.path.make_dirs(filename);
    exportgraphics(f,filename+".png");
    
    %%
    close(f) 
end


