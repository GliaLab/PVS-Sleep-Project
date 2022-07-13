begonia.logging.set_level(1);

ts = eustoma.get_endfoot_tseries();
ts = ts(ts.has_var('roi_dilation'));
ts = ts(ts.has_var('eeg_dilation'));
ts = ts(ts.has_var('diameter_dilation'));

trials = eustoma.get_endfoot_recrigs();

dloc_list = yucca.datanode.DataNodeList();
dloc_list.add(trials);
dloc_list.add(ts);

%%

ep_name = ["REM","IS","NREM"]';
color = [82,28,138; ...
    177,124,246; ...
    117,208,250];
color = color / 256;
sleep_color_table = table(ep_name,color);

%%

roi_dilation = ts.load_var('roi_dilation');
roi_dilation = cat(1,roi_dilation{:});

eeg_dilation_ep = ts.load_var('eeg_dilation_ep');
eeg_dilation_ep = cat(1,eeg_dilation_ep{:});

eeg_dilation = ts(1).load_var('eeg_dilation');

diameter_dilation = ts.load_var('diameter_dilation');
diameter_dilation = cat(1,diameter_dilation{:});
%%
% Aggregate the ROIs per trial as they are so similar.
[G,tbl] = findgroups(roi_dilation(:,["vessel_id","ep_id"]));
tbl.signal = splitapply(@(x)mean(x,1), roi_dilation.signal, G);
tbl.fs = splitapply(@(x)x(1), roi_dilation.fs, G);
roi_dilation = tbl;
%%

f = figure;
f.Position(3:4) = [1000,1000];

tiledlayout(4,1,"padding","none")

ax1 = nexttile();

N_diameter = height(diameter_dilation);
diameter_avg = mean(diameter_dilation.diameter,1);
diameter_std = std(diameter_dilation.diameter,[],1);
diameter_confidence = 1.96 * diameter_std / sqrt(N_diameter);

diameter_t = (0:length(diameter_avg)-1) / diameter_dilation.vessel_fs(1); 
diameter_t = diameter_t - diameter_t(round(length(diameter_t)/2));

p = plot(diameter_t,diameter_avg);
yucca.plot.plot_around_line(p,diameter_confidence)
title(sprintf('Vessel diameter (average +/- 1.96 sem), N = %.f',N_diameter))
ylabel('Diameter (um)')

ax2 = nexttile();

N_rois = height(roi_dilation);
roi_avg = mean(roi_dilation.signal,1);
roi_std = std(roi_dilation.signal,[],1);
roi_confidence = 1.96 * roi_std / sqrt(N_rois);

roi_t = (0:length(roi_avg)-1) / roi_dilation.fs(1); 
roi_t = roi_t - roi_t(round(length(roi_t)/2));

p = plot(roi_t,roi_avg);
yucca.plot.plot_around_line(p,roi_confidence)
title(sprintf('Glt1 ROI df/f0 (average +/- 1.96 sem), N = %.f',N_rois))
ylabel('df/f0')

ax3 = nexttile();

spectrogram = cat(3,eeg_dilation_ep.spectrogram{:});
mid = round(size(spectrogram,2)/2);
spectrogram = spectrogram - spectrogram(:,mid,:);
spectrogram = mean(spectrogram,3);

imagesc(eeg_dilation.t,eeg_dilation.f,spectrogram);
colormap(begonia.colormaps.turbo);
cb = colorbar;

ax3.YTickLabelMode = 'auto';
ax3.YTick = [0.1,0.2,0.5,1,2,5,10,20,50];
ax3.YDir = 'normal';
ax3.YScale = 'log';
ylabel('Frequency (Hz)');
title(sprintf("Average ECoG Spectrogram difference compared t = 0, N = %d",height(eeg_dilation_ep)));

ax4 = nexttile();
ecog_t = eeg_dilation.t;
mid_idx = begonia.util.val2idx(ecog_t,0);
slow_delta = eeg_dilation_ep.slow_delta;
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

linkaxes([ax1,ax2,ax3,ax4],'x');
xlim([diameter_t(1),diameter_t(end)])

filename = fullfile(eustoma.get_plot_path,"Endfeet Vessel diameter and ROI traces around dilation average", ...
    "Average ROI and diameter traces");
begonia.path.make_dirs(filename);
exportgraphics(f,filename+".png");
savefig(f,filename+".fig");
close(f) 

diameter_t = diameter_t';
diameter_avg = diameter_avg';
diameter_std = diameter_std';
diameter_confidence = diameter_confidence';

filename = fullfile(eustoma.get_plot_path,"Endfeet Vessel diameter and ROI traces around dilation average", ...
    "Diameter trace.csv");
diameter_table = table(diameter_t,diameter_avg,diameter_std,diameter_confidence);
writetable(diameter_table,filename);

roi_t = roi_t';
roi_avg = roi_avg';
roi_confidence = roi_confidence';
roi_std = roi_std';

filename = fullfile(eustoma.get_plot_path,"Endfeet Vessel diameter and ROI traces around dilation average", ...
    "ROI trace.csv");
roi_table = table(roi_t,roi_avg,roi_std,roi_confidence);
writetable(roi_table,filename);

ecog_t = ecog_t';
ecog_avg = ecog_avg';
ecog_std = ecog_std';
ecog_confidence = ecog_confidence';

filename = fullfile(eustoma.get_plot_path,"Endfeet Vessel diameter and ROI traces around dilation average", ...
    "ECoG slow delta trace.csv");
ecog_table = table(ecog_t,ecog_avg,ecog_std,ecog_confidence);
writetable(ecog_table,filename);
