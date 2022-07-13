function result = analyse_tseries(ts, frames)
    import xylobium.vesseltool2.measurement.*;
    
    if nargin < 2
        frames = 60:60:ts.frames_in_cycle;
    end
    
    if ~ts.has_var('vestool2_marker_array')
       error("TSeries has no markers"); 
    end

    % load previosu config from this tseries:
    markers = ts.load_var('vestool2_marker_array');

    % load markers from config:
    i = 1;
    for marker = markers
        disp("Marker " + marker.name + " CH2/CH3");
        result_ch2 = analyse_frames(ts, 1, 1, 'valley-intercept', 60, marker, frames);
        result_ch3 = analyse_frames(ts, 1, 2, 'hill-intercept', 60, marker, frames);
        
        ts_name(i,:) = categorical(string(ts.name));
        ts_name(i + 1,:) = categorical(string(ts.name));
        
        channel(i,:) = categorical("Ch2");
        channel(i + 1,:) = categorical("Ch3");
        
        marker_name(i,:) = categorical(string(marker.name));
        marker_name(i + 1,:) = categorical(string(marker.name));
        
        marker_obj(i,:) = {marker};
        marker_obj(i + 1,:) = {marker};
        
        distance_pix(i,:) = [result_ch2.distance_pix];
        distance_pix(i + 1,:) = [result_ch3.distance_pix];
        
        distance_um(i,:) = [result_ch2.distance_pix] * ts.dt;
        distance_um(i + 1,:) = [result_ch3.distance_pix] * ts.dt;
        
        time_s(i,:) = frames * ts.dt;
        time_s(i + 1,:) = frames * ts.dt;
        
        i = i + 2;
    end
    
    % make table:
    result = table(ts_name, channel, marker_name, distance_pix, distance_um, time_s, marker_obj);
    ts.save_var('vestool2_results', result);
end

