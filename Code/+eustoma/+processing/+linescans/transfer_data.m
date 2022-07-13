begonia.logging.set_level(1);

scans = eustoma.get_linescans();
scans = scans(scans.has_var('recrig'));

trials = eustoma.get_linescans_recrig();
trials = trials(trials.has_var('linescan'));

dloc_list = yucca.datanode.DataNodeList();
dloc_list.add(trials);
dloc_list.add(scans);

for i = 1:length(trials)
    scan = trials(i).find_dnode('linescan');
    
    trial_type = trials(i).load_var('trial_type',[]);
    if ~isempty(trial_type)
        scan.save_var(trial_type);
    end
end

for i = 1:length(scans)
    trial = scans(i).find_dnode('recrig');
    
    trial_id = scans(i).load_var('trial_id',[]);
    if ~isempty(trial_id)
        trial.save_var(trial_id)
    end
end