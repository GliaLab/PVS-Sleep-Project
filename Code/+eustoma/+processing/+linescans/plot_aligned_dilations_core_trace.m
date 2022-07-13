begonia.logging.set_level(1);

scans = eustoma.get_linescans();
scans = scans(scans.has_var('core_trace_dilation'));

trials = eustoma.get_linescans_recrig();

dloc_list = yucca.datanode.DataNodeList();
dloc_list.add(trials);
dloc_list.add(scans);

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

core_trace_dilation_tbl = scans.load_var('core_trace_dilation_tbl');
core_trace_dilation_tbl = cat(1,core_trace_dilation_tbl{:});

core_trace_dilation = scans(1).load_var('core_trace_dilation');

diameter_dilation_tbl = scans.load_var('diameter_dilation_tbl');
diameter_dilation_tbl = cat(1,diameter_dilation_tbl{:});

diameter_dilation = scans(1).load_var('diameter_dilation');

%%
N_diameter = height(diameter_dilation_tbl);
nSamples = length(diameter_dilation.t);
diameter_t = diameter_dilation.t;
%%
f = figure;
f.Position(3:4) = [1000,1000];

tiledlayout(5,1,"padding","none")

%
ax1 = nexttile();

red_diameter_avg = mean(diameter_dilation_tbl.red,1);
red_diameter_std = std(diameter_dilation_tbl.red,[],1);
red_diameter_confidence = 1.96 * red_diameter_std / sqrt(N_diameter);

p = plot(diameter_t,red_diameter_avg);
yucca.plot.plot_around_line(p,red_diameter_confidence)
title(sprintf('Lumen diameter change from dilation (average +/- 1.96 sem), N = %.f',N_diameter))
ylabel('Diameter (um)')

%
ax2 = nexttile();

green_diameter_avg = mean(diameter_dilation_tbl.green,1);
green_diameter_std = std(diameter_dilation_tbl.green,[],1);
green_diameter_confidence = 1.96 * green_diameter_std / sqrt(N_diameter);

p = plot(diameter_t,green_diameter_avg);
yucca.plot.plot_around_line(p,green_diameter_confidence)
title(sprintf('Endfoot diameter change from dilation (average +/- 1.96 sem), N = %.f',N_diameter))
ylabel('Diameter (um)')

%
ax3 = nexttile();

pvs_diameter_avg = mean(diameter_dilation_tbl.peri,1);
pvs_diameter_std = std(diameter_dilation_tbl.peri,[],1);
pvs_diameter_confidence = 1.96 * pvs_diameter_std / sqrt(N_diameter);

p = plot(diameter_t,pvs_diameter_avg);
yucca.plot.plot_around_line(p,pvs_diameter_confidence)
title(sprintf('PVS length change from dilation (average +/- 1.96 sem), N = %.f',N_diameter))
ylabel('Diameter (um)')

%
ax4 = nexttile();

core_trace_avg = mean(core_trace_dilation_tbl.core_trace,1);
core_trace_std = std(core_trace_dilation_tbl.core_trace,[],1);
core_trace_confidence = 1.96 * core_trace_std / sqrt(height(core_trace_dilation_tbl));

p = plot(diameter_t,core_trace_avg);
yucca.plot.plot_around_line(p,core_trace_confidence)
title(sprintf('Vessel center fluo. (average +/- 1.96 sem), N = %.f',N_diameter))
ylabel('df/f0')

linkaxes([ax1,ax2,ax3,ax4],'x');

filename = fullfile(eustoma.get_plot_path,'Linescan dilations vessel center avg',"vessel center avg.png");
begonia.path.make_dirs(filename);
exportgraphics(f,filename);
close(f) 
% 
% diameter_t = diameter_t';
% green_diameter_avg = green_diameter_avg';
% green_diameter_std = green_diameter_std';
% green_diameter_confidence = green_diameter_confidence';
% red_diameter_avg = red_diameter_avg';
% red_diameter_std = red_diameter_std';
% red_diameter_confidence = red_diameter_confidence';
% pvs_diameter_avg = pvs_diameter_avg';
% pvs_diameter_std = pvs_diameter_std';
% pvs_diameter_confidence = pvs_diameter_confidence';
% 
% filename = fullfile(eustoma.get_plot_path,'Linescan dilations ECoG avg',"diameter trace.csv");
% diameter_table = table(diameter_t,green_diameter_avg,green_diameter_std,green_diameter_confidence, ...
%     red_diameter_avg,red_diameter_std,red_diameter_confidence, ...
%     pvs_diameter_avg,pvs_diameter_std,pvs_diameter_confidence);
% writetable(diameter_table,filename);
% 
% ecog_t = ecog_t';
% ecog_avg = ecog_avg';
% ecog_std = ecog_std';
% ecog_confidence = ecog_confidence';
% 
% filename = fullfile(eustoma.get_plot_path,'Linescan dilations ECoG avg',"ECoG slow delta trace.csv");
% ecog_table = table(ecog_t,ecog_avg,ecog_std,ecog_confidence);
% writetable(ecog_table,filename);