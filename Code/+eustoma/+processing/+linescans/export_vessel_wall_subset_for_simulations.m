
% This script exports the selected datat that was used in the simulation
% analysis.


%% Pial arteries
dir_in = fullfile(get_project_path(),"Plot","Lumen Vessel Wall CSV Awakening");
dir_out = fullfile(get_project_path(),"Plot","Vessel Wall CSV used in simulations","Pials");

files = begonia.path.find_files(dir_in,"Pial");
files = [files{:}];

for i = 1:length(files)
    file_out = strrep(files(i),dir_in,dir_out);
    begonia.path.make_dirs(file_out);
    copyfile(files(i),file_out);
end

%% Veins
dir_in = fullfile(get_project_path(),"Plot","Vessel Wall CSV Clean + Awakening");
dir_out = fullfile(get_project_path(),"Plot","Vessel Wall CSV used in simulations","Veins");

files = begonia.path.find_files(dir_in,"Vein");
files = [files{:}];

for i = 1:length(files)
    file_out = strrep(files(i),dir_in,dir_out);
    begonia.path.make_dirs(file_out);
    copyfile(files(i),file_out);
end


%% Penetrating Arteriole
dir_in = fullfile(get_project_path(),"Plot","Vessel Wall CSV Clean + Awakening");
dir_out = fullfile(get_project_path(),"Plot","Vessel Wall CSV used in simulations","PenetratingArterioles");

files = begonia.path.find_files(dir_in,"Penetrating Arteriole");
files = [files{:}];

for i = 1:length(files)
    file_out = strrep(files(i),dir_in,dir_out);
    begonia.path.make_dirs(file_out);
    copyfile(files(i),file_out);
end




