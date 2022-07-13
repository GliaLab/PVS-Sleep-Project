function frame = channel_average( stack, writer, ch, cy )
%AVERAGE_CHANNEL Summary of this function goes here
%   Detailed explanation goes here
    
    freader = stack.get_stack(ch, cy);
    length = floor(freader.size(3) / 2);
    name = [stack.name '-' stack.channel_names{ch} '-cycle_' num2str(cy) '-averaged'];
    
    frame = yucca.tseries.average_frame(freader, floor(length / 2), length);
    
    writer.start_series(name);
    writer.write_2D_frame(frame);
    writer.end_series();
end

