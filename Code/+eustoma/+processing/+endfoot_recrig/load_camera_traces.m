
begonia.logging.set_level(1);

path = fullfile(eustoma.get_data_path,'Endfeet Recrig');
trials = yucca.trial_search.find_trials(path);
trials = trials(trials.has_var('video_region_names'));

datastore = fullfile(eustoma.get_data_path,'Endfeet Recrig Data');
engine = yucca.datanode.OffPathEngine(datastore);
%%

for trial_idx = 1:length(trials)
    begonia.logging.log(1,'load_camera (%d/%d)',trial_idx,length(trials));
    trial = trials(trial_idx);

    files = begonia.path.find_files(trial.Path, 'camera.avi');
    assert(~isempty(files), ' "camera.avi" not found.');
    assert(length(files) == 1, ' Multiple "camera.avi" found.')
    file = files{1};
    warning('off')
    vidObj = VideoReader(file);
    warning('on')

    files = begonia.path.find_files(trial.Path,'camera_time.csv');
    assert(~isempty(files), 'camera_time.csv not found.');
    assert(length(files) == 1, 'Multiple camera_time.csv found.');

    mat = dlmread(files{1}, ',', 22, 1);
    camera_t = mat(:,1)/1000;

    video_region_names = trial.load_var('video_region_names');
    video_region_mask = trial.load_var('video_region_mask');

    num_regions = size(video_region_mask,3);

    N_approx = round(vidObj.FrameRate*vidObj.Duration);
    
    camera = zeros(N_approx,num_regions);
    % Read rgb
    im_pre = vidObj.readFrame();
    % To grayscale
    im_pre = mean(im_pre,3);

    begonia.logging.log(1,'Reading %d frames',N_approx);
    i = 0;
    while vidObj.hasFrame
        i = i + 1;
        % Read rgb
        im = vidObj.readFrame();
        % To grayscale
        im = mean(im,3);

        im_1 = abs(im - im_pre);
        for j = 1:num_regions
            im_2 = video_region_mask(:,:,j);
            camera(i,j) = sum(im_1(:).*im_2(:))/sum(im_2(:));
        end

        im_pre = im;
    end
    
    % Remove end values if pre-allocation was too large. 
    if size(camera,1) > i
        camera(i:end,:) = [];
    end

    % Make the time vector and camera traces the same length. 
    camera_t = reshape(camera_t,[],1);
    camera_t(end) = [];
    camera_t = camera_t - camera_t(1);
    if length(camera) > length(camera_t)
        camera = camera(1:length(camera_t),:);
    elseif length(camera_t) > length(camera)
        camera_t = camera_t(1:length(camera));
    end

    % Calculate the average frame rate which will be used to resample the
    % traces to uniform intervals.
    dt = mean(diff(camera_t));
    fs = 1/dt;
    
    I = isnan(camera(1,:));
    camera(:,I) = [];
    video_region_names(I) = [];
    
    % Resample and gather the traces to a table.
    camera = resample(camera,camera_t,fs);
    camera_traces = array2timetable(camera,'SampleRate',fs, ...
        'VariableNames',video_region_names);

    engine.save_var(trial,'camera_traces',camera_traces);
end

begonia.logging.log(1,'Finished');