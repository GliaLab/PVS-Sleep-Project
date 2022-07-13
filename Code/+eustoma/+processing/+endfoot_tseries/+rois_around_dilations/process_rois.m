begonia.logging.set_level(1);

ts = eustoma.get_endfoot_tseries(true);
ts = ts(ts.has_var('roi_table'));

%% "Custom" code to extract ROIs. Loads the whole matrix in memory.

import begonia.logging.log;
import begonia.processing.roi.extract_single_roi_signal;

for i = 1:length(ts)    

    roi_table = ts(i).load_var('roi_table');

    % Assume all cycles have equally many frames.
    signal = cell.empty;

    log(1, "Extracting roi signals: " + ts(i).path);

    for ch = 1:ts(i).channels
        % Get the rois of the correct cycle and channel.
        ch_rows = roi_table(roi_table.channel == ch,:);

        % Get the matrix.
        mat = ts(i).get_mat(ch, 1);
        mat = mat(:,:,:);

        for j = 1:height(ch_rows)
            log(2, "RoI Ch" + ch + "/" + j);
            roi = table2struct(ch_rows(j, :));
            vec = extract_single_roi_signal(roi, mat);
            
            row = find(roi.roi_id == roi_table.roi_id);
            signal(row) = {vec};
        end
    end

    roi_signals_raw = roi_table(:,["short_name","roi_id","channel","type","mask"]);
    roi_signals_raw.pos = [roi_table.center_y,roi_table.center_x];
    roi_signals_raw.signal_raw = signal';
    roi_signals_raw.dt(:) = ts(i).dt;
    
    ts(i).save_var(roi_signals_raw);
end
