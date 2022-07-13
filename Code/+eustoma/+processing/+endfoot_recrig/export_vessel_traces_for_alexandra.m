
begonia.logging.set_level(1);
datastore = fullfile(eustoma.get_data_path,'Endfeet Recrig Data');
engine = begonia.data_management.dans_corner.OffPathEngine(datastore);
rr = engine.get_dlocs();

begonia.logging.log(1,'Filtering trials');
rr = rr(rr.has_var('vessel_baseline_traces'));
%%
vessel_name = 'M2 VDX 20 Artery';
[data,i] = find_vessel_traces_by_id(rr,vessel_name);

%%
output_dir = fullfile(eustoma.get_plot_path,'Endfeet Vessel Traces for Alexandra');
%%
episodes = rr(i).load_var('sleep_episodes');
filename = fullfile(output_dir,'sleep_episodes.csv');
begonia.util.save_table(filename,episodes);

%%
tbl = table(data.t',data.distance_endfoot',data.distance_lumen',data.distance_peri', ...
    'VariableNames',{'Time','EndfootTube','VesselLumen','Perivascular'});

filename = fullfile(output_dir,'traces.csv');
begonia.util.save_table(filename,tbl);
%%

f = figure;
f.Color = 'w';
f.Position(3:4) = [1500,600];

margins = [0.08,0.04];

ax(1) = begonia.plot.subplot_tight(2,1,1,margins);
hold on
p1 = plot(data.t,data.distance_endfoot,'DisplayName','Endfoot Tube');
p2 = plot(data.t,data.distance_lumen,'DisplayName','Vessel Lumen');

ylabel('Diameter (um)')
grid on

h = begonia.plot.plot_episodes(episodes.state,episodes.state_start,episodes.state_end,0.3);

legend([p1,p2,h]);

title(sprintf('%s Endfoot Tube & Vessel Lumen',data.vessel_id))

ax(2) = begonia.plot.subplot_tight(2,1,2,margins);
plot(data.t,data.distance_peri);
ylabel('Width (um)')
grid on
h = begonia.plot.plot_episodes(episodes.state,episodes.state_start,episodes.state_end,0.3);
title(sprintf('%s Perivascular Space',data.vessel_id))

xlabel('Time (s)')
filename = fullfile(output_dir,'Vessel traces.png');
begonia.path.make_dirs(filename);
warning off
export_fig(f,filename);
warning on
close(f);

begonia.logging.log(1,'Finished');
%%
function [data,i] = find_vessel_traces_by_id(rr,vessel_name)
for i = 1:length(rr)
    tbl = rr(i).load_var('vessel_baseline_traces');
    for j = 1:height(tbl)
        if tbl.vessel_id(j) == vessel_name
            data = tbl(j,:);
            data = table2struct(data);
            return;
        end
    end
end

data = [];
i = [];

end