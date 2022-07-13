clear all
%%
ts = eustoma.get_endfoot_tseries();
ts = ts(ts.has_var('roi_signals_cap'));
ts = ts(ts.has_var('diameter'));

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
    roi_signals_cap = ts(i).load_var('roi_signals_cap');
    roi_signals_cap.color = autumn(height(roi_signals_cap));
    
    diameter = ts(i).load_var('diameter');
    diameter.color = lines(height(diameter));
    
    roi_signals = ts(i).load_var('roi_signals');
    roi_signals.color = winter(height(roi_signals));
    
    sleep_episodes = ts(i).find_dnode('recrig').load_var('sleep_episodes',[]);
    
    wheel = ts(i).find_dnode('recrig').load_var('wheel');
    
    f = figure;
    f.Position(3:4) = [1350,1150];

    tiledlayout(5,5,"padding","none")
    
    ax1 = nexttile(2,[1,1]);
    hold on

    img = ts(i).load_var("avg_glt_img");
    imagesc(img);
    colormap(gray);
    xlim([0,size(img,2)])
    ylim([0,size(img,1)])
    ax1.YDir = 'normal';
    colorbar
        
    % Plot ROIs
    for k = 1:height(roi_signals_cap)
        [B,L] = bwboundaries(roi_signals_cap.mask{k},'noholes');
        for l = 1:length(B)
            boundary = B{l};
            plot(boundary(:,2), boundary(:,1), 'Color',roi_signals_cap.color(k,:), 'LineWidth', 2)
        end
    end
    
    % Plot ROIs
    for k = 1:height(roi_signals)
        [B,L] = bwboundaries(roi_signals.mask{k},'noholes');
        for l = 1:length(B)
            boundary = B{l};
            plot(boundary(:,2), boundary(:,1), 'Color','b', 'LineWidth', 2)
        end
    end
    
    ax2 = nexttile(4,[1,1]);
    img = ts(i).load_var("avg_texas_red_img");
    imagesc(img);
    colormap(gray);
    colorbar
    
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
    diams = cat(1,diameter.diameter{:});
    lim = [mean(diams(:))-2.5*std(diams(:)),mean(diams(:))+2*std(diams(:))];
    ylim(lim);
    
    if ~isempty(sleep_episodes)
        sleep_marks = yucca.plot.plot_episodes(sleep_episodes.state, ...
            sleep_episodes.state_start, ...
            sleep_episodes.state_end, ...
            0.6, [], sleep_color_table);
    end
    xlabel("Time (s)")
    ylabel("Diameter (um)");
    title(sprintf("Diameter smoothed with %d samples",smooth_win));
    xlim([0,t(end)]);
    
    
    ax4 = nexttile(11,[1,5]);
    hold on
    smooth_win = 10;
    for j = 1:height(roi_signals_cap)
        trace = roi_signals_cap.signal{j};
        trace = smooth(trace,smooth_win);
        t = (0:length(trace)-1) / roi_signals_cap.fs(j);
        plot(t,trace,"Color", roi_signals_cap.color(j,:),'LineWidth',1);
    end
    
    if ~isempty(sleep_episodes)
        sleep_marks = yucca.plot.plot_episodes(sleep_episodes.state, ...
            sleep_episodes.state_start, ...
            sleep_episodes.state_end, ...
            0.6, [], sleep_color_table);
    end
    xlabel("Time (s)")
    ylabel("ROI Fluo.");
    title(sprintf("Center vessel ROI(s) fluo. smoothed with %d samples",smooth_win));
    xlim([0,t(end)]);
    
    
    nexttile(16,[1,5]);
    hold on
    spacing = 2/height(roi_signals);
    for k = 1:height(roi_signals)
        trace = roi_signals.signal{k};
        t = (0:length(trace)-1) / roi_signals.fs(k);
        trace = trace + (k-1)*spacing;

        plot(t,trace,'Color',roi_signals.color(k,:));
    end
    if ~isempty(sleep_episodes)
        sleep_marks = yucca.plot.plot_episodes(sleep_episodes.state, ...
            sleep_episodes.state_start, ...
            sleep_episodes.state_end, ...
            0.6, [], sleep_color_table);
    end
    xlim([0,t(end)]);
    title("Normal ROI trace(s)")
    
    
    nexttile(21,[1,5]);
    hold on
    wheel_t = seconds(wheel.Time);
    wheel_speed = wheel.wheel_speed;
    smooth_win_sec = 5;
    smooth_win = round(smooth_win_sec * wheel.Properties.SampleRate);
    wheel_speed = smooth(wheel_speed,smooth_win);
    plot(wheel_t,wheel_speed);
    ylabel("Wheel speed (deg/s)");
    title(sprintf("Wheel speed smoothed with %d seconds",smooth_win_sec));
    if ~isempty(sleep_episodes)
        sleep_marks = yucca.plot.plot_episodes(sleep_episodes.state, ...
            sleep_episodes.state_start, ...
            sleep_episodes.state_end, ...
            0.6, [], sleep_color_table);
    end
    xlim([0,t(end)]);
    
    filename = fullfile(eustoma.get_plot_path,"Endfeet ROI in empty vessels per trial", ts(i).load_var("trial"));
    begonia.path.make_dirs(filename);
    exportgraphics(f,filename+".png");
    close(f) 
end