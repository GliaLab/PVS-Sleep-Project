function path = get_data_path()
path = which('eustoma.get_data_path');
path = fileparts(path);
path = fileparts(path);
path = fileparts(path);
path = fullfile(path,'Data');
end

