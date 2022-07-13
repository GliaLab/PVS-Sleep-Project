function roa_heatmap(trial)

output_folder = '~/Desktop/';
output_folder = fullfile(output_folder,datestr(now,'yyyymmdd'));
output_folder = [output_folder,'_v2_roa_heatmap'];
begonia.path.make_dirs(output_folder)

%%
tr = trial.rec_rig_trial;
ts = trial.tseries;

dt = ts.dt;
fs = 1/dt;
dx = ts.dx;

img_avg = ts.get_avg_img(1,1);
img_avg = begonia.mat_functions.normalize(img_avg);

genotype = tr.load_var('genotype');
%% Plot average img

% f = figure;
% imshow(img_avg);
% a = gca;
% a.CLim = [0,prctile(img_avg(:),99)];
% a.XTickLabel = [];
% a.YTickLabel = [];
% a.XLim = [0,size(img_avg,1)];
% a.YLim = [0,size(img_avg,2)];
% 
% str = sprintf('fov_%d_avg_%s_%s.png', ...
%     ts.load_var('fov_id'), ...
%     trial.genotype, ...
%     trial.trial_id);
% str = fullfile(output_folder,str);
% export_fig(f,str,'-native');
% 
% close(f)


%%
begonia.util.logging.vlog(1,'Loading roa data');
mat = ts.load_var('highpass_roa_mask');
threshold = 0.85; % um^2
mat = begonia.processing.remove_roa_events(mat,dx,threshold);

dim = size(mat);

%%

img_red = zeros(dim(1),dim(2),3);
img_red(:,:,1) = 1;

%% Figure roa density
% 
roa_density_heatmap = nansum(mat,3) / size(mat,3);
ts.save_var(roa_density_heatmap);

% roa_density_heatmap = begonia.mat_functions.normalize(roa_density_heatmap,'limits',[0,0.01]);
% 
% f = figure;
% 
% imshow(img_avg);
% 
% a = gca;
% a.CLim = [0,prctile(img_avg(:),99)];
% 
% hold on
% im = imshow(img_red);
% im.AlphaData = img_density;
% 
% a.XTickLabel = [];
% a.YTickLabel = [];
% a.XLim = [0,dim(1)];
% a.YLim = [0,dim(2)];
% 
% str = sprintf('fov_%d_density_%s_%s.png', ...
%     ts.load_var('fov_id'), ...
%     trial.genotype, ...
%     trial.trial_id);
% str = fullfile(output_folder,str);
% export_fig(f,str,'-native');
% 
% close(f)

%% calculate frequency heatmap

begonia.util.logging.vlog(1,'Finding connected components')
CC = bwconncomp(mat,6);

begonia.util.logging.vlog(1,'Gathering data of each connected component')
roa_frequency_heatmap = zeros(dim(1),dim(2));
tmp = zeros(dim(1),dim(2));
for j = 1:CC.NumObjects
    [x,y,~] = ind2sub(CC.ImageSize,CC.PixelIdxList{j});

    tmp(:) = 0;
    for k = 1:length(x)
        tmp(x(k),y(k)) = 1;
    end
    roa_frequency_heatmap = roa_frequency_heatmap + tmp;
end
% Calculate events / sec per pixel
dur = size(mat,3) * dt;
roa_frequency_heatmap = roa_frequency_heatmap / dur;

ts.save_var(roa_frequency_heatmap)

% Make the pure red color 3 events / min
roa_frequency_heatmap = begonia.mat_functions.normalize(roa_frequency_heatmap*60,'limits',[0,2]);

%% plot freq heatmap
f = figure;

imshow(img_avg);

a = gca;
a.CLim = [0,prctile(img_avg(:),99)];

hold on
im = imshow(img_red);
im.AlphaData = roa_frequency_heatmap;

a.XTickLabel = [];
a.YTickLabel = [];
a.XLim = [0,dim(1)];
a.YLim = [0,dim(2)];

str = sprintf('%s_fov_%d_%s.png', ...
    genotype, ...
    ts.load_var('fov_id'), ...
    trial.trial_id);
str = fullfile(output_folder,str);
pause(0.2)
export_fig(f,str,'-native');

close(f)

end

