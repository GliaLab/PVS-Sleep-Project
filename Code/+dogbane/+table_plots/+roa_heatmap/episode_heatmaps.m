function episode_heatmaps(tbl_roa_heatmaps_per_ep)

I = ismember(tbl_roa_heatmaps_per_ep.state,{'nrem','is','rem'});
tbl_roa_heatmaps_per_ep = tbl_roa_heatmaps_per_ep(I,:);

[G,fov_id,state] = findgroups( ...
    tbl_roa_heatmaps_per_ep.fov_id, ...
    tbl_roa_heatmaps_per_ep.state);

splitapply(@merged_heatmap, ...
    tbl_roa_heatmaps_per_ep.img_roa_frequency, ...
    tbl_roa_heatmaps_per_ep.fov_id, ...
    tbl_roa_heatmaps_per_ep.state, ...
    tbl_roa_heatmaps_per_ep.state_duration, ...
    tbl_roa_heatmaps_per_ep.avg_img, ...
    tbl_roa_heatmaps_per_ep.roa_ignore_mask, ...
    G);

end

function merged_heatmap(imgs,fov_id,state,state_duration,avg_imgs,mask)
if length(imgs) < 2
    return;
end

fov_id = fov_id(1);
state = state(1);

folder = '~/Desktop/sleep_project/heatmaps/episode_heatmaps/';
filename = sprintf('%s_fov_%d.png',state,fov_id);
path = fullfile(folder,filename);

begonia.path.make_dirs(path);

dim = size(imgs{1});

heatmap = zeros(dim);
for i = 1:length(imgs)
    heatmap = heatmap + (imgs{i} > 0);
end

f = figure;
f.Position(3:4) = [1200,500];

ax(1) = subplot(1,2,1);
imagesc(heatmap);

N = length(imgs);
colormap(begonia.colormaps.turbo(N+1));
cb = colorbar;
cb.Ticks = 0:N;
caxis([-0.5,N+0.5]);

hold on
img_flat = zeros(dim(1),dim(2),3);
img_flat(:,:,:) = 1;
im = imshow(img_flat);
im.AlphaData = mask{1};

axis equal

state_long = dogbane.constants.state_names_short2long(char(state));
str_dur = sprintf('%g, ',state_duration);
str = sprintf('%d %s episodes : Duration [%s] s',length(imgs),state_long,str_dur(1:end-2));
title(str);

ax(2) = subplot(1,2,2);
imagesc(avg_imgs{1});
colormap(ax(2),begonia.colormaps.turbo);

hold on
img_flat = zeros(dim(1),dim(2),3);
img_flat(:,:,:) = 1;
im = imshow(img_flat);
im.AlphaData = mask{1};

axis equal

set(ax,'XTickLabel',[])
set(ax,'YTickLabel',[])
set(ax,'XLim',[0,dim(1)])
set(ax,'YLim',[0,dim(2)])
set(ax,'FontSize',20)

export_fig(f,path,'-native');
close(f)

end