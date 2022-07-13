clear all

begonia.logging.set_level(1);
scans = eustoma.get_linescans();
scans = scans(scans.has_var('diameter_green_baseline'));
scans = scans(scans.has_var('diameter_red_baseline'));
scans = scans(scans.has_var('diameter_peri_baseline'));
scans = scans(scans.has_var('episodes'));

trials = eustoma.get_linescans_recrig();
trials = trials(trials.has_var('ephys'));

dloc_list = yucca.datanode.DataNodeList();
dloc_list.add(trials);
dloc_list.add(scans);
%%

ep_name = ["NREM","IS","REM","Vessel Baseline"]';
color = zeros(4,3);
color(1,:) = [117,208,250];
color(2,:) = [177,124,246]; 
color(3,:) = [82,28,138]; 
color(4,:) = [100,256,100];
color = color / 256;
color_table = table(ep_name,color);
%%
for i = 1:length(scans)
    begonia.logging.log(1,'Plotting %d/%d',i,length(scans));
    
    diameter_red = scans(i).load_var('diameter_red_baseline');
    diameter_green = scans(i).load_var('diameter_green_baseline');
    diameter_peri = scans(i).load_var('diameter_peri_baseline');
    episodes = scans(i).load_var('episodes');
    ephys = scans(i).find_dnode('recrig').load_var('ephys',[]);
    
    if isempty(ephys)
        continue;
    end 
    
    N_vessels = height(diameter_red);
    
    for j = 1:N_vessels
        
        f = figure; 
        f.Position = [10,50,2000,1000];
        
        tile = tiledlayout(5,1, ...
            'TileSpacing', 'none', ...
            'Padding', 'none');
        
        ax(1) = nexttile;
        hold on
        t = (0:length(diameter_green.diameter{j})-1) / diameter_green.vessel_fs(j);
        title(string(diameter_red.vessel_name(j)) + " diameter")
        plot(t, diameter_green.diameter{j}, '-g');
        plot(t, diameter_red.diameter{j}, '-r');
        ylabel('Diameter (um)');
        yucca.plot.plot_episodes(episodes.state, ...
            episodes.state_start, ...
            episodes.state_end, ...
            0.6, [], color_table);
        
        ax(2) = nexttile;
        plot(t, diameter_peri.diameter{j}, '-b');
        ylabel('Perivascular space (um)');
        yucca.plot.plot_episodes(episodes.state, ...
            episodes.state_start, ...
            episodes.state_end, ...
            0.6, [], color_table);
        title("Perivascular space");
        
        ax(3) = nexttile;
        flims = [0.01,50];
        diameter = diameter_red.diameter{j};
        diameter = fillmissing(diameter,'linear');
        fb = cwtfilterbank('SignalLength',numel(diameter), ...
            'SamplingFrequency',diameter_red.vessel_fs(j),...
            'FrequencyLimits',flims);
        [wt,freq] = cwt(diameter,'FilterBank',fb);
        wt = abs(wt);
        t = (0:length(diameter)-1)/diameter_red.vessel_fs(j);
        imagesc(t,freq,wt,[0,0.2]);
        colormap(turbo);
        cb = colorbar;
        ylabel(cb,'Magnitude (um)')
        ax(3).YDir = 'normal';
        ax(3).YScale = 'log';
        ax(3).YTickLabelMode = 'auto';
        ax(3).YTick = yticks;
        ylim(flims);
        ylabel('Frequency (Hz)');
        title("Vessel lumen spectrogram");
        
        ax(4) = nexttile;
        t = seconds(ephys.Time);
        ecog = bandpass(ephys.ecog,[0.4,5],ephys.Properties.SampleRate);
        plot(t,ecog);
        title("ECoG 0.4 - 5 Hz");
        ylabel("ECoG (arb. unit)");
        
        ax(5) = nexttile;
        t = seconds(ephys.Time);
        ecog = bandpass(ephys.ecog,[5,12],ephys.Properties.SampleRate);
        plot(t,ecog);
        title("ECoG 5 - 12 Hz");
        ylabel("ECoG (arb. unit)");
        
        linkaxes(ax,'x');
        xlim([t(1),t(end)]);
        xlabel('Time (s)');

        % Save
        filename = string(diameter_peri.vessel_name(j));
        filename = fullfile(eustoma.get_plot_path,'Linescan Diameter ECoG',filename);
        begonia.path.make_dirs(filename);
        exportgraphics(tile,filename+".png");
        close(f)
    end
end
