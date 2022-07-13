clear all
%%
begonia.logging.set_level(1);
trials = eustoma.get_linescans_recrig();
trials = trials(trials.has_var('trial_type'));
trials = trials(trials.has_var('trial_id'));

trial_type = trials.load_var('trial_type');
trial_type = string(trial_type);
trials = trials(trial_type == "Awake");

%%
ep_name = ["Locomotion","Whisking","Quiet"]';
color = zeros(0,3);
color(end+1,:) = [230,0,0];
color(end+1,:) = [230,230,0];
color(end+1,:) = [39,143,144];
color = color / 256;
color_table = table(ep_name,color);

o = cell(length(trials),1);

tic
for i = 1:length(trials)
    if i == 1 || i == length(trials) || toc > 10
        begonia.logging.log(1,"Trial %2.d/%2.d", i, length(trials));
    end
    
    wheel = trials(i).load_var("wheel");
    trial_id = trials(i).load_var('trial_id');
    episodes = trials(i).load_var('wakefulness_episodes',[]);
    
    camera_traces = trials(i).load_var("camera_traces",[]);
    if ~isempty(camera_traces)
        camera_whisking = camera_traces.camera_absdiff{2};
        camera_t = camera_traces.camera_t{2};

        % Calculate filtered traces.
        [camera_whisking_filt, camera_t_filt, camera_fs_filt] = ...
            eustoma.processing.linescans_recrig.calc_wakefulness_filter_whisking( ...
            camera_whisking, camera_t);
    end
    
    o{i} = trial_id;
    o{i}.max_speed = max(wheel.wheel_speed);
    o{i}.avg_speed = mean(wheel.wheel_speed);
    
    f = figure;
    f.Position(3:4) = [1000, 400] * 2;
    
    tiledlayout(3, 1, "Padding", "tight", "TileSpacing", "tight");
    
    nexttile
    plot(seconds(wheel.Time), wheel.wheel_speed)
    ylim([-3,15])
    xlim([0,600])
    title("Wheel speed")
    ylabel("Degrees per second")
    if ~isempty(episodes)
        yucca.plot.plot_episodes( ...
            episodes.state, ...
            episodes.state_start, ...
            episodes.state_end,0.5,[],color_table);
    end
    
    nexttile
    if ~isempty(camera_traces)
        plot(camera_t_filt,camera_whisking_filt)
        ylim([-2,10])
        xlim([0,600]);
        title("Whisking filtered")
        ylabel("Pixel absdiff")
        if ~isempty(episodes)
            yucca.plot.plot_episodes( ...
                episodes.state, ...
                episodes.state_start, ...
                episodes.state_end,0.5,[],color_table);
        end
    end
    
    nexttile
    if ~isempty(camera_traces)
        plot(camera_t,camera_whisking)
        ylim([-2,10])
        xlim([0,600]);
        title("Whisking raw")
        ylabel("Pixel absdiff")
        if ~isempty(episodes)
            yucca.plot.plot_episodes( ...
                episodes.state, ...
                episodes.state_start, ...
                episodes.state_end,0.5,[],color_table);
        end
    end
    xlabel("Seconds (s)")
    
    % Save
    filename = fullfile(eustoma.get_plot_path,'Linescan behavior traces (awake only)',trial_id.trial_id + ".png");
    begonia.path.make_dirs(filename);
    exportgraphics(f,filename);
    close(f)
    
end
%%
% tbl = struct2table([o{:}],'AsArray',true);
% 
% g = gramm('y',tbl.max_speed,'x',tbl.avg_speed,'color',categorical(tbl.mouse));
% g.geom_jitter();
% % g.facet_grid(categorical(tbl.genotype),categorical(tbl.vessel_type));
% g.set_names('x','Average speed','y','Max speed', 'color','');
% % g.set_title('Lumen diameter change from baseline');
% g.axe_property('TickDir','out','YGrid','on','XGrid','on','GridColor',[0.5 0.5 0.5]);
% g.draw();
% f = gcf;
% f.Position = [10,50,600,500];
% 
% filename = fullfile(eustoma.get_plot_path,'Linescan wheel time series (awake only)',"Mouse speeds.png");
% exportgraphics(f,filename);
% close(f)

