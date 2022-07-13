begonia.logging.set_level(1);

trials = eustoma.get_endfoot_recrigs();
trials = trials(trials.has_var('mouse'));
trials = trials(trials.has_var('ephys'));

for i = 1:length(trials)
    begonia.logging.log(1,'%d/%d',i,length(trials));
    
    ecog_note = trials(i).load_var('ecog_note','');
    if isequal(ecog_note,'bad')
        continue;
    end
    
    ephys_norm = trials(i).load_var('ephys');
    
    ecog_normalization_factor = std(ephys_norm.ecog);
    
    ephys_norm.ecog = ephys_norm.ecog - median(ephys_norm.ecog);
    ephys_norm.ecog = ephys_norm.ecog / std(ephys_norm.ecog);
    
    ephys_norm.emg = ephys_norm.emg - median(ephys_norm.emg);
    ephys_norm.emg = ephys_norm.emg / std(ephys_norm.emg);
    
    
    trials(i).save_var(ephys_norm);
    trials(i).save_var(ecog_normalization_factor);
    
end

% Old normalization method below.
%% Gather all ECoG in NREM and normalize each trial based on NREM episodes per mosue
% begonia.logging.set_level(1);
% 
% trials = eustoma.get_endfoot_recrigs();
% trials = trials(trials.has_var('mouse'));
% 
% tbl = table;
% tbl.mouse = begonia.util.catvec(length(trials),1);
% tbl.ecog_in_nrem = cell(length(trials),1);
% tbl.ecog_fs = zeros(length(trials),1);
% tbl.trial_object = trials';
% 
% begonia.logging.backwrite()
% for i = 1:length(trials)
%     begonia.logging.backwrite(1,'%d/%d',i,length(trials));
%     
%     tr = trials(i);
%     
%     tbl.mouse(i) = tr.load_var('mouse');
%     
%     sleep_episodes = tr.load_var('sleep_episodes',[]);
%     if isempty(sleep_episodes) || ~ismember('NREM',sleep_episodes.state)
%         continue;
%     end
%     
%     nrem_episodes = sleep_episodes(sleep_episodes.state == 'NREM',:);
%     
%     ecog_note = tr.load_var('ecog_note','');
%     if isequal(ecog_note,'bad')
%         continue;
%     end
%     
%     ephys = tr.load_var('ephys',[]);
%     if isempty(ephys)
%         continue;
%     end
%     
%     ecog = ephys.ecog - median(ephys.ecog);
%     ecog_fs = ephys.Properties.SampleRate;
%     
%     % Calculate a vector with equal length as the traces with true where the
%     % nrem episodes are. 
%     nrem_vec = false(length(ecog),1);
%     for j = 1:height(nrem_episodes)
%         st = round(nrem_episodes.state_start(j) * ecog_fs) + 1;
%         en = round(nrem_episodes.state_end(j) * ecog_fs) + 1;
%         if en > length(nrem_vec)
%             en = length(nrem_vec);
%         end
%         nrem_vec(st:en) = true;
%     end
%     
%     tbl.ecog_in_nrem{i} = ecog(nrem_vec);
%     tbl.ecog_fs(i) = ecog_fs;
% end
% 
% % Make sure everthing is sampled at the same rate. 
% fs_vec = tbl.ecog_fs;
% fs_vec(fs_vec == 0) = [];
% assert(~isempty(fs_vec));
% assert(all(fs_vec == fs_vec(1)),'Sampling rate for all trials are not identical.');
% 
% %% Calculate a normalization factor for each mouse. 
% G = findgroups(tbl.mouse);
% w = splitapply(@get_norm_factor, ...
%     tbl.ecog_in_nrem,tbl.ecog_fs, ...
%     G);
% 
% tbl.ecog_weight = w(G);
% 
% %% Assign the normalized ecog.
% for i = 1:height(tbl)
%     tr = tbl.trial_object(i);
%     
%     ecog_normalization_factor = 1/tbl.ecog_weight(i);
%     if isnan(ecog_normalization_factor)
%         continue;
%     end
%     
%     ephys = tr.load_var('ephys',[]);
%     if isempty(ephys)
%         continue;
%     end
%     
%     ephys_norm = ephys;
%     ephys_norm.ecog = ephys_norm.ecog - median(ephys_norm.ecog);
%     ephys_norm.ecog = ephys_norm.ecog * ecog_normalization_factor;
%     
%     tr.save_var(ephys_norm);
%     tr.save_var(ecog_normalization_factor);
%     
% end
% 
% function w = get_norm_factor(ecog,ecog_fs)
% ecog_fs(ecog_fs == 0) = [];
% ecog_fs = ecog_fs(1);
% 
% ecog_merged_nrem = cat(1,ecog{:});
% 
% if isempty(ecog_merged_nrem)
%     w = nan;
% else
%     freq_band = [0.5,30];
%     w = sqrt(bandpower(ecog_merged_nrem, ecog_fs, freq_band));
% end
% end
