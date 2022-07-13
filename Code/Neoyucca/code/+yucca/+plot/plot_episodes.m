function [h,r] = plot_episodes(ep_name,ep_start,ep_end,alpha,y_pos,color_table)
if nargin < 4
    alpha = 0.6;
end
if nargin < 5
    y_pos = [];
end

episodes = table;
episodes.ep_name = categorical(ep_name);
episodes.ep_start = ep_start;
episodes.ep_end = ep_end;

if nargin < 6
    unique_states = unique(ep_name);
    color_table = table;
    color_table.ep_name = unique_states;
    color_table.color = begonia.util.distinguishable_colors(height(color_table));
else
    color_table.ep_name = categorical(color_table.ep_name);
end

episodes = innerjoin(episodes,color_table);
episodes.ep_duration = episodes.ep_end - episodes.ep_start;

hold on

% Boxes
if isempty(y_pos)
    y_pos = ylim();
end
box_y = y_pos(1);
box_height = diff(y_pos);
for i = 1:height(episodes)
    color = [episodes.color(i,:),alpha];
    pos = [episodes.ep_start(i), box_y, episodes.ep_duration(i), box_height];
    if isduration(pos)
        pos = days(pos);
    end
    r = rectangle( ...
        'Position', pos, ...
        'FaceColor', color, ...
        'EdgeColor', 'none');

    uistack(r, 'bottom');
end

% legend
for i = 1:height(color_table)
    h(i) = plot(NaN,'square', ...
        'MarkerSize', 10, ...
        'MarkerEdgeColor',color_table.color(i,:), ...
        'MarkerFaceColor',color_table.color(i,:), ...
        'DisplayName', char(color_table.ep_name(i)));
end
legend(h);
end

