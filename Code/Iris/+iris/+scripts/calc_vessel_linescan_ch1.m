clear all

%% Load tseries
ts = get_tseries(true);
ts = ts(ts.has_var("trial_id"));
ts = ts(ts.has_var("vessel_position"));

%%
tic
for i = 1:length(ts)
    if i == 1 || i == length(ts) || toc > 5
        tic
        begonia.logging.log(1,"%d / %d",i,length(ts))
    end
    
    % Load vessel position.
    vessel_linescan = ts(i).load_var("vessel_position");
    
    % Parameters of linescan extraction.
    half_line_width = 2;
    merged_frames = 10;
    channel = 1;
    
    mat = ts(i).get_mat(channel);
    mat = mat(:,:,:);
    
    % Init output data
    fs = 1 / ts(i).dt / merged_frames;
    dx = ts(i).dx;
    
    % Init new data.
    N = height(vessel_linescan);
    trial_id = string(ts(i).load_var("trial_id"));
    vessel_linescan.trial_id = repmat(trial_id,N,1);
    vessel_linescan.fs = repmat(fs,N,1);
    vessel_linescan.dx = repmat(dx,N,1);
    vessel_linescan.linescan = cell(N,1);
    vessel_linescan.center = nan(N,2);
    
    for j = 1:N
        % Calculate linescan angle and length
        a = vessel_linescan.linescan_position(j,[1,3]);
        b = vessel_linescan.linescan_position(j,[2,4]);
        
        center = (a+b)/2;
        center = round(center);
        vessel_linescan.center(j,:) = center;
        
        img_center = round(ts(i).img_dim / 2);
        
        shift = img_center - center;
        shift = fliplr(shift);
        
        half_length_pix = round(norm(a-b) / 2);
        
        X = b(1) - a(1);
        Y = b(2) - a(2);
        angle = atan2(Y,X) / 2 / pi * 360 - 90;
        % Sample data
        tic
        frames = 1:merged_frames:ts(i).frame_count-merged_frames;
        vessel_linescan.linescan{j} = zeros(half_length_pix * 2 + 1, length(frames));
        for k = 1:length(frames)
            frame = frames(k);
            if k == 1 || k == length(frames) || toc > 5
                begonia.logging.log(1,"Sampling vessel #%.f %.f/%.f frames.", j, frame, ts(i).frame_count);
                tic
            end
            
            img = mat(:,:,frame:frame+merged_frames-1);
            img = mean(double(img),3);
            img = circshift(img, shift);
            img = imrotate(img,angle,"crop");
            img = img( ...
                img_center(1) - half_length_pix:img_center(1) + half_length_pix, ...
                img_center(2) - half_line_width:img_center(2) + half_line_width);
            img = mean(img,2);
            vessel_linescan.linescan{j}(:,k) = img;
        end
    end
    
    ts(i).save_var(vessel_linescan);
end