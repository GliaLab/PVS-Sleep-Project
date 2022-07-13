ts = eustoma.get_sleep_tseries();
ts = ts(ts.has_var('recrig'));
ts = ts(ts.has_var('state_episodes'));

start_times = ts.load_var('start_time');
start_times = [start_times{:}];
[~,I] = sort(start_times);
ts = ts(I);

color_table = table;
color_table.ep_name = categorical({'locomotion','whisking','quiet','nrem','is','rem'}');
color_table.color = begonia.util.distinguishable_colors(height(color_table));
%%
rows = 10;
cnt = 1;
for i = 1:rows:length(ts)
    f = figure;
    f.Position(3:4) = [1500,800];
    ax = gca;
    ax.Color = 'none';
    ax.YAxis.Visible = false;
    hold on
    for j = 1:rows
        trial_index = i + j - 1;
        if trial_index > length(ts)
            break;
        end
        
        state_episodes = ts(trial_index).load_var('state_episodes');
        yucca.plot.plot_episodes(state_episodes.State, ...
            state_episodes.StateStart, ...
            state_episodes.StateEnd, ...
            0.6,[j,j+0.75],color_table);
        text(0,j+0.75/2,ts(trial_index).load_var('path'),'FontSize',22,'Interpreter','none');
    end
    ax.FontSize = 22;
    axis('tight');
    
    
    % Save
    filename = sprintf('Plot %d',cnt);
    filename = fullfile(eustoma.get_plot_path,'Sleep Project States','Stacked Episodes',filename);
    filename = [filename,'.png'];
    begonia.path.make_dirs(filename);
    warning off
    export_fig(f,filename,'-png');
    warning on
    close(f)
    cnt = cnt + 1;
end
