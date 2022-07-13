function [video_reader,frametimes] = read_pupil_video(tr)
% Read video.
mp4_path = iris.util.get_trial_name(tr) + ".mp4";
mp4_path = fullfile(get_project_path(),"Data","Pupil videos", mp4_path);
if ~exist(mp4_path,"file")
    video_reader = [];
    frametimes = [];
    return
end
video_reader = VideoReader(mp4_path);

% Read frametimes
frame_path = iris.util.get_trial_name(tr) + "-frametimes.csv";
frame_path = fullfile(get_project_path(),"Data","Pupil videos", frame_path);
frametimes = readtable(frame_path);
end

