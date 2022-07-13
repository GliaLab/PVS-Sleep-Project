begonia.logging.set_level(1);
scans = eustoma.get_linescans();
scans = scans(scans.has_var('clean_episodes'));

%%

episodes = scans.load_var('clean_episodes');
episodes = cat(1,episodes{:});
if ismember("ep",episodes.Properties.VariableNames)
    episodes.state = episodes.ep;
    episodes.state_duration = episodes.ep_end - episodes.ep_start;
end
episodes.state = categorical(episodes.state);
%%

close all force

g = gramm('x',episodes.state_duration,'color',episodes.state);

%Raw data as raster plot
% g.facet_grid(cars.Origin_Region,[]);
g.geom_raster();
g.set_title('geom_raster()');

% %Histogram
% g(1,2).facet_grid(cars.Origin_Region,[]);
% g(1,2).stat_bin('nbins',8);
% g(1,2).set_title('stat_bin()');
% 
% %Kernel smoothing density estimate
% g(2,1).facet_grid(cars.Origin_Region,[]);
% g(2,1).stat_density();
% g(2,1).set_title('stat_density()');
% 
% % Q-Q plot for normality
% g(2,2).facet_grid(cars.Origin_Region,[]);
% g(2,2).stat_qq();
% g(2,2).axe_property('XLim',[-5 5]);
% g(2,2).set_title('stat_qq()');

g.set_names('x','Episode duration (s)','color','','y','');
g.set_title('Duration of episodes');
figure('Position',[100 100 800 550]);
g.draw();