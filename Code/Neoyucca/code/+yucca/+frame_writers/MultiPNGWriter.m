classdef MultiPNGWriter < yucca.frame_writers.FrameWriter
    %MULTIPNGWRITER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        OutputDir
        As16Bit = 1;
        Status
    end
    
    properties (Access = private)
        CurrentOutputIdent
        CurrentNumber
        Suffix = '.png';
    end
    
    methods
        
        function obj = MultiPNGWriter(output_dir, as_16bit)
            obj.OutputDir = output_dir;
            obj.As16Bit = as_16bit;
        end
        
        function write_2D_frame(obj, data)
            filename = fullfile(obj.OutputDir, [obj.CurrentOutputIdent '-' num2str(obj.CurrentNumber) obj.Suffix]);
            obj.CurrentNumber = obj.CurrentNumber + 1;
            
            if obj.As16Bit
                data = yucca.util.as_16bit_frame(data);
            end
            imwrite(data, filename);
        end
        
        function start_series(obj, ident)
            obj.CurrentNumber = 1;
            obj.CurrentOutputIdent = char(ident);
            obj.Status = 'open';
        end
        
        function end_series(obj)
            obj.Status = 'closed';
        end
    end
    
end

