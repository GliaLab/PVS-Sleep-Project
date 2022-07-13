function result = analyse_recording(rec_path, config)
    import begonia.logging.*;
    import yucca.mod.puptool.*;

    rec = yucca.puptool.PupilRecording(rec_path);
    roiarea = config.eye_rect;
    minv = config.min;
    maxv  = config.max; 
    do_imadjust = config.use_imadjust;
    do_adapt = false;
    reliable_axis = config.reliable_axis;
    eye_width_px = config.eye_measure_px;
    
    ignore_mask = config.ignore_mask;
    
    % frames to analyse:
    log(1, "Analysis starting");
    row = 1;
    len = length(rec.frame_times);
    parfor i = 1:len
        if mod(i, 100) == 0
            disp(i + " analysed");
        end
        
        img = rec.read(i);
        [~, bbox, ~, dm_px] = analyse_frame(img, roiarea, minv, maxv, do_imadjust, do_adapt, ignore_mask, reliable_axis);
        
        timepoint(i,:) = rec.frame_offset_s(i);
        
            
        if ~isempty(bbox)
            bounds_px(i,:) = {bbox};
            diameter_px(i,:) = dm_px;
            ratio(i,:) = dm_px / eye_width_px;
            center_px(i,:) = {[(bbox(1) + bbox(3)/2), (bbox(2) + bbox(4)/2)]};
        
        else
            bounds_px(i,:) = {nan};
            diameter_px(i,:) = nan;
            ratio(i,:) = nan;
            center_px(i,:) = {nan};
        end
    end
   
    result = table(timepoint, bounds_px, diameter_px, center_px, ratio);
end

