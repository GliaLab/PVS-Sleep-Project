function [f,tbl_scatter_handle] = scatterbox(y,group_1,varargin)
p = inputParser;
p.addRequired('y',...
    @(x) validateattributes(x,{'numeric'},{}));
p.addRequired('group_1',...
    @(x) validateattributes(x,{'categorical','numeric'},{}));
p.addOptional('group_2',[],...
    @(x) validateattributes(x,{'categorical','numeric'},{}));
p.addParameter('overlay','none',...
    @(x) begonia.validators.validatestring(x,{'none','sem','std','confidence'}));
p.addParameter('plot_missing_categories',false,...
    @(x) validateattributes(x,{'logical'},{'nonempty'}));
p.addParameter('style','rand',...
    @(x) begonia.validators.validatestring(x,{'rand'}));
p.parse(y,group_1,varargin{:});
begonia.util.dump_inputParser_vars_to_caller_workspace(p);

if isempty(group_2)
    group_2 = cell(size(group_1));
    group_2(:) = {'do_not_plot_legend'};
    group_2 = categorical(group_2);
end

group_1 = categorical(group_1);
group_2 = categorical(group_2);

if ~plot_missing_categories
    group_1 = removecats(group_1);
    group_2 = removecats(group_2);
end

%% Transform group_1 into numerical values. 
x = grp2idx(group_1);
%% Find the colors that correspond to group_2
[G,grp_2] = findgroups(group_2);
if length(grp_2) == 1
    colors = zeros(length(G),3);
    colors(:,1) = 1;
else
%     colors = begonia.colormaps.turbo(length(grp_2)+2);
%     colors(1,:) = [];
%     colors(end,:) = [];
%     colors = colors(G,:);

    colors = begonia.util.distinguishable_colors(length(grp_2));
    colors = colors(G,:);
end
%% Find new positions of the points 
switch style
    case 'rand'
        y_new = y;
        x_new = x;
end
%% Plot

% f = figure;
hold on
[G,grp_1,grp_2] = findgroups(group_1,group_2);
s = splitapply(@plot_group,x_new,y_new,colors,G);
tbl_scatter_handle = table(grp_1,grp_2,s);

G = findgroups(group_1);
switch overlay
    case 'sem'
        splitapply(@plot_sem,x,y,colors,G);
    case 'std'
        splitapply(@plot_std,x,y,colors,G);
    case 'confidence'
        splitapply(@plot_confidence,x,y,colors,G);
end
hold off

if group_2(1) ~= 'do_not_plot_legend'
    G = findgroups(tbl_scatter_handle.grp_2);
    s = splitapply(@(x)x(1),s,G);
    grp_2 = splitapply(@(x)x(1),grp_2,G);
    legend(s,cellstr(grp_2),'Interpreter','none');
end
%%
cats = categories(group_1);
x_ticks = 1:length(cats);

a = gca;
a.XTick = x_ticks;
a.XTickLabels = cats;
a.XTickLabelRotation = 45;
a.TickLabelInterpreter = 'none';
a.XLim = [x_ticks(1) - 1,x_ticks(end) + 1];

end

function s = plot_group(x,y,colors)
x_spread = 0.6;
x = x + (rand(size(x))-0.5)*x_spread;

s = scatter(x,y);
s.MarkerEdgeColor = 'none';
s.MarkerFaceColor = 'flat';
s.CData = colors(1,:);
s.SizeData = 70;
s.MarkerFaceAlpha = 0.5;
end
%% Error bars
function plot_sem(x,y,colors)
mu = mean(y);
line([x(1)-0.15,x(1)+0.15],[mu,mu],'LineWidth',3,'Color','k');

sigma = std(y)/sqrt(length(y));
line([x(1),x(1)],[mu-sigma,mu+sigma],'LineWidth',2,'Color','k');
line([x(1)-0.1,x(1)+0.1],[mu+sigma,mu+sigma],'LineWidth',2,'Color','k');
line([x(1)-0.1,x(1)+0.1],[mu-sigma,mu-sigma],'LineWidth',2,'Color','k');

end

function plot_confidence(x,y,colors)
mu = mean(y);
line([x(1)-0.15,x(1)+0.15],[mu,mu],'LineWidth',3,'Color','k');

sigma = std(y)/sqrt(length(y)) * 1.96;
line([x(1),x(1)],[mu-sigma,mu+sigma],'LineWidth',2,'Color','k');
line([x(1)-0.1,x(1)+0.1],[mu+sigma,mu+sigma],'LineWidth',2,'Color','k');
line([x(1)-0.1,x(1)+0.1],[mu-sigma,mu-sigma],'LineWidth',2,'Color','k');

end

function plot_std(x,y,colors)
mu = mean(y);
line([x(1)-0.15,x(1)+0.15],[mu,mu],'LineWidth',3,'Color','k');

sigma = std(y);
line([x(1),x(1)],[mu-sigma,mu+sigma],'LineWidth',2,'Color','k');
line([x(1)-0.1,x(1)+0.1],[mu+sigma,mu+sigma],'LineWidth',2,'Color','k');
line([x(1)-0.1,x(1)+0.1],[mu-sigma,mu-sigma],'LineWidth',2,'Color','k');

end