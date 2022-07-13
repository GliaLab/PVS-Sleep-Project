
begonia.logging.set_level(1);
scans = eustoma.get_linescans();
scans = scans(scans.has_var('diameter_peri_baseline'));

trials = eustoma.get_linescans_recrig();

dloc_list = yucca.datanode.DataNodeList();
dloc_list.add(trials);
dloc_list.add(scans);
%%
color_table = eustoma.processing.linescans.get_sleep_color_table();

%%
for i = 1:length(scans)
    begonia.logging.log(1,'Plotting %d/%d',i,length(scans));
    
    vessels_red = scans(i).load_var('vessels_red');
    vessels_green = scans(i).load_var('vessels_green');
    diameter_red = scans(i).load_var('diameter_red_baseline');
    diameter_green = scans(i).load_var('diameter_green_baseline');
    diameter_peri = scans(i).load_var('diameter_peri_baseline');
    trial_type = scans(i).load_var('trial_type');
    vessel_type = scans(i).load_var('vessel_type');
    
    if trial_type == "Ignore"
        continue;
    end
    
    N_vessels = height(diameter_peri);
    
    for j = 1:N_vessels
        
        diameter = diameter_peri.diameter{j};
        fs = diameter_peri.vessel_fs(j);
        flims = [0.1,50];
        
        diameter_filled = fillmissing(diameter,'linear');
        
        margins = [0.05,0.05];
        yticks = [0.1,0.2,0.5,1,2,5,10,20,50];
        fig = figure;
        fig.Position(3:4) = [1500,750];
        ax = gobjects;
        ax(1) = yucca.plot.subplot_tight(3,1,1,margins);

        fb = cwtfilterbank('SignalLength',numel(diameter), ...
            'SamplingFrequency',fs,...
            'FrequencyLimits',flims);

        [wt,f] = cwt(diameter_filled,'FilterBank',fb);
        wt = abs(wt);
        t = (0:length(diameter)-1)/fs;

        imagesc(t,f,wt,[0,0.2]);
        colormap(begonia.colormaps.turbo);
        cb = colorbar;
        ylabel(cb,'Magnitude (um)')

        ax(1).YDir = 'normal';
        ax(1).YScale = 'log';
        ax(1).YTickLabelMode = 'auto';
        ax(1).YTick = yticks;
        ylim(flims);
        ylabel('Frequency (Hz)');


        ax(2) = yucca.plot.subplot_tight(3,1,2,margins);
        plot(t,diameter);
        cb = colorbar;
        ylabel('Diameter (um)');
        ylabel(cb,'N/A')
        episodes = scans(i).load_var('episodes',[]);
        if ~isempty(episodes)
            I = ismember(color_table.ep_name, episodes.state);
            yucca.plot.plot_episodes( ...
                episodes.state, ...
                episodes.state_start, ...
                episodes.state_end,0.3,[],color_table(I,:));
        end
        
        % Get the indices of the vessel image where the diameter of the
        % green and red channel starts and ends. 
        st_green = diameter_green.vessel_upper{j};
        en_green = diameter_green.vessel_lower{j};
        st_red = diameter_red.vessel_upper{j};
        en_red = diameter_red.vessel_lower{j};
        
        ax(3) = yucca.plot.subplot_tight(3,1,3,margins);
        mat_green = vessels_green.vessel{j};
        mat_red = vessels_red.vessel{j};
        dim = size(mat_green);
        
        % Make a binary image with the perivascular space marked as true.
        img_diam = false(size(mat_green));
        for frame = 1:size(mat_green,2)
            if isnan(st_green(frame)); continue; end
            if isnan(st_red(frame)); continue; end
            img_diam(st_green(frame):st_red(frame),frame) = true;
            img_diam(en_red(frame):en_green(frame),frame) = true;
        end
        
        mat_green = single(mat_green);
        bounds = prctile(mat_green(:),[1,90]);
        mat_green = (mat_green-bounds(1))/(bounds(2)-bounds(1));
        mat_green(mat_green < 0) = 0;
        mat_green(mat_green > 1) = 1;
        
        mat_red = single(mat_red);
        bounds = prctile(mat_red(:),[1,90]);
        mat_red = (mat_red-bounds(1))/(bounds(2)-bounds(1));
        mat_red(mat_red < 0) = 0;
        mat_red(mat_red > 1) = 1;

        img = zeros(dim(1),dim(2),3);
        img(:,:,1) = mat_red;
        img(:,:,2) = mat_green;
        img(:,:,3) = img_diam*0.8;
        
        x = (0:dim(1)-1)*vessels_green.vessel_dx(j);

        imagesc(img,'XData',t,'YData',x);
        cb = colorbar;
        ylabel(cb,'N/A')
        
        xlabel('Time (seconds)');
        ylabel('Length (um)');

        linkaxes(ax,'x');
        xlim([t(1),t(end)])

        set(ax,'FontSize',15)

        % Save
        filename = char(diameter_peri.vessel_name(j));
        % Make folders that separate sleep/wake and vessel types.
        filename = fullfile(trial_type, vessel_type, filename);
        filename = fullfile(eustoma.get_plot_path,'Linescan Diameter Spectrograms Peri',filename);
        begonia.path.make_dirs([filename,'.png']);
        warning off
        export_fig(fig,[filename,'.png'],'-png');
        warning on
        close(fig)
    end
end
