
begonia.logging.set_level(1);
datastore = fullfile(eustoma.get_data_path,'Endfeet Recrig Data');
engine = begonia.data_management.dans_corner.OffPathEngine(datastore);
rr = engine.get_dlocs();

begonia.logging.log(1,'Filtering trials');
rr = rr(rr.has_var('vessel_baseline_traces'));
%%
for i = 1:length(rr)
    begonia.logging.log(1,'Plotting (%d/%d)',i,length(rr));
    vessels = rr(i).load_var('vessel_baseline_traces');
    episodes = rr(i).load_var('vessel_baseline_episodes');
    % Rename baseline name for plotting.
    episodes.state(:) = 'Baseline Period';
    
    for ves_idx = 1:height(vessels)
        f = figure;
        f.Color = 'w';
        f.Position(3:4) = [1500,600];
        
        margins = [0.08,0.04];
        
        ax(1) = begonia.plot.subplot_tight(3,1,1,margins);
        plot(vessels.t{ves_idx},vessels.distance_endfoot{ves_idx});
        ylabel('Diameter (um)')
        grid on
        h = begonia.plot.plot_episodes(episodes.state,episodes.state_start,episodes.state_end,0.3);
        title(sprintf('%s Endfoot Tube',vessels.vessel_id(ves_idx)))
        plot(xlim,vessels.baseline_endfoot([ves_idx,ves_idx]),'r', ...
            'LineWidth',2, ...
            'DisplayName','Baseline Diameter')
        
        ax(2) = begonia.plot.subplot_tight(3,1,2,margins);
        plot(vessels.t{ves_idx},vessels.distance_lumen{ves_idx});
        ylabel('Diameter (um)')
        grid on
        h = begonia.plot.plot_episodes(episodes.state,episodes.state_start,episodes.state_end,0.3);
        title(sprintf('%s Vessel Lumen',vessels.vessel_id(ves_idx)))
        plot(xlim,vessels.baseline_lumen([ves_idx,ves_idx]),'r', ...
            'LineWidth',2, ...
            'DisplayName','Baseline Diameter')
        
        ax(3) = begonia.plot.subplot_tight(3,1,3,margins);
        plot(vessels.t{ves_idx},vessels.distance_peri{ves_idx});
        ylabel('Width (um)')
        grid on
        h = begonia.plot.plot_episodes(episodes.state,episodes.state_start,episodes.state_end,0.3);
        title(sprintf('%s Perivascular Space',vessels.vessel_id(ves_idx)))
        plot(xlim,vessels.baseline_peri([ves_idx,ves_idx]),'r', ...
            'LineWidth',2, ...
            'DisplayName','Baseline Width')
        
        xlabel('Time (s)')
        filename = sprintf('%s.png',vessels.vessel_id(ves_idx));
        filename = fullfile(eustoma.get_plot_path,'Endfeet Vessel Baseline Traces',filename);
        begonia.path.make_dirs(filename);
        warning off
        export_fig(f,filename);
        warning on
        close(f);
    end
end

begonia.logging.log(1,'Finished');