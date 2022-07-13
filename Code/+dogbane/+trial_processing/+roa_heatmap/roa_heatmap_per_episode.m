function roa_heatmap_per_episode(trial)

output_folder = '~/Desktop/roa_heatmaps/';
output_folder = fullfile(output_folder,datestr(now,'yyyymmdd'));
output_folder = [output_folder,'_v2_roa_heatmap_per_episode'];
begonia.path.make_dirs(output_folder)
%%
tr = trial.rec_rig_trial;
ts = trial.tseries;

dt = ts.dt;
fs = 1/dt;
dx = ts.dx;

% string that is probably unique, used for creating unique filenames.
unique_trial_str = tr.load_var('trial');

fov_id = ts.load_var('fov_id');

img_avg = ts.get_avg_img(1,1);

genotype = tr.load_var('genotype');

tbl_states = tr.load_var('state_episodes');
%% get some extra episodes defined inside awakenings
tbl_awakening_states = tr.load_var('inside_awakenings',[]);
if ~isempty(tbl_awakening_states)
    % Only include the neccessary columns so we can concatinate the tables
    % later. 
    tbl_states = tbl_states(:,{'State','StateStart','StateEnd','StateDuration'});
    
    tbl_states = cat(1,tbl_states,tbl_awakening_states);
end
%%
begonia.util.logging.vlog(1,'Loading roa data');
mat = ts.load_var('highpass_thresh_roa_mask');

dim = size(mat);

%%
tbl_states.start_idx = round(tbl_states.StateStart * fs) + 1;
tbl_states.end_idx = round(tbl_states.StateEnd * fs);

img_roa_density = cell(height(tbl_states),1);
img_roa_frequency = cell(height(tbl_states),1);
img_roa_point = cell(height(tbl_states),1);
for i = 1:height(tbl_states)
    state = tbl_states.State(i);
    st = tbl_states.start_idx(i);
    en = tbl_states.end_idx(i);
    
    if state == 'undefined'
        continue;
    end
    
    if en > size(mat,3)
        en = size(mat,3);
    end
    
    mat_sub = mat(:,:,st:en);
    %% roa density heatmap
    img_roa_density{i} = sum(mat_sub,3) / size(mat_sub,3);
    %% roa frequency and point heatmap
    CC = bwconncomp(mat_sub,6);
    
    img_freq = zeros(dim(1),dim(2));
    tmp = zeros(dim(1),dim(2));
    
    roa_center = zeros(CC.NumObjects,2);
    
    for j = 1:CC.NumObjects
        [y,x,~] = ind2sub(CC.ImageSize,CC.PixelIdxList{j});
        
        
        roa_center(i,:) = round(mean([y,x],1));
        
        tmp(:) = 0;
        for k = 1:length(y)
            tmp(y(k),x(k)) = 1;
        end
        img_freq = img_freq + tmp;
    end
    % Calculate events / min per pixel
    dur = size(mat_sub,3) * dt;
    img_freq = img_freq / dur;
    
    
    % Calculate point heatmap
    edge_y = 1:dim(1)+1;
    edge_x = 1:dim(2)+1;

    img_point = histcounts2(roa_center(:,1),roa_center(:,2),edge_y,edge_x);
    img_point = img_point / dur;
    
    % Save
    img_roa_frequency{i} = img_freq;
    img_roa_point{i} = img_point;
    %% plot freq heatmap
        
    img_red = zeros(dim(1),dim(2),3);
    img_red(:,:,1) = 1;
    
    img_freq = begonia.mat_functions.normalize(img_freq*60,'limits',[0,2]);
    
    f = figure;

    imshow(img_avg);

    a = gca;
    a.CLim = [0,prctile(img_avg(:),99)];

    hold on
    im = imshow(img_red);
    im.AlphaData = img_freq;

    t = text(256,25,sprintf('State : %s',state));
    t.Color = 'r';
    t.FontSize = 20;
    t.HorizontalAlignment = 'center';
    t.VerticalAlignment = 'middle';

    a.XTickLabel = [];
    a.YTickLabel = [];
    a.XLim = [0,dim(1)];
    a.YLim = [0,dim(2)];
    
    str = sprintf('%s_%s_fov_%s_dur_%03.0f_%d_%s.png', ...
        genotype, ...
        state, ...
        num2str(fov_id), ...
        tbl_states.StateEnd(i) - tbl_states.StateStart(i), ...
        i, ...
        unique_trial_str);
    str = fullfile(output_folder,str);
    
    pause(0.2);
    export_fig(f,str,'-native');
    
    close(f)
end
%%
state = tbl_states.State;
state_start = tbl_states.StateStart;
state_end = tbl_states.StateEnd;
state_duration = state_end - state_start;

roa_heatmap_per_episode = table(state,state_start,state_end,state_duration,img_roa_density,img_roa_frequency,img_roa_point);
ts.save_var(roa_heatmap_per_episode);
end

