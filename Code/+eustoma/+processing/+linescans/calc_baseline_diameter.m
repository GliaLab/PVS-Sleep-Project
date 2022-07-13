begonia.logging.set_level(1);
scans = eustoma.get_linescans();
scans = scans(scans.has_var('diameter_green') | scans.has_var('diameter_red') | scans.has_var('diameter_peri'));
%%
for i = 1:length(scans)
    episodes = scans(i).load_var('baseline_episodes',[]);
    N_episodes = height(episodes);
    
    diameter_green_baseline = scans(i).load_var('diameter_green',[]);
    diameter_red_baseline = scans(i).load_var('diameter_red',[]);
    diameter_peri_baseline = scans(i).load_var('diameter_peri',[]);
    
    %% Ignore samples
    if ~isempty(diameter_green_baseline)
        I_ignore = false(1, length(diameter_green_baseline.diameter{1}));
    else
        I_ignore = false(1, length(diameter_red_baseline.diameter{1}));
    end
    
    ignored_episodes_green = scans(i).load_var("ignored_episodes_green",[]);
    if ~isempty(ignored_episodes_green)
        for j = 1:height(ignored_episodes_green)
            st = round(ignored_episodes_green.start(j));
            en = round(ignored_episodes_green.end(j));
            if en > length(I_ignore)
                en = length(I_ignore);
            end
            I_ignore(st:en) = true;
        end
    end
    ignored_episodes_red = scans(i).load_var("ignored_episodes_red",[]);
    if ~isempty(ignored_episodes_red)
        for j = 1:height(ignored_episodes_red)
            st = round(ignored_episodes_red.start(j));
            en = round(ignored_episodes_red.end(j));
            if en > length(I_ignore)
                en = length(I_ignore);
            end
            I_ignore(st:en) = true;
        end
    end
        
    % Green
    if ~isempty(diameter_green_baseline)
        for j = 1:height(diameter_green_baseline)
            diameter_green_baseline.diameter{j}(I_ignore) = nan;
        end
    end
    
    % Red
    if ~isempty(diameter_red_baseline)
        diameter_red_baseline.baseline = zeros(height(diameter_red_baseline),1);
        for j = 1:height(diameter_red_baseline)
            diameter_red_baseline.diameter{j}(I_ignore) = nan;
        end
    end
    
    % Peri
    if ~isempty(diameter_green_baseline) && ~isempty(diameter_red_baseline)
        diameter_peri_baseline.baseline = zeros(height(diameter_peri_baseline),1);
        for j = 1:height(diameter_peri_baseline)
            diameter_peri_baseline.diameter{j}(I_ignore) = nan;
        end
    end
    
    %% Find which samples are in the baseline episodes.
    if ~isempty(diameter_green_baseline)
        I_baseline = false(1,length(diameter_green_baseline.diameter{1}));
        fs = diameter_green_baseline.vessel_fs(1);
    else
        I_baseline = false(1,length(diameter_red_baseline.diameter{1}));
        fs = diameter_red_baseline.vessel_fs(1);
    end
    
    for k = 1:N_episodes
        st = floor(episodes.state_start(k) * fs) + 1;
        en = floor(episodes.state_end(k) * fs) + 1;
        en = min(en,length(I_baseline));
        st = max(1,st);
        I_baseline(st:en) = true;
    end
    
    %% Green
    if ~isempty(diameter_green_baseline)
        diameter_green_baseline.baseline = zeros(height(diameter_green_baseline),1);
        for j = 1:height(diameter_green_baseline)
            diameter_green_baseline.baseline(j) = nanmedian(diameter_green_baseline.diameter{j}(I_baseline));
        end
        scans(i).save_var(diameter_green_baseline);
    end
    
    %% Red
    if ~isempty(diameter_red_baseline)
        diameter_red_baseline.baseline = zeros(height(diameter_red_baseline),1);
        for j = 1:height(diameter_red_baseline)
            diameter_red_baseline.baseline(j) = nanmedian(diameter_red_baseline.diameter{j}(I_baseline));
        end
        scans(i).save_var(diameter_red_baseline);
    end
    
    %% Peri
    if ~isempty(diameter_peri_baseline)
        diameter_peri_baseline.baseline = zeros(height(diameter_peri_baseline),1);
        for j = 1:height(diameter_peri_baseline)
            diameter_peri_baseline.baseline(j) = nanmedian(diameter_peri_baseline.diameter{j}(I_baseline));
        end
        scans(i).save_var(diameter_peri_baseline);
    end
end

begonia.logging.log(1,'Finished');
