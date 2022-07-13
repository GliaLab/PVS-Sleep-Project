clear all
begonia.logging.set_level(1);
begonia.logging.log(1,"Finding tseries")

begonia.logging.set_level(0);
ts = eustoma.get_endfoot_tseries(true);
ts = ts(ts.has_var("vessel_position"));

%%
begonia.logging.set_level(1);

for i = 1:length(ts)
    vessel_table = ts(i).load_var("vessel_position");
    
    half_line_width = 2;
    merged_frames = 5;
    
    mat = ts(i).get_mat(2);
    
    %% Init output data
    vessel_fs = 1/ts(i).dt / merged_frames;
    vessel_dx = ts(i).dx;
    
    N = height(vessel_table);
    vessel_table.vessel_fs = repmat(vessel_fs,N,1);
    vessel_table.vessel_dx = repmat(vessel_dx,N,1);
    vessel_table.vessel = cell(N,1);
    
    for j = 1:N
        %% Calculate linescan angle and length
        a = vessel_table.vessel_position(j,[1,3]);
        b = vessel_table.vessel_position(j,[2,4]);
        
        vessel_center = (a+b)/2;
        vessel_center = round(vessel_center);
        
        center = round(ts(i).img_dim / 2);
        
        shift = center - vessel_center;
        shift = fliplr(shift);
        
        half_length_pix = round(norm(a-b) / 2);
        
        X = b(1) - a(1);
        Y = b(2) - a(2);
        angle = atan2(Y,X) / 2 / pi * 360 - 90;
        %% Sample data
        tic
        frames = 1:merged_frames:ts(i).frame_count-merged_frames;
        vessel_table.vessel{j} = zeros(half_length_pix * 2 + 1, length(frames));
        for k = 1:length(frames)
            frame = frames(k);
            if toc > 10 || k == 1 || k == length(frames)
                begonia.logging.log(1,"Sampling tseries %d/%d vessel %d/%d frame %d/%d.", ...
                    i, length(ts), j, N, frame, ts(i).frame_count);
                tic
            end
            
            img = mat(:,:,frame:frame+merged_frames-1);
            img = mean(double(img),3);
            img = circshift(img, shift);
            img = imrotate(img,angle,"crop");
            img = img( ...
                center(1) - half_length_pix:center(1) + half_length_pix, ...
                center(2) - half_line_width:center(2) + half_line_width);
            img = mean(img,2);
            vessel_table.vessel{j}(:,k) = img;
        end
    end
    disp(vessel_table)
    ts(i).save_var(vessel_table);
end