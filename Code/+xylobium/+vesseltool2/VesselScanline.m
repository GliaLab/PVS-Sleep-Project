classdef VesselScanline < handle
    %VESSELROI Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        name
        start_point
        end_point
        angle
        locked_means
        tags
        method
        channel
        cycle
        
        vessel_type
    end
    
    methods
        function obj = VesselScanline(type)
            % random human relatable name:
%             obj.name = ['Vessel ' ...
%                 char(randi([65 90],1,1)) ...
%                 num2str(floor(rand(1,1) * 99)) ...
%                 '-' num2str(floor(rand(1,1) * 9999))];
            obj.name = begonia.util.make_snowflake_id(type);
            
            obj.start_point = [100 100];
            obj.end_point = [200 200];
            obj.angle = 0;
            obj.tags = '';
            obj.method = 'valley_width';
            obj.channel = 1;
            obj.cycle = 1;
            obj.vessel_type = type;
        end
    end
end

