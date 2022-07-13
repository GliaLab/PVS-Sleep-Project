classdef IsStabilizedMod < xylobium.dledit.model.Modifier
        
    methods
        
        function obj = IsStabilizedMod()
            obj = obj@xylobium.dledit.model.Modifier("stabilized", false, true);
        end
        
        function stabilized = onLoad(obj, dloc, ~, ~)
            dir = dloc.load_var("stabilization_output_dir",[]);
            if isempty(dir)
                stabilized = false;
                return;
            end

            % Create the file path of the stabilized tseries.
            output_path = strrep(dloc.path,'TSeries unaligned',dir);
            [a,b] = fileparts(output_path);
            output_path = fullfile(a,b);
            output_path = string(output_path);
            
            % Try to load the tseries. If the file does not exist the
            % following instructions will crash.
            try
                begonia.scantype.h5.TSeriesH5(char(output_path+".h5"));
                stabilized = true;
                return
            end
            try
                begonia.scantype.tiff.TSeriesTIFF(char(output_path+".tif"));
                stabilized = true;
                return
            end

            % If the code goes here the two previous loading of the TSeries
            % failed. 
            stabilized = false;
        end
    end
end
