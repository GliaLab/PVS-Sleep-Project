function path = get_plot_path()
path = which('eustoma.get_plot_path');
path = fileparts(path);
path = fileparts(path);
path = fileparts(path);
path = fullfile(path,'Plot');
end

