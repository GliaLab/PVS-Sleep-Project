begonia.logging.set_level(1);
ts_path = fullfile(eustoma.get_data_path,'Microbead TSeries');
ts = begonia.scantype.find_scans(ts_path);
%%

for i = 1:length(ts)
    merged_frames = 10;
    
    if ts(i).channels ==  1
        ch1 = ts(i).get_mat(1);
        ch1_out = strrep(ts(i).path,ts_path, ...
            fullfile(eustoma.get_plot_path,'Microbead Movies'));
        ch1_out = [ch1_out,' ',ts(i).channel_names{1}];
        begonia.path.make_dirs(ch1_out);
        
        ch1_v = VideoWriter(ch1_out,'MPEG-4');
        open(ch1_v);
        ch1_img_rgb = zeros(ts(i).img_dim(1),ts(i).img_dim(2),3);
        for frame = 1:merged_frames:size(ch1,3)-merged_frames
            ch1_img = ch1(:,:,frame:frame + merged_frames - 1);
            ch1_img_rgb(:,:,2) = mean(ch1_img,3) / 4095;
            ch1_v.writeVideo(ch1_img_rgb);
        end
        close(ch1_v);
        
    elseif ts(i).channels > 1
        ch1 = ts(i).get_mat(1);
        ch2 = ts(i).get_mat(2);
        
        ch1_out = strrep(ts(i).path,ts_path, ...
            fullfile(eustoma.get_plot_path,'Microbead Movies'));
        ch1_out = [ch1_out,' ',ts(i).channel_names{1}];
        begonia.path.make_dirs(ch1_out);
        
        ch2_out = strrep(ts(i).path,ts_path, ...
            fullfile(eustoma.get_plot_path,'Microbead Movies'));
        ch2_out = [ch2_out,' ',ts(i).channel_names{2}];
        begonia.path.make_dirs(ch2_out);
        
        ch_merged_out = strrep(ts(i).path,ts_path, ...
            fullfile(eustoma.get_plot_path,'Microbead Movies'));
        ch_merged_out = [ch_merged_out,' Merged'];
        begonia.path.make_dirs(ch_merged_out);
        
        ch1_v = VideoWriter(ch1_out,'MPEG-4');
        ch2_v = VideoWriter(ch2_out,'MPEG-4');
        ch_merged_v = VideoWriter(ch_merged_out,'MPEG-4');
        
        open(ch1_v);
        open(ch2_v);
        open(ch_merged_v);
        
        ch1_img_rgb = zeros(ts(i).img_dim(1),ts(i).img_dim(2),3);
        ch2_img_rgb = zeros(ts(i).img_dim(1),ts(i).img_dim(2),3);
        ch_merged_img_rgb = zeros(ts(i).img_dim(1),ts(i).img_dim(2),3);
        
        for frame = 1:merged_frames:size(ch1,3)-merged_frames
            ch1_img = ch1(:,:,frame:frame + merged_frames - 1);
            ch1_img = mean(ch1_img,3) / 4095;
            
            ch2_img = ch2(:,:,frame:frame + merged_frames - 1);
            ch2_img = mean(ch2_img,3) / 4095;
            
            ch1_img_rgb(:,:,2) = ch1_img;
            ch2_img_rgb(:,:,1) = ch2_img;
            ch_merged_img_rgb = ch1_img_rgb + ch2_img_rgb;
            
            ch1_v.writeVideo(ch1_img_rgb);
            ch2_v.writeVideo(ch2_img_rgb);
            ch_merged_v.writeVideo(ch_merged_img_rgb);
        end
        close(ch1_v);
        close(ch2_v);
        close(ch_merged_v);
    end
    
    
%         
%         output_path = strrep(ts(i).path,ts_path, ...
%             fullfile(eustoma.get_plot_path,'Microbead Movies'));
%         output_path = [output_path,' ',ts(i).channel_names{ch}];
%         begonia.path.make_dirs(output_path);
%         
%         cmap = zeros(256,3);
%         if ch == 1
%             cmap(:,2) = linspace(0,1,256);
%         else
%             cmap(:,1) = linspace(0,1,256);
%         end
%         
%         v = VideoWriter(output_path,'MPEG-4');
%         open(v);
%         for frame = 1:merged_frames:size(mat,3)-merged_frames
%             img = mat(:,:,frame:frame + merged_frames - 1);
%             img = mean(img,3) / 4095;
%             img = ind2rgb8(round(img*256),cmap);
%             v.writeVideo(img);
%         end
%         close(v);
%     end
end