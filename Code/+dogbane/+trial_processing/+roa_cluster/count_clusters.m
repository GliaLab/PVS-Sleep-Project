function count_clusters(trial)
ts = trial.tseries;


%% ROA ignore mask.
if ts.has_var('roa_ignore_mask')
    roa_ignore_mask = ts.load_var('roa_ignore_mask');
else
    mat = ts.get_mat(1,1);
    dim = size(mat);
    roa_ignore_mask = false(dim(1:2));
end
edge_ignore_width = 15;
roa_ignore_mask(1:edge_ignore_width,:) = true;
roa_ignore_mask(end-edge_ignore_width:end,:) = true;
roa_ignore_mask(:,1:edge_ignore_width) = true;
roa_ignore_mask(:,end-edge_ignore_width:end) = true;
% Flips it. Result is true where ROAs are allowed.
roa_ignore_mask = ~roa_ignore_mask;
%%
mask = ts.load_var('highpass_thresh_roa_mask');
mask = mask & roa_ignore_mask;
%%
CC = bwconncomp(mask,4);
%%
tbl_1 = table;
tbl_1.frame = cellfun(@(x)z_index(CC.ImageSize,x),CC.PixelIdxList)';
tbl_1.area = cellfun(@length,CC.PixelIdxList)' * ts.dx * ts.dx;
range(tbl_1.frame)
%%

p = ts.load_var('highpass_thresh_roa_density_trace');
bins = 0:0.05:1;
% bins = [0.35,0.40,0.45,0.50,0.54,0.57,0.58];
I = discretize(p,bins);
frames = find(~isnan(I));
I(isnan(I)) = [];
p = bins(I);
p = reshape(p,[],1);

tbl_2 = table;
tbl_2.frame = frames;
tbl_2.p = p;

% A table with the size and frame of every cluster and the roa density (p) of the
% frame. 
tbl_1 = innerjoin(tbl_2,tbl_1);

[G,roa_cluster_number_density] = findgroups(tbl_1(:,{'p'}));
roa_cluster_number_density_bins = logspace(0,6,6*5+1); %
roa_cluster_number_density.n = splitapply(@(x,y)cluster_number_density(x,y,roa_cluster_number_density_bins),tbl_1.frame,tbl_1.area,G);
roa_cluster_number_density.n = roa_cluster_number_density.n / sum(roa_ignore_mask(:));
roa_cluster_number_density.n = roa_cluster_number_density.n ./ diff(roa_cluster_number_density_bins);

ts.save_var(roa_cluster_number_density)
ts.save_var(roa_cluster_number_density_bins)
end

function t = z_index(SIZ,I)
[~,~,t] = ind2sub(SIZ,I(1));
end

function n = cluster_number_density(frame,area,bins)
n = histcounts(area,bins)/length(unique(frame));
end