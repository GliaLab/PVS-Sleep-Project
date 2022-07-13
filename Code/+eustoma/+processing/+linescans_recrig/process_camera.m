begonia.logging.set_level(1);

%%
trials = eustoma.get_linescans_recrig(true);
trials = trials(trials.has_var('trial_id'));

%%

yucca.processing.mark_camera.process_camera(trials);