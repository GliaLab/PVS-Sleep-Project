function export_pupil_video_with_outline(tr)

video_reader = iris.util.read_pupil_video(tr);
if isempty(video_reader)
    error("Missing mp4");
end

% Load mask and diameter. The timeinfo is saved in the diameter trace.
pupil_mask = tr.load_var("pupil_mask");

% Recreate the mask from the indicies.
mask = false(pupil_mask.dim);
mask(pupil_mask.mask) = true;

% Read correct frames from the pupil video.
vid = video_reader.read();
% Make a new matrix to hold the video with the same number of frames as 
% the mask. 
vid_new = zeros(size(mask,1), size(mask,2), 3, size(mask,3),'uint8');
for i = 1:length(pupil_mask.frames)
    iris.util.log_progress(i,pupil_mask.frames);
    img = vid(:,:,:,pupil_mask.frames(i));
    % Impose the mask on the blue rgb frame.
    img(:,:,3) = max(img(:,:,3),im2uint8(mask(:,:,i)));
    
    % Put the time as text in the image.
    time = string(pupil_mask.frametimes(i)) + " s";
    img = insertText(img,[1,1],time,"FontSize",35);

    vid_new(:,:,:,i) = img;
end

% Make video name.
mp4_path = iris.util.get_trial_name(tr) + ".mp4";
mp4_path = fullfile(get_project_path(),"Data","Pupil videos outline", mp4_path);

% Write video.
begonia.path.make_dirs(mp4_path);
vwriter = VideoWriter(mp4_path, 'MPEG-4');
% The framerate is not so imprtant. Set it to the average framerate of
% the images.
vwriter.FrameRate = round(1/mean(diff(pupil_mask.frametimes)));
open(vwriter);
vwriter.writeVideo(vid_new);
close(vwriter);
