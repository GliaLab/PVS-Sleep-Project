classdef DisplayPathMod < xylobium.dledit.model.Modifier
        
    methods
        
        function obj = DisplayPathMod()
            obj = obj@xylobium.dledit.model.Modifier("path", false, true);
        end
        
        function path = onLoad(obj, dloc, ~, ~)
            path = strrep(dloc.path,get_project_path(),"");
            path = split(path,filesep);
            path = fullfile(path{4:end});
            path = char(path);
        end
    end
end
