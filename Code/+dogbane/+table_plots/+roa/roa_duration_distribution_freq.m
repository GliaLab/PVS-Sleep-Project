function roa_duration_distribution_freq(table_roa_distributions)
table_roa_distributions(table_roa_distributions.state == 'undefined',:) = [];

%% Calculate one (weighted) distribution per genotype and state.
[G,genotype,state] = findgroups(table_roa_distributions.genotype,table_roa_distributions.state);
roa_dur_N_norm = splitapply(@(N,w) sum(N .* w,1) ./ sum(w), ...
    table_roa_distributions.roa_dur_N_norm, ...
    table_roa_distributions.state_duration .* table_roa_distributions.fov_area, ...
    G);
roa_dur_bin_edges = splitapply(@(x) x(1,:), ...
    table_roa_distributions.roa_dur_bin_edges, ...
    G);
table_roa_distributions = table(genotype,state,roa_dur_N_norm,roa_dur_bin_edges);
%%
output_folder = '~/Desktop/sleep_project/roa_distributions';
begonia.path.make_dirs(output_folder)
%% Plot 
% Setup figure
f = figure;
f.Position(3:4) = [1000,800];
ylabel('Frequency (events / 100um^2 / min)');
xlabel('ROA Duration (s)');

a = gca;
a.FontSize = 20;

xlim([1e-2,1e6])
a.XScale = 'log';
a.YScale = 'log';

% Plot wt_dual
cla
title(sprintf('ROA Frequency by Duration : wt_dual'),'interpreter','none');
hold on
I = find(table_roa_distributions.genotype == 'wt_dual')';
for i = I
    x = table_roa_distributions.roa_dur_bin_edges(i,2:end);
    y = table_roa_distributions.roa_dur_N_norm(i,:) * 100 * 60;
    state = char(table_roa_distributions.state(i));
    
    state_color = alyssum_v2.constants.state_names_short2colors(state);
    state = alyssum_v2.constants.state_names_short2long(state);
    
    p = plot(x,y,'-o','DisplayName',state);
    p.LineWidth = 3;
    p.MarkerSize = 6;
    p.MarkerEdgeColor = 'none';
    p.MarkerFaceColor = 'k';
    p.Color = state_color;
end
l = legend();
l.Interpreter = 'none';

file_name = fullfile(output_folder,'roa_duration_distribution_wt_dual.png');
export_fig(file_name);
file_name = fullfile(output_folder,'roa_duration_distribution_wt_dual.fig');
export_fig(file_name);

% Plot ip3_dual
cla
title(sprintf('ROA Frequency by Duration : ip3_dual'),'interpreter','none');
hold on
I = find(table_roa_distributions.genotype == 'ip3_dual')';
for i = I
    x = table_roa_distributions.roa_dur_bin_edges(i,2:end);
    y = table_roa_distributions.roa_dur_N_norm(i,:) * 100 * 60;
    state = char(table_roa_distributions.state(i));
    
    state_color = alyssum_v2.constants.state_names_short2colors(state);
    state = alyssum_v2.constants.state_names_short2long(state);
    
    p = plot(x,y,'-o','DisplayName',state);
    p.LineWidth = 3;
    p.MarkerSize = 6;
    p.MarkerEdgeColor = 'none';
    p.MarkerFaceColor = 'k';
    p.Color = state_color;
end
l = legend();
l.Interpreter = 'none';

file_name = fullfile(output_folder,'roa_duration_distribution_ip3_dual.png');
export_fig(file_name);
file_name = fullfile(output_folder,'roa_duration_distribution_ip3_dual.fig');
export_fig(file_name);

% Plot states
states = unique(table_roa_distributions.state)';

for state = states
    state = char(state);
    
    cla
    title(sprintf('ROA Frequency by Duration : %s',state),'interpreter','none');
    hold on
    I = find(table_roa_distributions.state == state)';
    for i = I
        x = table_roa_distributions.roa_dur_bin_edges(i,2:end);
        y = table_roa_distributions.roa_dur_N_norm(i,:) * 100 * 60;
        genotype = char(table_roa_distributions.genotype(i));

        p = plot(x,y,'-o','DisplayName',genotype);
        p.LineWidth = 3;
        p.MarkerSize = 6;
        p.MarkerEdgeColor = 'none';
        p.MarkerFaceColor = 'k';
    end
    l = legend();
    l.Interpreter = 'none';
    
    file_name = sprintf('roa_duration_distribution_%s.png',state);
    file_name = fullfile(output_folder,file_name);
    export_fig(file_name);
    file_name = sprintf('roa_duration_distribution_%s.fig',state);
    file_name = fullfile(output_folder,file_name);
    export_fig(file_name);
end
end

