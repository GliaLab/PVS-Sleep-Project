clear all
%%
begonia.logging.set_level(1);
scans = eustoma.get_linescans();
scans = scans(scans.has_var('core_trace'));
scans = scans(scans.has_var('diameter_green_baseline'));

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
for i = 1:length(scans)
    
    diameter_green = scans(i).load_var('diameter_green_baseline');
    core_trace = scans(i).load_var('core_trace');
    episodes = scans(i).load_var('episodes',[]);
    wheel = scans(i).find_dnode('recrig').load_var('wheel');
    
    f = figure;
    f.Position(3:4) = [1350,600];

    tiledlayout(3,1,"padding","none")
    
    ax1 = nexttile(1);
    hold on
    trace = diameter_green.diameter{1};
    t = (0:length(trace)-1) / diameter_green.vessel_fs(1);
    plot(t, trace);
    if ~isempty(episodes)
        sleep_marks = yucca.plot.plot_episodes(episodes.state, ...
            episodes.state_start, ...
            episodes.state_end, ...
            0.6, [], color_table);
    end
    xlabel("Time (s)")
    ylabel("Diameter (um)");
    title(sprintf("Diameter"));
    xlim([0,600])
    
    ax2 = nexttile(2);
    hold on
    trace = core_trace.core_trace{1};
    t = (0:length(trace)-1) / core_trace.vessel_fs(1);
    plot(t, trace);
    if ~isempty(episodes)
        sleep_marks = yucca.plot.plot_episodes(episodes.state, ...
            episodes.state_start, ...
            episodes.state_end, ...
            0.6, [], color_table);
    end
    xlabel("Time (s)")
    ylabel("Raw fluo.");
    title(sprintf("Center fluoresence"));
    xlim([0,600])
    
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
    
    filename = fullfile(eustoma.get_plot_path,'Linescan vessel center traces',string(core_trace.vessel_name)+".png");
    begonia.path.make_dirs(filename);
    exportgraphics(f,filename);
    close(f)
end