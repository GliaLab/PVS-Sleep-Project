function s = is_trial( path )

s = exist(fullfile(path,'Logpart.csv'),'file') == 2;

% path = char(path);
% f_infos = dir(path);
% f_names = string({f_infos.name});
% 
% %[~,name,~] = fileparts(path);
% %s = contains(name, 'TSeries') && length(f_tifs) > 1;
% s = any(contains(f_names, 'Logpart.csv') == 1);

end

