begonia.logging.set_level(1);

scans = eustoma.get_linescans();
scans = scans(scans.has_var('eeg_dilation'));

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

eeg_dilation_tbl = scans.load_var('eeg_dilation_tbl');
eeg_dilation_tbl = cat(1,eeg_dilation_tbl{:});

eeg_dilation = scans(1).load_var('eeg_dilation');

diameter_dilation_tbl = scans.load_var('diameter_dilation_tbl');
diameter_dilation_tbl = cat(1,diameter_dilation_tbl{:});

diameter_dilation = scans(1).load_var('diameter_dilation');
%%

spectrogram = cat(3,eeg_dilation_tbl.spectrogram{:});
mid = find(eeg_dilation.t == 0);
spectrogram = spectrogram - spectrogram(:,mid,:);
spectrogram = mean(spectrogram,3);

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

imagesc(eeg_dilation.t,eeg_dilation.f,spectrogram);
colormap(begonia.colormaps.turbo);
cb = colorbar;

ax4.YTickLabelMode = 'auto';
ax4.YTick = [0.1,0.2,0.5,1,2,5,10,20,50];
ax4.YDir = 'normal';
ax4.YScale = 'log';
ylabel('Frequency (Hz)');
title(sprintf("Average ECoG Spectrogram difference compared dilation, N = %d",height(eeg_dilation_tbl)));
% 
ax5 = nexttile();
ecog_t = eeg_dilation.t;
mid_idx = begonia.util.val2idx(ecog_t,0);
slow_delta = eeg_dilation_tbl.slow_delta;
% Offset/align to dilation timepoint. 
slow_delta = slow_delta - slow_delta(:,mid_idx);
N_ecog = size(slow_delta,1);
ecog_avg = mean(slow_delta,1);
ecog_std = std(slow_delta,[],1);
ecog_confidence = 1.96 * ecog_std / sqrt(N_ecog);
p = plot(ecog_t,ecog_avg);
yucca.plot.plot_around_line(p,ecog_confidence)
title(sprintf('ECoG slow delta power 0.2-4 Hz (average +/- 1.96 sem), N = %.f',N_ecog))
ylabel('ECoG power a.u.')

linkaxes([ax1,ax2,ax3,ax4,ax5],'x');

filename = fullfile(eustoma.get_plot_path,'Linescan dilations ECoG avg',"endfoot, lumen, pvs and ecog avg.png");
begonia.path.make_dirs(filename);
exportgraphics(f,filename+".png");
savefig(f,filename+".fig");
close(f) 

diameter_t = diameter_t';
green_diameter_avg = green_diameter_avg';
green_diameter_std = green_diameter_std';
green_diameter_confidence = green_diameter_confidence';
red_diameter_avg = red_diameter_avg';
red_diameter_std = red_diameter_std';
red_diameter_confidence = red_diameter_confidence';
pvs_diameter_avg = pvs_diameter_avg';
pvs_diameter_std = pvs_diameter_std';
pvs_diameter_confidence = pvs_diameter_confidence';

filename = fullfile(eustoma.get_plot_path,'Linescan dilations ECoG avg',"diameter trace.csv");
diameter_table = table(diameter_t,green_diameter_avg,green_diameter_std,green_diameter_confidence, ...
    red_diameter_avg,red_diameter_std,red_diameter_confidence, ...
    pvs_diameter_avg,pvs_diameter_std,pvs_diameter_confidence);
writetable(diameter_table,filename);

ecog_t = ecog_t';
ecog_avg = ecog_avg';
ecog_std = ecog_std';
ecog_confidence = ecog_confidence';

filename = fullfile(eustoma.get_plot_path,'Linescan dilations ECoG avg',"ECoG slow delta trace.csv");
ecog_table = table(ecog_t,ecog_avg,ecog_std,ecog_confidence);
writetable(ecog_table,filename);