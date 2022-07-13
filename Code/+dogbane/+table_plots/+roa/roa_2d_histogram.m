function roa_2d_histogram(tbl_roa_events)
output_folder = '~/Desktop/sleep_project/roa_hist2d';
begonia.path.make_dirs(output_folder)
%%

edges_size      = logspace(0,5,5*10 + 1);
edges_duration  = logspace(-1,2,3*10 + 1);

% Histcounts per trial.
[G,genotype,state] = findgroups(tbl_roa_events.genotype,tbl_roa_events.state);
N = splitapply(@(roa_size,roa_dur) {histcounts2(roa_size,roa_dur,edges_size,edges_duration)}, tbl_roa_events.roa_xy_size, tbl_roa_events.roa_dur, G);

% Add another group. 
genotype(end+1) = 'wt_dual';
state(end+1) = 'all_states';
I = tbl_roa_events.genotype == 'wt_dual';
N{end+1} = histcounts2(tbl_roa_events.roa_xy_size(I), tbl_roa_events.roa_dur(I),edges_size,edges_duration);

edges_size(1) = [];
edges_duration(1) = [];

%%
for i = 1:length(genotype)
    f = figure;
    imagesc(log10(N{i}))
    t = title(sprintf('%s : %s',genotype(i),state(i)));
    t.Interpreter = 'none';
    set(gca,'YDir','normal');
%     set(gca,'CLim',[-12,4]);
    set(gca,'YTick',[1,10:10:length(edges_size)]);
    set(gca,'YTickLabels',num2cell(edges_size(get(gca,'YTick'))));
    set(gca,'XTick',[1,10:10:length(edges_duration)]);
    set(gca,'XTickLabels',num2cell(edges_duration(get(gca,'XTick'))));
    set(gca,'XTickLabelRotation',45)
    ylabel('ROA Size (um^2)')
    xlabel('ROA Duration (s)')
    
    colorbar
    
    % Save figure
    file_name = sprintf('2d_hist_%s_%s',genotype(i),state(i));
    file_name = fullfile(output_folder,file_name);
    export_fig(f,file_name,'-native');
    
    % Save figure
    file_name = sprintf('2d_hist_%s_%s.fig',genotype(i),state(i));
    file_name = fullfile(output_folder,file_name);
    export_fig(f,file_name);
end

end