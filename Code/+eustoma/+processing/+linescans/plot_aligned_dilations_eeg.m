begonia.logging.set_level(1);

scans = eustoma.get_linescans();
scans = scans(scans.has_var('eeg_dilation'));

trials = eustoma.get_linescans_recrig();

dloc_list = yucca.datanode.DataNodeList();
dloc_list.add(trials);
dloc_list.add(scans);

%%
ep_name = ["NREM","IS","REM","Vessel Baseline","Locomotion","Whisking","Quiet"]';
color = zeros(0,3);
color(end+1,:) = [117,208,250];
color(end+1,:) = [177,124,246]; 
color(end+1,:) = [82,28,138]; 
color(end+1,:) = [100,256,100];
color(end+1,:) = [230,0,0];
color(end+1,:) = [230,230,0];
color(end+1,:) = [39,143,144];
color = color / 256;
color_table = table(ep_name,color);

%%
close all
for i = 1:length(scans)
    begonia.logging.log(1,"Trial %d/%d",i,length(scans));
    eeg_dilation = scans(i).load_var('eeg_dilation');
    eeg_dilation_tbl = scans(i).load_var('eeg_dilation_tbl');
    trial_id = scans(i).load_var('trial_id');
    trial_id = trial_id.trial_id;
    
    diameter_red = scans(i).load_var('diameter_red_baseline');
    
    episodes = scans(i).load_var('episodes',[]);
    
    ephys = scans(i).find_dnode('recrig').load_var('ephys');
    
    diameter = diameter_red.diameter{1};
    diameter_t = (0:length(diameter)-1) / diameter_red.vessel_fs;
    
    ecog_slow_delta = bandpass(ephys.ecog, [0.2,4], ephys.Properties.SampleRate);
    ecog_t = (0:length(ecog_slow_delta)-1) / ephys.Properties.SampleRate;
    
    % Add color values to each dilation.
    eeg_dilation_tbl.color = turbo(height(eeg_dilation_tbl));
    
    % Assign values from the input data.
    slow_delta = eeg_dilation_tbl.slow_delta;
    t = eeg_dilation.t;
    f = eeg_dilation.f;
    
    % Find the index of the dilation.
    mid = begonia.util.val2idx(t,0);
    
    % Offset the slow delta amplitude by the value at dilation.
    slow_delta = slow_delta - slow_delta(:,mid);
    
    % Calculate average spectrogram.
    spectrogram = cat(3,eeg_dilation_tbl.spectrogram{:});
    % Offset the values along the dilation.
    spectrogram = spectrogram - spectrogram(:,mid,:);
    spectrogram = mean(spectrogram,3);
    
    fig = figure; 
    fig.Position(3:4) = [2000,1000];

    tile = tiledlayout(4,1, ...
        'TileSpacing', 'tight', ...
        'Padding', 'tight');
    
    ax = gobjects(0);
    
    ax(1) = nexttile;
    plot(diameter_t,diameter,"k");
    yucca.plot.plot_episodes( ...
        episodes.state, ...
        episodes.state_start, ...
        episodes.state_end,0.3,[],color_table);
    legend("AutoUpdate","Off")
    hold on
    y_limits = ylim;
    % Plot each dilation
    for j = 1:height(eeg_dilation_tbl)
        t0 = eeg_dilation_tbl.t0(j);
        plot([t0,t0], [y_limits(1),y_limits(2)],'--', ...
            "Color", eeg_dilation_tbl.color(j,:), ...
            "LineWidth", 2);
    end
    title("Vessel lumen diameter")
    ylabel("Diameter (um)");
    xlabel("Time (s)");
    xlim([diameter_t(1),diameter_t(end)]);
    ax(1).XMinorTick = "On";
    
    ax(2) = nexttile;
    plot(ecog_t,ecog_slow_delta,"k")
    ylabel("ECoG (original units)")
    title("Slow delta (0.2-4 Hz) ECoG");
    xlim([diameter_t(1),diameter_t(end)]);
    hold on
    y_limits = ylim;
    % Plot each dilation
    for j = 1:height(eeg_dilation_tbl)
        t0 = eeg_dilation_tbl.t0(j);
        plot([t0,t0], [y_limits(1),y_limits(2)],'--', ...
            "Color", eeg_dilation_tbl.color(j,:), ...
            "LineWidth", 2);
    end
    ax(2).XMinorTick = "On";
    
    ax(3) = nexttile;
    hold on
    p = gobjects(0);
    for j = 1:height(eeg_dilation_tbl)
        p(j) = plot(t,slow_delta(j,:),"Color",eeg_dilation_tbl.color(j,:),"LineWidth",2);
    end
    ylabel("Power")
    title("Slow delta (0.2-4 Hz) ECoG power aligned to dilation")
    
    ax(4) = nexttile;
    imagesc(t,f,spectrogram);
    colormap(begonia.colormaps.turbo);
    cb = colorbar;
    ax(4).YTickLabelMode = 'auto';
    ax(4).YTick = [0.01,0.02,0.05,0.1,0.2,0.5,1,2,5,10,20,50];
    ax(4).YDir = 'normal';
    ax(4).YScale = 'log';
    ylabel('Frequency (Hz)');
    title(sprintf("Average ECoG Spectrogram aligned to dilation, N = %d",height(eeg_dilation_tbl)));
    xlabel("Time from dilation (seconds)")
    
    filename = fullfile(eustoma.get_plot_path,'Linescan dilations ECoG per trial',trial_id+".png");
    begonia.path.make_dirs(filename);
    exportgraphics(fig,filename);
    close(fig)
end