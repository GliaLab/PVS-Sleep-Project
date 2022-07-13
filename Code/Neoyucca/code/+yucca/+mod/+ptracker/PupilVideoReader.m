classdef PupilVideoReader < handle
    %PUPILVIDEOREADER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        path
        frame_count
        png_files 
        frame_time
        frame_time_abs
        frame_delta_s
        
        start_time
        end_time
    end
    
    methods
        function obj = PupilVideoReader(path)
            obj.path = path;
            obj.load();
        end
        
        function load(obj)
            % load png file paths:
            obj.png_files = begonia.path.find_files(obj.path, '.png');
            obj.frame_count = length(obj.png_files);
            
            % load times for each file:
            stamps_str = cellfun(@(p) p(end-24:end-4), obj.png_files, 'UniformOutput', false);
            stamps = cellfun(@(s) ...
                datetime(s, 'InputFormat','yyyy_MM_dd_HHmmss.SSS', 'Format', 'yyyy-MM-dd hh:mm:ss.SSS'), ...
                stamps_str, 'UniformOutput', false);
            obj.frame_time_abs = [stamps{:}];
            
            % calculate frame time differences:
            obj.frame_delta_s = zeros(obj.frame_count, 1);
            for i = 2:obj.frame_count
                d = obj.frame_time_abs(i) - obj.frame_time_abs(i-1);
                obj.frame_delta_s(i) = seconds(d);
            end
            obj.frame_delta_s = obj.frame_delta_s';
            
            % calculate frame time from start:
            obj.frame_time = zeros(obj.frame_count, 1);
            for i = 1:obj.frame_count
                d = obj.frame_time_abs(i) - obj.frame_time_abs(1);
                obj.frame_time(i) = seconds(d);
            end
            obj.frame_time = obj.frame_time'
            
            % some data:
            obj.start_time = obj.frame_time_abs(1);
            obj.end_time = obj.frame_time_abs(end);
        end
        
        function img = read_frame(obj, fnr)
            fpath = obj.png_files(fnr);
            fpath = fpath{:};
            img = imread(fpath);
        end
        
        function [img, fnr] = read_frame_at_second(obj, sec)
            fts = obj.frame_time;
            fnr = [];
            for i = 2:obj.frame_count
                if fts(i-1) <= sec && fts(i) > sec
                    fnr = i;
                end
            end
            
            img = obj.read_frame(fnr);
        end
    end
end

