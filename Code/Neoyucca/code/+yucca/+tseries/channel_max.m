function frame = channel_max( stack, writer, ch, cy )
%AVERAGE_CHANNEL Summary of this function goes here
%   Detailed explanation goes here

    name = [stack.name '-' stack.channel_names{ch} '-cycle_' num2str(cy) '-max'];
    
    % calc max:
    reader = stack.get_stack(ch, cy);
    mat = reader(:,:,:);
    max_vals = max(mat,[],3);
    
    % write output:
    writer.start_series(name);
    writer.write_2D_frame(max_vals);
    writer.end_series();
end

