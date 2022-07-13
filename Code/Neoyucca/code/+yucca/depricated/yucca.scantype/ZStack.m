classdef ZStack < yucca.scantype.PrairieOutput 
    %LINESCAN Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        laser_wavelength;
    end
    
    methods
        function obj = ZStack(path)
            obj@yucca.scantype.PrairieOutput(path)
            
            % assert we are a linescan:
            assert(strcmp(obj.type, 'ZSeries'), ...
                    'begonia:invalid_stack:not_zstack_sequence_type', ...
                    'Not a zstack according to type');
               
        end
    end
    
end

