function [h,r] = plot_episodes(episodes, ax, y_pos, alpha)
if nargin < 2
    ax = gca;
end
if nargin < 3
    y_pos = ax.YLim;
end
if nargin < 4 
    alpha = 0.3;
end
if isempty(y_pos)
    y_pos = ax.YLim;
end

hold on

% Alternative metrics of the y extent of the boxes.
box_y = y_pos(1);
box_height = diff(y_pos);

% Prepare color information. Add if missing.
if ismember("color", episodes.Properties.VariableNames)
    % Make a color table from the episodes.
    [~, ep, r, g, b] = findgroups(episodes.ep, ...
        episodes.color(:,1), episodes.color(:,2), episodes.color(:,3));
    color = [r,g,b];
    color_table = table(ep, color);
else
    unique_episodes = unique(episodes.ep);
    color_table = table;
    color_table.ep = unique_episodes;
    color_table.color = begonia.util.distinguishable_colors(length(unique_episodes));
    
    % Add color information to the episode table.
    episodes = innerjoin(episodes, color_table);
end

% Plot the boxes.
for i = 1:height(episodes)
    pos = [episodes.ep_start(i), box_y, episodes.ep_duration(i), box_height];
    r = rectangle(ax, ...
        'Position', pos, ...
        'FaceColor', [episodes.color(i,:),alpha], ...
        'EdgeColor', 'none');

    % Put the boxes on the bottom of the plot. Does not work for
    % AppDesigner UIFigures. 
    try
        % Problems with making both normal and UI figure work. Fix with try
        % catch. Hopefully works without problems.
        uistack(r, 'bottom');
    catch
    end
end

% legend
for i = 1:height(color_table)
    h(i) = plot(ax, NaN,'square', ...
        'MarkerSize', 10, ...
        'MarkerEdgeColor',color_table.color(i,:), ...
        'MarkerFaceColor',color_table.color(i,:), ...
        'DisplayName', char(color_table.ep(i)));
end
legend(h);

end

