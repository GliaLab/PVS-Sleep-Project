begonia.logging.set_level(1);
scans = eustoma.get_linescans();
scans = scans(scans.has_var('diameter_red_baseline') | scans.has_var('diameter_green_baseline'));

trials = eustoma.get_linescans_recrig();

dloc_list = yucca.datanode.DataNodeList();
dloc_list.add(trials);
dloc_list.add(scans);

trial_ids = "";
for i = 1:length(scans)
    trial_id = scans(i).load_var('trial_id');
    trial_ids(i) = trial_id.trial_id;
end
%%
selected_trials = table;
%selected_trials(end+1,["trial_id","start","end"]) = {"WT 10 20210422 06", 800,1100};
selected_trials(end+1,["trial_id","start","end"]) = {"WT 14 20210712 05", 10,600};
%selected_trials(end+1,["trial_id","start","end"]) = {"WT 06 20201008 11", 40,800};
disp(selected_trials)

%%
close all force
for i = 1:height(selected_trials)
    scan = scans(trial_ids == selected_trials.trial_id(i));
    
    diameter_red_tbl = scan.load_var('diameter_red_baseline', []);
    if ~isempty(diameter_red_tbl)
        diameter_red = diameter_red_tbl.diameter{1};
        
        vessels_red = scan.load_var('vessels_red');
    end
    
    diameter_green_tbl = scan.load_var('diameter_green_baseline', []);
    if ~isempty(diameter_green_tbl)
        diameter_green = diameter_green_tbl.diameter{1};
        
        vessels_green = scan.load_var('vessels_green');
    end
    
    diameter_peri_tbl = scan.load_var('diameter_peri_baseline', []);
    if ~isempty(diameter_peri_tbl)
        diameter_peri = diameter_peri_tbl.diameter{1};
    end
    
    ephys = scan.find_dnode("recrig").load_var("ephys");
    
    %%
    folder = fullfile(eustoma.get_plot_path,"Linescan example figure data", ...
        sprintf("%s from %.fs to %.fs",selected_trials.trial_id(i),selected_trials.start(i),selected_trials.end(i)));
    disp(folder);
    begonia.path.make_dirs(folder+filesep);
    %% Save the red and green picture.
    
    if ~isempty(diameter_red_tbl)
        img_red = vessels_red.vessel{1};
        img_red = img_red(:, round(selected_trials.start(i) * vessels_red.vessel_fs) : round(selected_trials.end(i) * vessels_red.vessel_fs));
        img_red = double(img_red);
        img_red = img_red - min(img_red(:));
        img_red = img_red / max(img_red(:));
    end
    
    if ~isempty(diameter_green_tbl)
        img_green = vessels_green.vessel{1};
        img_green = img_green(:, round(selected_trials.start(i) * vessels_green.vessel_fs) : round(selected_trials.end(i) * vessels_green.vessel_fs));
        img_green = double(img_green);
        img_green = img_green - min(img_green(:));
        img_green = img_green / max(img_green(:));
    end
    
    if ~isempty(diameter_red_tbl)
        img_vessel = zeros(size(img_red,1), size(img_red,2), 3, 'uint8');
        img_vessel_t = (0:size(img_vessel,2)-1) / vessels_red.vessel_fs;
        img_vessel_y = (0:size(img_vessel,1)-1) * vessels_red.vessel_dx;
    else
        img_vessel = zeros(size(img_green,1), size(img_green,2), 3, 'uint8');
        img_vessel_t = (0:size(img_vessel,2)-1) / vessels_green.vessel_fs;
        img_vessel_y = (0:size(img_vessel,1)-1) * vessels_green.vessel_dx;
    end
    
    if ~isempty(diameter_red_tbl)
        img_vessel(:,:,1) = img_red * 255;
    end
    if ~isempty(diameter_green_tbl)
        img_vessel(:,:,2) = img_green * 255;
    end
    
    f = figure;
    imagesc(img_vessel_t,img_vessel_y,img_vessel);
    ylabel('um');
    xlabel('Time (s)');
    export_fig(f,fullfile(folder,"Vessel image.fig"));
    exportgraphics(f,fullfile(folder,"Vessel image.png"));
    close(f);
    %% Export diameter 
    tbl = table;
    
    if ~isempty(diameter_green_tbl)
        diam_green = diameter_green(round(selected_trials.start(i) * diameter_green_tbl.vessel_fs) : round(selected_trials.end(i) * diameter_green_tbl.vessel_fs));
        tbl.diam_green = diam_green';
    end
    
    if ~isempty(diameter_red_tbl)
        diam_red = diameter_red(round(selected_trials.start(i) * diameter_red_tbl.vessel_fs) : round(selected_trials.end(i) * diameter_red_tbl.vessel_fs));
        tbl.diam_red = diam_red';
    end
    
    if ~isempty(diameter_peri_tbl)
        diam_peri = diameter_peri(round(selected_trials.start(i) * diameter_peri_tbl.vessel_fs) : round(selected_trials.end(i) * diameter_peri_tbl.vessel_fs));
        tbl.diam_peri = diam_peri';
    end
    
    if ~isempty(diameter_red_tbl)
        diam_t = (0:length(diam_red) -1) / diameter_red_tbl.vessel_fs;
        tbl.diam_t = diam_t';
    else
        diam_t = (0:length(diam_green) -1) / diameter_green_tbl.vessel_fs;
        tbl.diam_t = diam_t';
    end
    
    if ~isempty(tbl)
        writetable(tbl, fullfile(folder,"Diameter.csv"));
    end
    
    if ~isempty(diameter_red_tbl)
        f = figure;
        plot(diam_t,diam_red);
        ylabel('um');
        xlabel('Time (s)');
        exportgraphics(f,fullfile(folder,"Diameter lumen.png"));
        close(f);
    end
    
    if ~isempty(diameter_green_tbl)
        f = figure;
        plot(diam_t,diam_green);
        ylabel('um');
        xlabel('Time (s)');
        exportgraphics(f,fullfile(folder,"Diameter endfoot.png"));
        close(f);
    end
    
    if ~isempty(diameter_peri_tbl)
        f = figure;
        plot(diam_t,diam_peri);
        ylabel('um');
        xlabel('Time (s)');
        exportgraphics(f,fullfile(folder,"Diameter peri.png"));
        close(f);
    end
    
    %% Save the spectrograms
    frequency_limits = [0.1,50];
    frequency_ticks = [0.1,0.2,0.5,1,2,5,10,20,50];
    
    %% Red spectrogram
    if ~isempty(diameter_red_tbl)
        diameter_red_filled = fillmissing(diameter_red,'linear');
        fb = cwtfilterbank('SignalLength',numel(diameter_red), ...
            'SamplingFrequency',vessels_red.vessel_fs,...
            'FrequencyLimits',frequency_limits);

        [spectrogram_red,spectrogram_red_f] = cwt(diameter_red_filled,'FilterBank',fb);
        spectrogram_red = abs(spectrogram_red);

        spectrogram_red = spectrogram_red(:, round(selected_trials.start(i) * vessels_red.vessel_fs) : round(selected_trials.end(i) * vessels_red.vessel_fs));
        spectrogram_red_t = (0:size(spectrogram_red,2)-1) / vessels_red.vessel_fs;

        f = figure;
        imagesc(img_vessel_t,spectrogram_red_f,spectrogram_red);
        ylabel('Frequency (Hz)');
        xlabel('Time (s)');

        cb = colorbar;
        ylabel(cb,'Magnitude (um)')

        ax = gca;
        ax.YDir = 'normal';
        ax.YScale = 'log';
        ax.YTickLabelMode = 'auto';
        ax.YTick = frequency_ticks;
        ylim(frequency_limits);

        export_fig(f,fullfile(folder,"Spectrogram lumen.fig"));
        exportgraphics(f,fullfile(folder,"Spectrogram lumen.png"));
        close(f);
    end
    
    %% Green spectrogram
    if ~isempty(diameter_green_tbl)
        diameter_green_filled = fillmissing(diameter_green,'linear');
        fb = cwtfilterbank('SignalLength',numel(diameter_green), ...
            'SamplingFrequency',vessels_green.vessel_fs,...
            'FrequencyLimits',frequency_limits);

        [spectrogram_green,spectrogram_green_f] = cwt(diameter_green_filled,'FilterBank',fb);
        spectrogram_green = abs(spectrogram_green);

        spectrogram_green = spectrogram_green(:, round(selected_trials.start(i) * vessels_green.vessel_fs) : round(selected_trials.end(i) * vessels_green.vessel_fs));
        spectrogram_green_t = (0:size(spectrogram_green,2)-1) / vessels_green.vessel_fs;

        f = figure;
        imagesc(img_vessel_t,spectrogram_green_f,spectrogram_green);
        ylabel('Frequency (Hz)');
        xlabel('Time (s)');

        cb = colorbar;
        ylabel(cb,'Magnitude (um)')

        ax = gca;
        ax.YDir = 'normal';
        ax.YScale = 'log';
        ax.YTickLabelMode = 'auto';
        ax.YTick = frequency_ticks;
        ylim(frequency_limits);

        export_fig(f,fullfile(folder,"Spectrogram endfoot.fig"));
        exportgraphics(f,fullfile(folder,"Spectrogram endfoot.png"));
        close(f);
    end
    %% Peri spectrogram
    if ~isempty(diameter_peri_tbl)
        diameter_peri_filled = fillmissing(diameter_peri,'linear');
        fb = cwtfilterbank('SignalLength',numel(diameter_peri), ...
            'SamplingFrequency',diameter_peri_tbl.vessel_fs,...
            'FrequencyLimits',frequency_limits);

        [spectrogram_peri,spectrogram_peri_f] = cwt(diameter_peri_filled,'FilterBank',fb);
        spectrogram_peri = abs(spectrogram_peri);

        spectrogram_peri = spectrogram_peri(:, round(selected_trials.start(i) * diameter_peri_tbl.vessel_fs) : round(selected_trials.end(i) * diameter_peri_tbl.vessel_fs));
        spectrogram_peri_t = (0:size(spectrogram_peri,2)-1) / diameter_peri_tbl.vessel_fs;

        f = figure;
        imagesc(img_vessel_t,spectrogram_peri_f,spectrogram_peri);
        ylabel('Frequency (Hz)');
        xlabel('Time (s)');

        cb = colorbar;
        ylabel(cb,'Magnitude (um)')

        ax = gca;
        ax.YDir = 'normal';
        ax.YScale = 'log';
        ax.YTickLabelMode = 'auto';
        ax.YTick = frequency_ticks;
        ylim(frequency_limits);

        export_fig(f,fullfile(folder,"Spectrogram peri.fig"));
        exportgraphics(f,fullfile(folder,"Spectrogram peri.png"));
        close(f);
    end
    
    %% Export ephys
    
    filter_order = 10;

    aa = designfilt('bandpassiir','FilterOrder',filter_order, ...
        'HalfPowerFrequency1',0.5,'HalfPowerFrequency2',30, ...
        'SampleRate',ephys.Properties.SampleRate);
    ecog_filt = filter(aa, ephys.ecog);
    
    st = round(selected_trials.start(i) * ephys.Properties.SampleRate);
    en = round(selected_trials.end(i) * ephys.Properties.SampleRate);
    
    ecog_filt = ecog_filt(st:en);
    emg = ephys.emg(st:en);
    
    t = (0:length(emg)-1) / ephys.Properties.SampleRate;
    t = t';
    
    writetable(table(t,ecog_filt,emg), ...
        fullfile(folder,"ECoG and EMG.csv"));
    
    f = figure;
    plot(t,ecog_filt);
    ylabel('Original values, mV?');
    xlabel('Time (s)');
    exportgraphics(f,fullfile(folder,"ECoG.png"));
    export_fig(f,fullfile(folder,"ECoG.fig"));
    close(f);
    
    f = figure;
    plot(t,emg);
    ylabel('Original values, mV?');
    xlabel('Time (s)');
    exportgraphics(f,fullfile(folder,"EMG.png"));
    export_fig(f,fullfile(folder,"EMG.fig"));
    close(f);
    
end


