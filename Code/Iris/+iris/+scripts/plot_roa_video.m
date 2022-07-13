clear all

%% Load tseries
ts = get_tseries(true);
ts = ts(ts.has_var("roa_param"));
ts = ts(ts.has_var("roa_mask"));

%%
for i = 1:length(ts)
    begonia.logging.log(1,"%d / %d",i,length(ts));
    
    trial_id = ts(i).load_var("trial_id");
    roa_param = ts(i).load_var("roa_param");
    roa_mask = ts(i).load_var("roa_mask");
    
    mat = ts(i).get_mat(roa_param.channel);
    dim = size(mat);
    
    outputfile = fullfile(get_project_path, "Plot", "ROA videos", trial_id+".mp4");
    if exist(outputfile,'file')
        delete(outputfile);
    end
    begonia.path.make_dirs(outputfile);
    
    v = VideoWriter(outputfile,'MPEG-4');
    v.Quality = 100;
    open(v);

    n = dim(1) * dim(2);
    
    tmp = double(mat(:,:,1));
    tmp = tmp(1:floor(n/roa_param.roa_t_smooth)*roa_param.roa_t_smooth);
    tmp = reshape(tmp,roa_param.roa_t_smooth,[]);
    tmp = mean(tmp,1);
    lims = [min(tmp),max(tmp)];

    img = zeros(dim(1),dim(2),3);
    tic
    for frame = 1 : roa_param.roa_t_smooth : dim(3) - roa_param.roa_t_smooth
        if toc > 5 || frame == 1
            tic
            begonia.logging.log(1,"Writing frame %d/%d (%.f%%)", frame, dim(3), frame/dim(3) * 100);
        end
        
        % Assign the frame data.
        img_cur_frame = mat(:,:,frame:frame + roa_param.roa_t_smooth - 1);
        img_cur_frame = mean(img_cur_frame,3);
        img_cur_frame = img_cur_frame - lims(1);
        img_cur_frame = img_cur_frame ./ lims(2);
        img_cur_frame(img_cur_frame<0) = 0;
        img_cur_frame(img_cur_frame>1) = 1;
        img(:,:,:) = repmat(img_cur_frame,1,1,3);
        
        % Assign ROA.
        img(:,:,1) = roa_mask(:,:,frame);

        v.writeVideo(img);
    end
    close(v);
    begonia.logging.log(1,"Writing frame %d/%d (100%%)", dim(3), dim(3));
end
