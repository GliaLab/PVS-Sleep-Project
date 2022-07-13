 function [video_frames] = generate_video(rec_path, config, output_path)
    import begonia.logging.*;
    import yucca.mod.puptool.*;

    rec = yucca.puptool.PupilRecording(rec_path);
    roiarea = config.eye_rect;
    minv = config.min;
    maxv  = config.max; 
    do_imadjust = config.use_imadjust;
    do_adapt = false;
    ignore_mask = config.ignore_mask;
    reliable_axis = config.reliable_axis;
    
    % frames to analyse:
    log(1, "Analysis starting");
    row = 1;
    len = length(rec.frame_times);
    %len = 1000;
    
    % analyse one frame to get size and create the frames array:
    img = rec.read(1); %#ok<*PFBNS>
    [~, ~, frame, ~] = analyse_frame(img, roiarea, minv, maxv, do_imadjust, do_adapt, ignore_mask, reliable_axis);
    video_frames = zeros(size(frame,1), size(frame,2), len);
    
    % generate frames:
    parfor i = 1:len
        if mod(i, 100) == 0
            disp(i + " frames generated");
        end
        
        img = rec.read(i); %#ok<*PFBNS>
        [~, bbox, frame, dm_px] = analyse_frame(img, roiarea, minv, maxv, do_imadjust, do_adapt, ignore_mask, reliable_axis);
        
        %preview = imresize(preview, round(roiarea(3:4)));
        %frame = imresize(frame, round(roiarea(3:4)));

        if ~isempty(bbox)
            %diameter = max([bbox(3) bbox(4)]);
            
            frame(:,round(bbox(1) + bbox(3)/2)) = 0;
            frame(round(bbox(2) + bbox(4)/2),:) = 0;
            frame = insertObjectAnnotation(frame, 'rectangle', bbox, char("Pupil: " + dm_px + " px"));
            
            frame = rgb2gray(frame);
        end
        
        video_frames(:,:,i) = frame;
    end
   
    % write the video:
    vwriter = VideoWriter(output_path, 'MPEG-4');
    vwriter.FrameRate = 45;
    open(vwriter);
    for i = 1:size(video_frames, 3)
        if mod(i, 100) == 0
            disp(i + " frames written");
        end
        %img = video_frames(:,:,i)
        %img = ind2rgb(video_frames(:,:,i), begonia.colormaps.turbo(256));
        img = ind2rgb(video_frames(:,:,i), bone(256));
        vwriter.writeVideo(img);
    end
    close(vwriter);
    
    
    %result = analyse_recording(rec_path, config);
end

