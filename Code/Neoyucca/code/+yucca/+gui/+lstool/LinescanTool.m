classdef LinescanTool < handle
    %LINESCANTOOL Summary of this class goes here
    %   Detailed explanation goes here

    properties
        Figure
        ScanAxes = [];
        RefFigAxes
        
        
        StackList
        CurrentStack
        
        AngleLine
        ScanLine
        DirectionMarker
        
        ScanFilenamePattern
        SourceFilenamePattern
        
        Button_SetAngle
        Button_DetectAngle
        Button_Invalid

        MessageLabel
    end
    
    methods
        
         function obj = LinescanTool(stacklist, scan_pattern)

            obj.StackList = stacklist;
            obj.CurrentStack  = stacklist(1);
            
            obj.ScanFilenamePattern = scan_pattern;
            
            obj.setupGUI();
            obj.loadData();

         end
         
        function setupGUI(obj)
            % figure:
            obj.Figure = figure('Visible','on','Position',[100,100,1000,500]);
            
            obj.ScanAxes = axes(obj.Figure);
            setpixelposition(obj.ScanAxes, [200 50 400 450]);
            
            obj.RefFigAxes = axes(obj.Figure);
            setpixelposition(obj.RefFigAxes, [600 50 400 450]);
            
            lb = uicontrol(obj.Figure, 'Style','listbox');
            setpixelposition(lb, [10 50 200 450]);
            lb.String = {obj.StackList.name};
            lb.Callback = @obj.handle_list_selection;
            
            imagesc(rand(300), 'Parent', obj.ScanAxes);
            
            % angle buttons
            obj.Button_SetAngle = uicontrol(obj.Figure, 'Style','pushbutton', 'String','Set angle','Position',[10,10,100,30]);
            obj.Button_DetectAngle = uicontrol(obj.Figure, 'Style','pushbutton', 'String','Detect angle','Position',[110,10,100,30]);
            obj.Button_SetAngle.Callback = @obj.handle_set_angle_manual;
            obj.Button_DetectAngle = @obj.handle_set_angle_automatic; 
            
            % invalid button:
            obj.Button_Invalid = uicontrol(obj.Figure, 'Style','pushbutton', 'String','Invalid scan','Position',[210,10,100,30]);
            obj.Button_Invalid.Callback = @obj.handle_set_invalid;
            
            % message box:
            obj.MessageLabel = uicontrol(obj.Figure, 'Style','text', 'String','Welcome Welcome Welcome Welcome Welcome','Position',[320,10,880,25]);
            obj.MessageLabel.FontSize = 10;
            obj.MessageLabel.HorizontalAlignment = 'Left';
    
        end
        
        function loadData(obj)
            colormap(obj.RefFigAxes, 'hot');
            obj.Figure.Name = ['Linescan Viewer :: ' obj.CurrentStack.name];
            
            % load scan image:
            finfos = dir(obj.CurrentStack.path);
            filenames = {finfos.name}';
            
            % scan image:
            scan_files = filenames(contains(filenames, obj.ScanFilenamePattern));
            scan_file = scan_files(contains(scan_files, 'ome.tif'));
            src_file = scan_files(contains(scan_files, 'Source.tif'));
            
            scan_img_path = fullfile(obj.CurrentStack.path, char(scan_file))
            src_img_path = fullfile(obj.CurrentStack.path, char(src_file))
            
            scan_img = yucca.util.as_16bit_frame(imread(scan_img_path));
            src_img = imread(src_img_path);
            
            imshow(scan_img, 'Parent', obj.ScanAxes);
            imagesc(src_img, 'Parent', obj.RefFigAxes);
            hold(obj.ScanAxes,'on')
            hold(obj.RefFigAxes,'on')
 
            obj.draw_scan();
            
        end
    end
    
    
     methods (Access = private)
         
         function handle_set_angle_manual(obj, ~, ~)
             if ~isempty(obj.AngleLine)
                 delete(obj.AngleLine);
             end
             obj.AngleLine = imline(obj.ScanAxes);
             
             
             % check direction:
            pos = obj.AngleLine.getPosition();
            if pos(3) - pos(1) < 0
                 obj.MessageLabel.String  = 'Please draw from left to right';
                 return;
            else
                addNewPositionCallback(obj.AngleLine, @obj.handle_imline_new_position);
                obj.update_data();
            end
         end
         
         function handle_set_angle_automatic(obj, ~, ~)
             msgbox('Not implemented');
         end
         
         function handle_set_invalid(obj, ~, ~)
             obj.CurrentStack.clear_var('LSLine');
             obj.CurrentStack.save_var('LSStatus', 'INVALID'); 
         end
         
         function handle_imline_new_position(obj, ~, ~)
             obj.update_data();
         end
         
         
         function handle_list_selection(obj, ~, ev)
            obj.CurrentStack = obj.StackList(ev.Source.Value);
            obj.loadData();
            
         end
         
         
         function update_data(obj)
            pos = obj.AngleLine.getPosition();
            

            ang = atan2(pos(4)-pos(3),pos(2)-pos(1));
            ang_deg = rad2deg(ang);

            % determine slope:
            if ang_deg > 0
                slope = 'DECENDING (w/scan direction)';
                obj.CurrentStack.save_var('LSFlowDirection', 'with');
            else
                slope = 'ASCENDING (against scan direction)';
                obj.CurrentStack.save_var('LSFlowDirection', 'against');
            end
            
            % save line:
            line = struct();
            line.start_x = obj.CurrentStack.first_point(1);
            line.start_y = obj.CurrentStack.first_point(2);
            line.end_x = obj.CurrentStack.last_point(1);
            line.end_y = obj.CurrentStack.last_point(2);
            obj.CurrentStack.save_var('LSLine', line);
            obj.CurrentStack.save_var('LSStatus', 'OK'); 
            
            obj.MessageLabel.String = ['Angle: ' num2str(ang_deg) '�, ' slope ' slope. Flow speed: --.' ' Saved to datalocation' ];
            
            % draw and save output if asked:
            obj.draw_scan();
            obj.save_scan_image();
         end

         
        function draw_scan(obj)
            if ~obj.CurrentStack.has_var('LSLine')
                return;
            end
            
            delete(obj.ScanLine);
            delete(obj.DirectionMarker);
            
            line_cords = obj.CurrentStack.load_var('LSLine');
            direction = obj.CurrentStack.load_var('LSFlowDirection');
            
            x = [line_cords.start_x line_cords.end_x];
            y = [line_cords.start_y line_cords.end_y];
            obj.ScanLine = line(obj.RefFigAxes, x, y, 'Color','green','LineStyle','-', 'LineWidth', 3);
            
             rpos = [];
             if strcmp(direction, 'with')
                rpos = [line_cords.end_x - 5, line_cords.end_y - 5, 10, 10];
             elseif strcmp(direction, 'against')
                rpos = [line_cords.start_x - 5, line_cords.start_y - 5, 10, 10];  
             end
             
            obj.DirectionMarker = rectangle(obj.RefFigAxes, 'Position', rpos, ...
                'FaceColor','green', 'Curvature',[1 1], 'EdgeColor','g');
            
        end
        
                 
         
        function save_scan_image(obj)

            f2 = figure('Position', [100 100 512 512] ,'Visible', 'off');
            ax = copyobj(obj.RefFigAxes, f2);
            ax.Position = [0,0,1,1];
            
            outpath = fullfile(obj.CurrentStack.dloc_metadata_dir, 'lstool_output.png');
            saveas(f2, outpath);
            delete(f2);
            disp(['Wrote image to: ' outpath])
            
        end
             
             
        
     end
    
end

