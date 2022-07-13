
ts = eustoma.get_endfoot_tseries();
ts = ts(ts.has_var('dilation_episodes'));
ts = ts(ts.has_var('roi_signals_cap'));
ts = ts(ts.has_var('diameter'));

%%
sec_before_episode = 15;
sec_after_episode = 15;
closest_ROI = 0;

for i = 1:length(ts)
    begonia.logging.log(1,"TSeries (%d/%d)",i,length(ts));
    
    diameter = ts(i).load_var('diameter');
    roi_signals_cap = ts(i).load_var('roi_signals_cap',[]);
    dilation_episodes = ts(i).load_var('dilation_episodes');
    
    if isempty(roi_signals_cap)
        continue;
    end
    
    % Exclude ROIs close to vessels.
    ves_pos = (diameter.vessel_position(:,[1,3]) + diameter.vessel_position(:,[2,4]))/2;
    I = false(height(roi_signals_cap),1);
    for j = 1:height(diameter) 
        dist = vecnorm(roi_signals_cap.pos - ves_pos(j,:), 2, 2) * diameter.vessel_dx(j) * diameter.vessel_dx(j);
        I(dist < closest_ROI) = true;
    end
    roi_signals_cap(I,:) = [];
    if isempty(roi_signals_cap)
        begonia.logging.log("No ROIs outside limit");
        continue;
    end
    
    % Make a new table with the combination of each ROI and each dilation
    % episode.
    tbls = {};
    for j = 1:height(dilation_episodes)
        tbl = repmat(dilation_episodes(j,:), height(roi_signals_cap), 1);
        tbls{j} = [tbl, roi_signals_cap(:,["roi_id","signal","fs"])];
    end
    roi_cap_dilation = cat(1,tbls{:});
    
    % Only include ROI traces around the dilation
    roi_cap_dilation.st = round((roi_cap_dilation.ep_start - sec_before_episode) .* roi_cap_dilation.fs) + 1;
    roi_cap_dilation.en = roi_cap_dilation.st + round((sec_before_episode + sec_after_episode) .* roi_cap_dilation.fs);
    roi_cap_dilation(roi_cap_dilation.st < 1,:) = [];
    roi_cap_dilation(roi_cap_dilation.en > length(roi_cap_dilation.signal{1}),:) = [];
    for j = 1:height(roi_cap_dilation)
        roi_cap_dilation.signal{j} = roi_cap_dilation.signal{j}(roi_cap_dilation.st(j):roi_cap_dilation.en(j));
    end
    
    % Change from cell array to matrix.
    roi_cap_dilation.signal = cat(1,roi_cap_dilation.signal{:});
    
    % Calculate df/f0 around the start point. 
    roi_cap_dilation.signal = roi_cap_dilation.signal ./ roi_cap_dilation.signal(:,round(sec_before_episode * roi_cap_dilation.fs(1))) - 1;
    
    % Clean up table
    roi_cap_dilation.st = [];
    roi_cap_dilation.en = [];
    roi_cap_dilation.ep_start = [];
    roi_cap_dilation.ep_end = [];
    roi_cap_dilation.ep = [];
    
    ts(i).save_var(roi_cap_dilation);
end

