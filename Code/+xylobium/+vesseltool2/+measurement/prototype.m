

ts = tss(2);
cy = 1;
mat_ch2 = ts.get_std_img(1,1);
mat_ch3 = ts.get_std_img(1,2);
im_ref_fused = imfuse(mat_ch2, mat_ch3,'falsecolor','Scaling','independent','ColorChannels',[2 1 0]); 


figure; imagesc(im_ref_fused);

colormap(begonia.colormaps.turbo);
mline = imdistline();

mline_pos = mline.getPosition();
xs = mline_pos(1:2,1);
ys = mline_pos(1:2,2);
ang = 90 - mline.getAngleFromHorizontal();

i = 1;
for f = 30:30:ts.frames_in_cycle
    result_ch2(i) = xylobium.vesseltool2.measurement.analyse_frame(ts, cy, 1,'valley' , f, xs, ys, ang);
    result_ch3(i) = xylobium.vesseltool2.measurement.analyse_frame(ts, cy, 2,'valley' , f, xs, ys, ang);

    i = i + 1;
end

mat_ls_ch2 = cat(1, result_ch2.linescan);
mat_ls_ch3 = cat(1, result_ch3.linescan);

im_fused = imfuse(mat_ls_ch2, mat_ls_ch3,'falsecolor','Scaling','independent','ColorChannels',[2 1 0]); 
figure; imagesc(im_fused);




% mat = mean(mat_ch2(:,:,100:130), 3);
% 
% figure;
% imagesc(mat);
% colormap(begonia.colormaps.turbo)
% mline = imdistline();
% 
% 
% %% lscan retrival:
% time_avg_s = 30;
% smooth_spatial = 10;
% span = 5;
% padding = 0;
% 
% ang = 90 - mline.getAngleFromHorizontal();
% dist = mline.getDistance();
% mline_pos = mline.getPosition();
% xs = mline_pos(1:2,1);
% ys = mline_pos(1:2,2);
% 
% 
% % crop to area around the line, then rotatE:
% cx = xs(1) +  (xs(2) - xs(1)) / 2;
% cy = ys(1) + (ys(2) - ys(1)) / 2;
% 
% croprect = [cx - dist/2 - padding ...
%     , cy - dist/2 - padding ...
%     , dist + padding * 2 ...
%     , dist + padding * 2];
% 
% mat_crop = imcrop(mat, croprect);   % select are
% %mat_gaus = mat_crop
% mat_gaus = imgaussfilt(mat_crop,2); % smooth a little in space
% mat_rot = imrotate(mat_gaus, ang);  % rotate
% 
% % get the imddle part, and use that as a linescan to get profile of
% % vessel:
% mat_rot_mid = floor(size(mat_rot,2)/2);
% lscan_mat = mat_rot(:,mat_rot_mid-span:mat_rot_mid+span)';
% lscan = mean(lscan_mat,1);
%     
% figure; imagesc(mat_rot);
% colormap(begonia.colormaps.turbo)
% 
% [diam_hp, peaks, intercepts] = xylobium.vesseltool2.measurement.get_unlocked_dist(lscan)
% figure; plot(lscan); 
% 
% %% distance calculation:
