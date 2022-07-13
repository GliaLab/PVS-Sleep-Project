classdef PupilRecording < handle
    %PUPDATASOURCE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        path
        files
        frame_times
        frame_offset_s
        
        
    end
    
    properties(Access=private)
        frame_times_ = [];
        frame_offset_s_ = [];
    end
    
    methods
        function obj = PupilRecording(path)
            obj.path = path;
            
            % load file metadata:
            fileinfos = dir(obj.path);
            filenames = {fileinfos.name};
            obj.files = string(filenames(endsWith(filenames, ".png")));
        end
        
        function times = get.frame_times(obj)
            
            if ~isempty(obj.frame_times_)
                times = obj.frame_times_;
                return;
            end
            
            obj.frame_times_ = repmat(datetime, length(obj.files), 1);
            
            i = 1;
            for file = obj.files
                fname = char(file);
                datestamp = fname(end-13:end-4);
                t = datetime(datestamp,'InputFormat', 'HHmmss.SSS');
                obj.frame_times_(i) = t;
                i = i + 1;
            end
            
            times = obj.frame_times_;
        end
        
        function durs = get.frame_offset_s(obj)
            
            if ~isempty(obj.frame_offset_s_)
               durs =  obj.frame_offset_s_;
               return;
            end
            
            durs = zeros(length(obj.frame_times), 1);
            
            i = 1;
            for file = obj.files
                durs(i) = seconds(obj.frame_times(i) - obj.frame_times(1)); 
                i = i + 1;
            end
            
            obj.frame_offset_s_ = durs;
        end
        
        function [frame, file, t, offset_s] = read(obj, i)
            file = fullfile(obj.path, obj.files(i));
            t = obj.frame_times(i);
            offset_s = obj.frame_offset_s(i);
            frame = imread(file);
        end
        
        % reads frame at time s:
        function [frame, file, t, offset_s] = read_at_sec(obj, sec)
            [~, i] = min(abs(obj.frame_offset_s - sec));
            [frame, file, t, offset_s] = obj.read(i);
        end
    end
end

