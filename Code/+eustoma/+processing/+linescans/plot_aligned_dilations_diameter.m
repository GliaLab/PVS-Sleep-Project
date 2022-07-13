begonia.logging.set_level(1);

scans = eustoma.get_linescans();
scans = scans(scans.has_var('diameter_dilation'));

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
    diameter_dilation = scans(i).load_var('diameter_dilation');
    diameter_dilation_tbl = scans(i).load_var('diameter_dilation_tbl');
    trial_id = scans(i).load_var('trial_id');
    trial_id = trial_id.trial_id;
    
    diameter_red = scans(i).load_var('diameter_red_baseline');
    
    episodes = scans(i).load_var('episodes',[]);
    
    % Add color values to each dilation.
    diameter_dilation_tbl.color = turbo(height(diameter_dilation_tbl));
    
    % Assign variables from the input data.
    diameter = diameter_red.diameter{1};
    diameter_t = (0:length(diameter)-1) / diameter_red.vessel_fs;
    red = diameter_dilation_tbl.red;
    green = diameter_dilation_tbl.green;
    peri = diameter_dilation_tbl.peri;
    t = diameter_dilation.t;
    
    % Find the index of the dilation.
    mid = begonia.util.val2idx(t,0);
    
    % Offset the slow delta amplitude by the value at dilation.
    red = red - red(:,mid);
    green = green - green(:,mid);
    peri = peri - peri(:,mid);
    
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
    for j = 1:height(diameter_dilation_tbl)
        t0 = diameter_dilation_tbl.t0(j);
        plot([t0,t0], [y_limits(1),y_limits(2)],'--', ...
            "Color", diameter_dilation_tbl.color(j,:), ...
            "LineWidth", 2);
    end
    title("Vessel lumen diameter")
    ylabel("Diameter (um)");
    xlabel("Time (s)");
    xlim([diameter_t(1),diameter_t(end)]);
    ax(1).XMinorTick = "On";
    
    ax(2) = nexttile;
    hold on
    p = gobjects(0);
    for j = 1:height(diameter_dilation_tbl)
        p(j) = plot(t,green(j,:),"Color",diameter_dilation_tbl.color(j,:),"LineWidth",1);
    end
    ylabel("Diameter (um)")
    title("Endfoot tube diameter aligned to dilation")
    
    ax(3) = nexttile;
    hold on
    p = gobjects(0);
    for j = 1:height(diameter_dilation_tbl)
        p(j) = plot(t,red(j,:),"Color",diameter_dilation_tbl.color(j,:),"LineWidth",1);
    end
    ylabel("Diameter (um)")
    title("Lumen diameter aligned to dilation")
    
    ax(4) = nexttile;
    hold on
    p = gobjects(0);
    for j = 1:height(diameter_dilation_tbl)
        p(j) = plot(t,peri(j,:),"Color",diameter_dilation_tbl.color(j,:),"LineWidth",1);
    end
    ylabel("Length (um)")
    title("PVS aligned to dilation")
    
    filename = fullfile(eustoma.get_plot_path,'Linescan dilations per trial diameter',trial_id+".png");
    begonia.path.make_dirs(filename);
    exportgraphics(fig,filename);
    close(fig)
end