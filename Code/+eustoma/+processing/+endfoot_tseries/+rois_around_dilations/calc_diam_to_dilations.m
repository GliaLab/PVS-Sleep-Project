begonia.logging.set_level(1);

ts = eustoma.get_endfoot_tseries();
ts = ts(ts.has_var('dilation_episodes'));
ts = ts(ts.has_var('diameter'));

%%
sec_before_episode = 15;
sec_after_episode = 15;

for i = 1:length(ts)
    begonia.logging.log(1,"TSeries (%d/%d)",i,length(ts));
    
    diameter = ts(i).load_var('diameter');
    diameter_dilation = ts(i).load_var('dilation_episodes');
    
    % Clean up tables
    diameter.vessel_position = [];
    diameter.vessel_dx = [];
    diameter.vessel_upper = [];
    diameter.vessel_lower = [];
    
    % Add vessel diameter traces to each dilation episode. 
    diameter_dilation = innerjoin(diameter_dilation,diameter);
    
    % Edit the diameter traces to only include a part before and after the
    % episode start.
    diameter_dilation.st = round((diameter_dilation.ep_start - sec_before_episode) .* diameter_dilation.vessel_fs) + 1;
    diameter_dilation.en = diameter_dilation.st + round((sec_before_episode + sec_after_episode) .* diameter_dilation.vessel_fs);
    diameter_dilation(diameter_dilation.st < 1,:) = [];
    diameter_dilation(diameter_dilation.en > length(diameter_dilation.diameter{1}),:) = [];
    for j = 1:height(diameter_dilation)
        diameter_dilation.diameter{j} = diameter_dilation.diameter{j}(diameter_dilation.st(j):diameter_dilation.en(j));
    end
    
    % Remove the indices used to align the traces.
    diameter_dilation.st = [];
    diameter_dilation.en = [];
    
    % Change from cell array to matrix.
    diameter_dilation.diameter = cat(1,diameter_dilation.diameter{:});
    
    % Calculate dilation difference
    diameter_dilation.diameter = diameter_dilation.diameter - diameter_dilation.diameter(:,round(sec_before_episode * diameter_dilation.vessel_fs(1)));
    
    ts(i).save_var(diameter_dilation);
end

