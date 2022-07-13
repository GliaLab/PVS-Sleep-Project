function running_average_channel(stack, writer, ch, cy, average_count, every_n, from, last_f) 

    % get frame provider for requested channel and cycle:
    fprovider = stack.get_stack(ch, cy);
    ch_name = stack.channel_names{ch};
   
    if nargin < 8
        last_f = fprovider.size(3);
    end
    
    if nargin < 7
        from = 0;
    end
    
    if nargin < 6
        every_n = 1;
    end

    % calc frames to average:
    frame_indexes = from:every_n:last_f;
    
    % get each frame and output using writer:
    writer.start_series([stack.name '-' ch_name '-' num2str(cy)]);
    for i = frame_indexes
        avrg = yucca.tseries.average_frame(fprovider, i, average_count);
        writer.write_2D_frame(avrg);
    end
    writer.end_series();
    
end

