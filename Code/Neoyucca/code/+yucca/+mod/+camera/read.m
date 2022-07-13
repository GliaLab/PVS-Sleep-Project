function camera = read(trial)
global BEGONIA_VERBOSE;

files = begonia.path.find_files(trial.Path, 'camera.avi');
assert(~isempty(files), ' "camera.avi" not found.');
assert(length(files) == 1, ' Multiple "camera.avi" found.')
file = files{1};
vidObj = VideoReader(file);
%%
files = begonia.path.find_files(trial.Path,'camera_time.csv');
assert(~isempty(files), 'camera_time.csv not found.');
assert(length(files) == 1, 'Multiple camera_time.csv found.');

mat = dlmread(files{1}, ',', 22, 1);
camera_t = mat(:,1)/1000;
%%
if BEGONIA_VERBOSE >= 1
    fprintf('Reading camera with %d frames: %s\n',vidObj.FrameRate*vidObj.Duration,trial.Path);
end


% Read rgb
im_pre = vidObj.readFrame();
% To grayscale
im_pre = mean(im_pre,3);
% Remove numbers
im_pre = im_pre(30:end,:);

i = 1;
while vidObj.hasFrame
    % Read rgb
    im = vidObj.readFrame();
    % To grayscale
    im = mean(im,3);
    % Remove numbers
    im = im(30:end,:);
    % Calculate the change.
    camera(i) = mean(abs(im(:) - im_pre(:)));
    % offset
    im_pre = im;
    
    i = i + 1;
end
camera = reshape(camera,[],1);
%%
camera_t(end) = [];
camera_t = camera_t - camera_t(1);
camera = timeseries(camera,camera_t,'Name','Camera');
camera = camera.resample(linspace(camera_t(1),camera_t(end),camera.Length));

camera = camera.setuniformtime('Interval',camera.Time(2)-camera.Time(1));


end

