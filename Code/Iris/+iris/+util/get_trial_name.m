function name = get_trial_name(dloc)
% Return a string which is the path of the trial but with file seperator
% character replaced with whitespace and the project directory folder, the 
% "Data" folder, and the subfolder of "Data" removed.

name = strrep(string(dloc.path),get_project_path,"");
name = split(name,filesep);
name = join(name(4:end));

end

