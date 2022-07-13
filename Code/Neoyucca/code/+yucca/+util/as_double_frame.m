function frame_double = as_double_frame( frame )
%FRAME_12BIT_TO_16BIT Summary of this function goes here
%   Detailed explanation goes here

    frame_double = double(frame) / 2^12;
end

