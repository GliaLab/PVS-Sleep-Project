begonia.logging.set_level(1);

ts = eustoma.get_endfoot_tseries();
ts = ts(ts.has_var('roi_dilation'));
ts = ts(ts.has_var('eeg_dilation'));
ts = ts(ts.has_var('diameter_dilation'));

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
warning off

for i = 1:length(ts)
    roi_dilation = ts(i).load_var('roi_dilation');
    
    diameter = ts(i).load_var('diameter');
    
    sleep_episodes = ts(i).find_dnode('recrig').load_var('sleep_episodes',[]);
    
    roi_table = ts(i).load_var('roi_table');
    
    dilation_episodes = ts(i).load_var('dilation_episodes');
    
    eeg_dilation = ts(i).load_var('eeg_dilation');
    eeg_dilation_ep = ts(i).load_var('eeg_dilation_ep');
    
    diameter_dilation = ts(i).load_var('diameter_dilation');
    
    % Exclude vessels not in the diameter_dilation table.
    I = ~ismember(diameter.vessel_id,diameter_dilation.vessel_id);
    diameter(I,:) = [];
    
    % Calculate the average roi_trace per vessel
    [G,tbl_roi] = findgroups(roi_dilation(:,"vessel_id"));
    tbl_roi.ne_transition = splitapply(@(x)mean(x,1),roi_dilation.signal,G);
    tbl_roi.fs = splitapply(@(x)x(1),roi_dilation.fs,G);
    
    % Calculate the average diameter per vessel
    [G,tbl_diam] = findgroups(diameter_dilation(:,"vessel_id"));
    tbl_diam.diameter_transition = splitapply(@(x)mean(x,1),diameter_dilation.diameter,G);
    tbl_diam.vessel_fs = splitapply(@(x)x(1),diameter_dilation.vessel_fs,G);
    
    % Collect tables.
    tbl = innerjoin(diameter,tbl_roi);
    tbl = innerjoin(tbl,tbl_diam);
    tbl.color = lines(height(diameter));
    
    % Also add the color to the dilation_episodes.
    dilation_episodes = innerjoin(dilation_episodes,tbl(:,["vessel_id","color"]));
    
    % Calculate the average spectrogram of the transitions
    spectrogram = cat(3,eeg_dilation_ep.spectrogram{:});
    mid = round(size(spectrogram,2)/2);
    spectrogram = spectrogram - spectrogram(:,mid,:);
    spectrogram = mean(spectrogram,3);

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
    for j = 1:height(tbl)
        pos = tbl.vessel_position(j,:);
        pos = reshape(pos,2,2);
        images.roi.Line(gca, "Position", pos, "Color",tbl.color(j,:));
    end
    
    ax2 = nexttile(4,[1,1]);
    img = ts(i).load_var("avg_texas_red_img");
    imagesc(img);
    colormap(gray);
    
    xlim([0,size(img,2)])
    ylim([0,size(img,1)])
    ax2.YDir = 'normal';
    for j = 1:height(tbl)
        pos = tbl.vessel_position(j,:);
        pos = reshape(pos,2,2);
        l = images.roi.Line(gca, "Position", pos, "Color",tbl.color(j,:));
    end
    
    ax3 = nexttile(6,[1,5]);
    hold on
    smooth_win = 10;
    for j = 1:height(tbl)
        trace = tbl.diameter{j};
        trace = smooth(trace,smooth_win);
        t = (0:length(trace)-1) / tbl.vessel_fs(j);
        plot(t,trace,"Color", tbl.color(j,:),'LineWidth',1);
    end
    diams = cat(1,tbl.diameter{:});
    lim = [mean(diams(:))-2.5*std(diams(:)),mean(diams(:))+2*std(diams(:))];
    ylim(lim);
    
    for j = 1:height(dilation_episodes)
        plot([dilation_episodes.ep_start(j),dilation_episodes.ep_start(j)],lim,"--", ...
            "Color",dilation_episodes.color(j,:), ...
            "LineWidth",1);
    end
    
    for j = 1:height(tbl)
        p = plot(NaN,"--", ...
            "Color",tbl.color(j,:), ...
            'DisplayName','Dilation', ...
            "LineWidth",1);
        if j == 1
            dilation_mark = p;
        else
            dilation_mark(j) = p;
        end
    end
    
    if ~isempty(sleep_episodes)
        sleep_marks = yucca.plot.plot_episodes(sleep_episodes.state, ...
            sleep_episodes.state_start, ...
            sleep_episodes.state_end, ...
            0.6, [], sleep_color_table);
    end
    legend([sleep_marks,dilation_mark])
    xlabel("Time (s)")
    ylabel("Diameter (um)");
    title(sprintf("Diameter smoothed with %d samples",smooth_win));
    
    ax4 = nexttile(11,[1,5]);
    hold on;
    t = (0:size(tbl.diameter_transition,2)-1) / tbl.vessel_fs(1); 
    t = t - t(round(length(t)/2));
    for j = 1:height(tbl)
        plot(t,tbl.diameter_transition(j,:),'LineWidth',2,"Color", tbl.color(j,:))
    end
    lim = ylim;
    plot([0,0],lim,'k');
    title('Diameter around dilations')
    ylabel('Diameter (um)');
    xlim([t(1),t(end)]);
    
    ax5 = nexttile(16,[1,5]);
    hold on;
    t = (0:size(tbl.ne_transition,2)-1) / tbl.fs(1); 
    t = t - t(round(length(t)/2));
    for j = 1:height(tbl)
        plot(t,tbl.ne_transition(j,:),'b','LineWidth',2,"Color", tbl.color(j,:))
    end
    lim = ylim;
    plot([0,0],lim,'k');
    title('Glt1 fluo. ratio around dilations')
    ylabel('df/f0')
    xlim([t(1),t(end)]);
    
    ax6 = nexttile(21,[1,5]);
    imagesc(eeg_dilation.t,eeg_dilation.f,spectrogram);
    colormap(begonia.colormaps.turbo);
    cb = colorbar;
    
    ax6.YTickLabelMode = 'auto';
    ax6.YTick = [0.1,0.2,0.5,1,2,5,10,20,50];
    ax6.YDir = 'normal';
    ax6.YScale = 'log';
    ylabel('Frequency (Hz)');
    title("Average ECoG Spectrogram difference compared t = 0");
    xlim([t(1),t(end)]);
    
    filename = fullfile(eustoma.get_plot_path,"Endfeet Vessel diameter and ROI traces around dilation", ...
        ts(i).load_var("trial"));
    begonia.path.make_dirs(filename);
    exportgraphics(f,filename+".png");
    close(f) 
end

warning on
