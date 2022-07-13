function [averaged_mat, averaged_frames, taken_left, taken_right] = average_frame( stack_mat, center_f, average )
%AVERAGE_RANGE Summary of this function goes here
%   Detailed explanation goes here
    
    % grab stack:
    last_f = size(stack_mat, 3);

    % calculate start frame:
    start_f = center_f - floor(average / 2);
    if start_f < 1
        start_f = 1;
    end
    
    % calculate end frame:
    end_f = center_f + floor(average / 2);
    if end_f > last_f
        end_f = last_f;
    end
    
    % calculate actual averaged frames:
    averaged_frames = end_f - start_f;
    taken_left = center_f - start_f;
    taken_right = end_f - center_f;
    
    if averaged_frames < 1
        error('Averaged frame count must be more than 1')
    end
    
    % average the frames, starting with first:
    all = stack_mat(:,:,start_f:end_f);
    averaged_mat = mean(all,3);

end

