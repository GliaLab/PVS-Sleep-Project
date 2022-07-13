classdef MP4Writer < yucca.frame_writers.FrameWriter
    %MULTIPNGWRITER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
    end
    
    properties (Access = private)
        OutputDir
        Writer
    end
    
    methods
        function obj = MP4Writer(output_dir)
            obj.OutputDir = output_dir;
        end
        
        function write_2D_frame(obj, data)
            
            % covert data to double:
            data = yucca.util.as_double_frame(data);
            writeVideo(obj.Writer, data);
        end
        
        function start_series(obj, ident)
            obj.Writer = VideoWriter(fullfile(obj.OutputDir, [ident '.mp4']));
            open(obj.Writer)
        end
        
        function end_series(obj)
            close(obj.Writer);
        end
    end
    
end

