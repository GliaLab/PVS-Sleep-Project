function export_pupil_video(tr)

% Init pupil data manager object.
rec_path = fullfile(tr.path, "pupil_data");
rec = yucca.mod.puptool.PupilRecording(rec_path);

pupil_crop = tr.load_var("pupil_crop");

% Calculate center of the rectangle.
roi_center = pupil_crop(1:2) + pupil_crop(3:4)/2;
img = imread(fullfile(rec.path,rec.files(1)));
dim = size(img);
shift = [dim(2),dim(1)]/2 - roi_center;
shift = round(shift);
pupil_crop(1:2) = pupil_crop(1:2) + shift;

% Set the name of the file to the same as the "path" variable in
% iris.scripts.load_labview_info
filename = iris.util.get_trial_name(tr);

% Create frame times output path.
csv_path = fullfile(get_project_path(),"Data","Pupil videos",filename + "-frametimes.csv");

% Write frame times.
frame_nr = (1:length(rec.files))';
t = rec.frame_offset_s;
tbl = table(frame_nr, t);
begonia.path.make_dirs(csv_path);
writetable(tbl,csv_path);

% Create video output path.
video_path = fullfile(get_project_path(),"Data","Pupil videos",filename + ".mp4");

% Write video.
begonia.path.make_dirs(video_path);
vwriter = VideoWriter(video_path, 'MPEG-4');
% The framerate is not so imprtant. Set it to the average framerate of
% the images.
vwriter.FrameRate = round(1/mean(diff(rec.frame_offset_s)));
open(vwriter);
tic
for frame_idx = 1:length(rec.files)
    iris.util.log_progress(frame_idx,rec.files,10,"Writing frame");
    % Read file.
    img = imread(fullfile(rec.path,rec.files(frame_idx)));
    % Roatate and crop the image according the the pupil crop.
    img = circshift(img,shift(1),2);
    img = circshift(img,shift(2),1);
    img = imrotate(img,-pupil_crop(5),'nearest','crop');
    img = imcrop(img,pupil_crop(1:4));

    vwriter.writeVideo(img);
end
close(vwriter);
