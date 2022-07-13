function results = analyse_frames(ts, cy, ch, method, frame, marker, frames)
    import xylobium.vesseltool2.measurement.*;
    
    % analyse at 0.5 hz by default
    if nargin < 7
        f_interval = ceil(2/ts.dt);
        frames = f_interval:f_interval:ts.frames_in_cycle;
    end
    
    % analyse each frame:
    for i = 1:length(frames)
        results(i) = analyse_frame(ts, cy, ch, method, frames(i), marker);
    end
    
end

