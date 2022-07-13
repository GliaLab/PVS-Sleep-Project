function calc_pupil_mask(tr)

[video_reader,frametimes] = iris.util.read_pupil_video(tr);
if isempty(video_reader)
    error("Missing mp4");
end

threshold = tr.load_var("pupil_threshold");

% Parameters for skipping frames.
skipped_frames = 15;
frames = 1:skipped_frames:height(frametimes);

% Calculate fs.
fs = 1/mean(diff(frametimes.t(frames)));
begonia.logging.log(1,"Output sampling rate ~= %f",fs);

% Read pupil area.
vid = video_reader.read();
mask = false(video_reader.Height,video_reader.Width,length(frames));
for i = 1:length(frames)
    iris.util.log_progress(frames(i),frametimes);
    img = vid(:,:,:,frames(i));
    mask(:,:,i) = iris.util.threshold_pupil(img,threshold);
end
% Save the pupil mask as indices.
pupil_mask = struct;
pupil_mask.mask = find(mask);
pupil_mask.dim = size(mask);
pupil_mask.frames = frames;
pupil_mask.frametimes = frametimes.t(frames);
tr.save_var(pupil_mask);

% Calculate center and diameter.
pupil_center = zeros(size(mask,3),2);
diameter = zeros(1,size(mask,3));
for i = 1:size(mask,3)
    x = regionprops(mask(:,:,i),"Centroid","MajorAxisLength");
    if ~isempty(x)
        pupil_center(i,:) = x.Centroid(:);
        diameter(i) = x.MajorAxisLength;
    end
end
pupil_diameter = table;
pupil_diameter.y = {diameter};
pupil_diameter.x = {frametimes.t(frames)};
pupil_diameter.ylabel = "Pupil diameter (pixels)";
pupil_diameter.name = "Pupil diameter";
pupil_diameter.img_dim = [size(mask,1),size(mask,2)];
tr.save_var(pupil_diameter)
tr.save_var(pupil_center);
end

