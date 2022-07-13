function process_camera(tr)

for i = 1:length(tr)
    begonia.logging.log(1,"Processing trial %d/%d",i,length(tr));
    camera_rois = tr(i).load_var('camera_rois', []);
    if isempty(camera_rois)
        continue;
    end
    
    % Find files.
    files = begonia.path.find_files(tr(i).path, 'camera.avi');
    assert(~isempty(files), ' "camera.avi" not found.');
    assert(length(files) == 1, ' Multiple "camera.avi" found.')
    file = files{1};
    warning('off')
    vidObj = VideoReader(file);
    warning('on')

    files = begonia.path.find_files(tr(i).path, 'camera_time.csv');
    assert(~isempty(files), 'camera_time.csv not found.');
    assert(length(files) == 1, 'Multiple camera_time.csv found.');

    % Read text file with timepoints of frames.
    mat = dlmread(files{1}, ',', 22, 1);
    t = mat(:,1)' ./ 1000;
    t = t - t(1);
    t(end) = [];
    
    % Process camera
    camera_traces = tr(i).load_var('camera_rois');
    tic
    begonia.logging.log(1,"Processing %.f frames (  0%%)", vidObj.NumFrames);
    
    N = height(camera_traces);
    camera_traces.camera_absdiff = cell(N, 1);
    camera_traces.camera_t = repmat({t}, N, 1);

    frame = 1;
    im_pre = vidObj.readFrame();
    im_pre = mean(im_pre,3);
    while vidObj.hasFrame
        if toc > 10
            begonia.logging.log(1,"Processing %.f frames (%3.f%%)", vidObj.NumFrames, frame / vidObj.NumFrames * 100);
            tic
        end
        
        im = vidObj.readFrame();
        im = mean(im,3);

        im_1 = abs(im - im_pre);
        for j = 1:N
            mask = camera_traces.mask{j};
            camera_traces.camera_absdiff{j}(frame) = sum(im_1(:).*mask(:))/sum(mask(:));
        end

        im_pre = im;

        frame = frame + 1;
    end
    
    tr(i).save_var(camera_traces);
    begonia.logging.log(1,"Processing %.f frames (100%%)", vidObj.NumFrames);
end
end

