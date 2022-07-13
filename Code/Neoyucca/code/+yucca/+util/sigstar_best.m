function h = sigstar_best(varargin)
p = inputParser;
p.addRequired('groups', ...
    @(x) validateattributes(x,{'numeric'},{}));
p.addRequired('p_values', ...
    @(x) validateattributes(x,{'numeric'},{}));
p.addOptional('ax', gca, ...
    @(x) validateattributes(x,{'matlab.graphics.axis.Axes'},{}));
p.addOptional('sort_bars', true, ...
    @(x) validateattributes(x,{'logical'},{}));

p.parse(varargin{:})
begonia.util.dump_inputParser_vars_to_caller_workspace(p);

assert(size(groups,1) == length(p_values),'Each comparison must have a p_value');

% Remove nan p values
groups(isnan(p_values),:) = [];
p_values(isnan(p_values)) = [];

% Remove self comparisons if they are there
del = groups(:,1) == groups(:,2);
groups(del,:) = [];
p_values(del) = [];

% Remove permutations and sort such that the first group is lower than the
% second group.
groups = sort(groups,2);
[groups,ia,~] = unique(groups,'rows');
p_values = p_values(ia);

% Insert a pause because the hidden property bar.XOffset is not create
% when bar is called. 
pause(0.1)
if ~isempty(findobj(ax,'Type','ErrorBar'))
    go = findobj(ax,'Type','ErrorBar');
    y_data = [go.YData] + [go.YPositiveDelta];
    x_data = [go.XData];
elseif ~isempty(findobj(ax,'Type','Bar'))
    go = findobj(ax,'Type','Bar');
    
    y_data = [go.YData];
    x_data = [go.XData];
%     y_data = [];
%     x_data = [];
%     for i = 1:length(go)
%         x_data = [x_data,go(i).XData + go(i).XOffset];
%         y_data = [y_data,go(i).YData];
%     end
else
    error('Cannot find any bar objects.');
end

[~,I] = sort(x_data);
x_data = x_data(I);
y_data = y_data(I);


if sort_bars
    % Sort by the first group (left)
    [~,I] = sort(groups(:,1),1);
    groups = groups(I,:);
    p_values = p_values(I);
    
    % Sort by bar length
    [~,I] = sort(abs(x_data(groups(:,2)) - x_data(groups(:,1))),'ascend');
    groups = groups(I,:);
    p_values = p_values(I);
    
    % Sort again by height.
    heights = zeros(size(groups,1),1);
    for i = 1:size(groups,1)
        heights(i) = max(y_data(groups(i,1):groups(i,2)));
    end
    [~,I] = sort(heights);
    groups = groups(I,:);
    p_values = p_values(I);
    
end

y_lim = ylim;
y_offset = (y_lim(2) - y_lim(1))*0.03;

y_data = y_data + y_offset;

h = [];
hold on
for i = 1:size(groups,1)
    g_1 = groups(i,1);
    g_2 = groups(i,2);
    y = max(y_data(g_1:g_2));
    
    x_1 = x_data(g_1);
    x_2 = x_data(g_2);
    
    h(i,:) = makeSignificanceBar([x_1,x_2],y,p_values(i));
    
    % Update the highest y value at this group for the next significance
    % bar.
    y_data(g_1:g_2) = y + y_offset;
end
hold off


%Now we can add the little downward ticks on the ends of each line. We are
%being extra cautious and leaving this it to the end just in case the y limits
%of the graph have changed as we add the highlights. The ticks are set as a
%proportion of the y axis range and we want them all to be the same the same
%for all bars.
% y_offset = y_lim(2)/20;

% for i=1:length(groups)
%     y=get(H(i,1),'YData');
%     x=get(H(i,1),'XData');
%     
%     x1 = x(1);
%     x2 = x(end);
%     ix1 = find(x_vals == x1); 
%     ix2 = find(x_vals == x2); 
% 
%     y(1) = top_bar(x_vals == x1)+3*y_offset;
%     y(2) = max(top_bar(find(x_vals == x1):find(x_vals == x2)))+4*y_offset;
%     y(3) = y(2);
%     y(4) = top_bar(x_vals == start_stop(i, 2))+3*y_offset;
%     y2 = get(H(i,2),'Position');
%     y2(2) = y(2)+y_offset/5;
% 
%     top_bar(ix1:ix2) = y(2);  
%     
%     set(H(i,1),'YData',y);
%     set(H(i,2),'Position', y2);
% end


end

function H = makeSignificanceBar(x,y,p)
    %makeSignificanceBar produces the bar and defines how many asterisks we get for a 
    %given p-value

    if p<=1E-3
        stars='***'; 
    elseif p<=1E-2
        stars='**';
    elseif p<=0.05
        stars='*';
    else 
        stars='n.s.';
    end
    
    H(1) = plot(x,[y,y],'-k','LineWidth',2,'Tag','sigstar_bar');

    %Increase offset between line and text if we will print "n.s."
    %instead of a star. 
    if strcmp(stars,'n.s.')
        offset = 0.03;
    else
        offset = 0.01;
    end
    
    y_lim = ylim;
    y_range = y_lim(2) - y_lim(1);

    y_star = y + y_range * offset;
    H(2) = text(mean(x),y_star,stars,...
        'HorizontalAlignment','Center',...
        'BackGroundColor','none',...
        'Tag','sigstar_stars', 'FontSize',14);


end 