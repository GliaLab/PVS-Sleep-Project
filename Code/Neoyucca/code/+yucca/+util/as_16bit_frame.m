function frame_16bit = as_16bit_frame( frame )
%FRAME_12BIT_TO_16BIT Summary of this function goes here
%   Detailed explanation goes here

    frame_16bit = uint16((double(frame) / 2^12) * double(intmax('uint16')));
end

