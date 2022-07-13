function configure(trials)

gui = yucca.mod.camera_regions.VideoGui();
gui.load_trials(trials);
assignin('base', 'VideoGUI', gui)

end