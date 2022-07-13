function tbl = roa_percent_heatmap_correlation_subfunc(tbl_heatmaps,s_1,s_2)
%% Find all the valid comparisons
N = height(tbl_heatmaps);
comparisons = nan(N * N,2);
I = tbl_heatmaps.state' == s_1;
I = find(I);

cnt = 0;
for i = I
    
    % false in the following comparisons represents an invalid comparison.
    % Only compare the same FOV.
    J = tbl_heatmaps.fov_id(i) == tbl_heatmaps.fov_id';
    % Only compare the correct states
    J = J & s_2 == tbl_heatmaps.state';
    % If the state is the same, do not compare more than once
    if isequal(s_1,s_2)
        J = J & i < 1:N;
    end
    % Never compare to self
    J(i) = false;
    
    J = find(J);
    
    for j = J
        cnt = cnt + 1;
        
        comparisons(cnt,1) = i;
        comparisons(cnt,2) = j;
    end
end

comparisons = comparisons(1:cnt,:);
%%
overlap = nan(size(comparisons,1),1);
fov_id = nan(size(comparisons,1),1);
state_1 = cell(size(comparisons,1),1);
state_2 = cell(size(comparisons,1),1);

begonia.util.logging.backwrite();
for idx = 1:size(comparisons,1)
    begonia.util.logging.backwrite(1,sprintf('comparing %s to %s (%d/%d)',s_1,s_2,idx,size(comparisons,1)));
    
    i = comparisons(idx,1);
    j = comparisons(idx,2);
    
    img_1 = tbl_heatmaps.img_roa_frequency{i};
    img_2 = tbl_heatmaps.img_roa_frequency{j};
        
    img_intersect = min(img_1,img_2);
    img_union = max(img_1,img_2);
    c = sum(img_intersect(:))/sum(img_union(:));
    
    overlap(idx) = c;
    fov_id(idx) = tbl_heatmaps.fov_id(i);
    state_1{idx} = char(tbl_heatmaps.state(i));
    state_2{idx} = char(tbl_heatmaps.state(j));
end

%%

I = isnan(overlap);
if any(I)
    begonia.util.logging.vlog(1,sprintf('Found %d NaN coefficents, ignoring.',sum(I)));
end

N = sum(~I);
mu = nanmean(overlap);
sigma = nanstd(overlap)/sqrt(N);

tbl = table(fov_id,state_1,state_2,overlap);
tbl.state_1 = categorical(tbl.state_1);
tbl.state_2 = categorical(tbl.state_2);
tbl(I,:) = [];

%%
if ~isempty(overlap)
    plot_coeff = mu;
    
    idx = begonia.util.val2idx(overlap,plot_coeff);
    c = overlap(idx);

    i = comparisons(idx,1);
    j = comparisons(idx,2);

    img_1 = tbl_heatmaps.img_roa_frequency{i};
    img_2 = tbl_heatmaps.img_roa_frequency{j};
    
    fov_id = tbl_heatmaps.fov_id(i);

    dim = size(img_1);

    im_merged = zeros(dim(1),dim(2),3);
    im_merged(:,:,1) = img_1;
    im_merged(:,:,3) = img_2;

    im_overlap = double(min(img_1,img_2)); % convert to float 0 to 1. 
    
    im_avg = tbl_heatmaps.avg_img{i};

    % Plot
    f = figure;
    f.Position(3:4) = [800,860];
    
    ax = begonia.util.tight_subplot(2,2);
    
    % Ax 1
    
    axes(ax(1))
    
    imshow(im_avg);

    a = gca;
    a.CLim = [0,prctile(im_avg(:),99)];

    hold on
    
    im_solid = zeros(dim(1),dim(2),3);
    im_solid(:,:,1) = 1;
    
    im_handle = imshow(im_solid);
    im_handle.AlphaData = begonia.mat_functions.normalize(img_1);
    
    title(s_1)
    
    % Ax 2
    
    axes(ax(2))
    
    imshow(im_avg);

    a = gca;
    a.CLim = [0,prctile(im_avg(:),99)];

    hold on
    
    im_solid = zeros(dim(1),dim(2),3);
    im_solid(:,:,3) = 1;
    
    im_handle = imshow(im_solid);
    im_handle.AlphaData = begonia.mat_functions.normalize(img_2);
    
    title(s_2)
    
    % Ax 3
    
    axes(ax(3))

    imshow(im_merged)
    
    title('Merged')
    
    axes(ax(4))
    
    imshow(im_avg);

    a = gca;
    a.CLim = [0,prctile(im_avg(:),99)];

    hold on
    
    im_solid = zeros(dim(1),dim(2),3);
    im_solid(:,:,1) = 1;
    im_solid(:,:,3) = 1;
    
    im_handle = imshow(im_solid);
    im_handle.AlphaData = im_overlap;
    
    title('overlap')
    
    % Finalize
    
    str = sprintf('%s to %s : overlap = %.1f %%',s_1,s_2,c*100);
    suptitle(str);
    
    output_folder = '~/Desktop/';
    output_folder = fullfile(output_folder,datestr(now,'yyyymmdd'));
    output_folder = [output_folder,'_v2_percent_heatmap_overlap'];
    begonia.path.make_dirs(output_folder)
    
    pause(0.2);
    
    str = sprintf('fov_%d_%s_to_%s.png', ...
        fov_id, ...
        s_1, ...
        s_2);
    str = fullfile(output_folder,str);
    export_fig(f,str,'-native');
    
end
end

