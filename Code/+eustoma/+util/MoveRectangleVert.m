classdef MoveRectangleVert < handle
    
    events
        DoneDrawing
        PositionChanged
    end
    
    properties
        Fig
        Ax
        RectangleObj
        Active_IX
        Tag
        State
        TimeText
        ShowTime
        original_color
    end
    
    properties(SetObservable)
         Position
    end
    
    methods
        function obj = MoveRectangleVert(fig, ax, pos, tag, showtime)
            if nargin < 4
                obj.Fig = gcf;
                obj.Ax = gca;
                obj.Tag = 'Marker';
                obj.Position = [obj.Ax.XLim(1), min(obj.Ax.YLim)+range(obj.Ax.YLim)/3, range(obj.Ax.XLim), range(obj.Ax.YLim)*1/3];
                obj.Position = round(obj.Position);
            else
                obj.Fig = fig;
                obj.Ax = ax;
                obj.Position = [obj.Ax.XLim(1), pos(1), range(obj.Ax.XLim), pos(2)-pos(1)];
                obj.Tag = tag;
            end
            
            if nargin < 5
                obj.ShowTime = true;
            else
                obj.ShowTime = showtime;
            end
            setappdata(obj.Fig, 'initial_wbmfcn', obj.Fig.WindowButtonMotionFcn);
            setappdata(obj.Fig, 'initial_wbdfcn', obj.Fig.WindowButtonDownFcn);
            setappdata(obj.Fig, 'initial_wbufcn', obj.Fig.WindowButtonUpFcn);
            setappdata(obj.Fig, 'initial_wkpfcn', obj.Fig.WindowKeyPressFcn);
            addlistener(obj, 'PositionChanged', @obj.update_text_box);
            obj.draw_rectangle;
            obj.deactivate_movefcn();
        end
        
        function delete(obj)
           delete(obj.RectangleObj)
           if obj.ShowTime
                delete(obj.TimeText.Time1)
                delete(obj.TimeText.Time2)
                delete(obj.TimeText.Time3)
           end
           delete(obj)
        end
        
        function make_selectable(obj, onoff)
           switch onoff
               case 'on'
                    obj.RectangleObj.ButtonDownFcn = @obj.select_rect;
               case 'off'
                   obj.RectangleObj.ButtonDownFcn = @obj.callback_rectangle;
           end  
          
        end
        function select_rect(obj, src, event)
            if strcmp(obj.RectangleObj.UserData, 'selected')
                obj.RectangleObj.FaceColor = [obj.original_color 0.3];
                obj.RectangleObj.EdgeColor = [obj.original_color 0.3];
                obj.RectangleObj.UserData = [];
            else
                obj.RectangleObj.UserData = 'selected';
                obj.original_color = obj.RectangleObj.FaceColor;
                obj.RectangleObj.FaceColor = [0 1 0 1];
                obj.RectangleObj.EdgeColor = [0 1 0 1];
            end
        end
        
        function draw_rectangle(obj)
            obj.RectangleObj = rectangle(obj.Ax, 'Position', obj.Position);
            obj.RectangleObj.Tag = obj.Tag;
            obj.RectangleObj.LineWidth = 3;
            obj.RectangleObj.FaceColor = [0 1 0 0.2];
            obj.RectangleObj.EdgeColor = [0 1 0 0.2];
            obj.RectangleObj.ButtonDownFcn = @obj.callback_rectangle;
            if obj.ShowTime
                if obj.Ax.YLim(2)-obj.Ax.YLim(1) > 1
                    obj.TimeText.Time1 = text(obj.Ax, range(obj.Ax.XLim)/2, obj.Position(2), sprintf('%.1f', obj.Position(2)), 'Parent', obj.Ax, 'HorizontalAlignment', 'center');
                    obj.TimeText.Time2 = text(obj.Ax, range(obj.Ax.XLim)/2, (obj.Position(2)+obj.Position(4)),  sprintf('%.1f', (obj.Position(2)+obj.Position(4))), 'Parent', obj.Ax, 'HorizontalAlignment', 'center');
                    obj.TimeText.Time3 = text(obj.Ax, range(obj.Ax.XLim)/2, (obj.Position(2)+obj.Position(4)/2), sprintf('%.1f', (obj.Position(2)+obj.Position(4)/2)), 'Parent', obj.Ax, 'HorizontalAlignment', 'center');
                else
                    obj.TimeText.Time1 = text(obj.Ax, range(obj.Ax.XLim)/2, obj.Position(2), sprintf('%.3f', obj.Position(1)), 'Parent', obj.Ax, 'HorizontalAlignment', 'center');
                    obj.TimeText.Time2 = text(obj.Ax, range(obj.Ax.XLim)/2, (obj.Position(2)+obj.Position(4))+range(obj.Ax.YLim)/5, sprintf('%.3f', (obj.Position(1)+obj.Position(3))), 'Parent', obj.Ax, 'HorizontalAlignment', 'center');
                    obj.TimeText.Time3 = text(obj.Ax, range(obj.Ax.XLim)/2, (obj.Position(2)+obj.Position(4))+range(obj.Ax.YLim)/5, sprintf('%.3f', obj.Position(4)), 'Parent', obj.Ax, 'HorizontalAlignment', 'center');
                end
            end
        end
        
        function update_text_box(obj, src, event)
            if obj.ShowTime
                if obj.Ax.YLim(2)-obj.Ax.YLim(1) > 1
                    obj.TimeText.Time1.Position(2) = event.Pos(1);
                    obj.TimeText.Time1.String = sprintf('%.0f',obj.TimeText.Time1.Position(2));
                    obj.TimeText.Time2.Position(2) = event.Pos(2);
                    obj.TimeText.Time2.String = sprintf('%.0f',obj.TimeText.Time2.Position(2));
                    obj.TimeText.Time3.Position(2) = event.Pos(1)+(event.Pos(2)-event.Pos(1))/2;
                    obj.TimeText.Time3.String = sprintf('%.0f',(event.Pos(2)-event.Pos(1)));
                else
                    obj.TimeText.Time1.Position(2) = event.Pos(1);
                    obj.TimeText.Time1.String = sprintf('%.0f',obj.TimeText.Time1.Position(2));
                    obj.TimeText.Time2.Position(2) = event.Pos(2);
                    obj.TimeText.Time2.String = sprintf('%.0f',obj.TimeText.Time2.Position(2));
                    obj.TimeText.Time3.Position(2) = event.Pos(1)+(event.Pos(2)-event.Pos(1))/2;
                    obj.TimeText.Time3.String = sprintf('%.0f',(event.Pos(2)-event.Pos(1)));
                end
            end
        end
        
        function callback_rectangle(obj,src, eventdata)
            set(obj.Fig,'WindowButtonDownFcn',@obj.activate_movefcn);
            set(obj.Fig,'WindowButtonUpFcn',@obj.deactivate_movefcn);
            obj.activate_movefcn(src, eventdata);
        end
        
       
        
        function activate_movefcn(obj,src, eventdata)
            set(obj.Fig,'WindowButtonMotionFcn',{@obj.movefcn src});
            coords = get(obj.Ax, 'CurrentPoint');
            dst(1) = coords(1,2)-src.Position(2);
            dst(2) = coords(1,2)-(src.Position(2)+src.Position(4));
            [~, obj.Active_IX] = min(abs(dst));
        end
        
        function movefcn(obj, src, eventdata, rectobj)
            coords = get(obj.Ax, 'CurrentPoint');
            xl = get(gca,'xlim');
            yl = get(gca,'ylim');
            outX = ~any(diff([xl(1) coords(1,1) xl(2)])<0);
            outY = ~any(diff([yl(1) coords(1,2) yl(2)])<0);
            if outX && outY
                if obj.Active_IX == 1
                     h = gca;
                    if (rectobj.Position(2)+rectobj.Position(4))-coords(1,2) <= 0
                       
                        rectobj.Position(4) = range(h.YLim)/1000;
                    else
                        rectobj.Position(4) = (rectobj.Position(2)+rectobj.Position(4))-coords(1,2);
                    end
                    rectobj.Position(2) = coords(1,2);
                    
                elseif obj.Active_IX == 2
                    h = gca;
                    if (coords(1,2)-rectobj.Position(2)) <= 0
                        
                        rectobj.Position(4) = range(h.YLim)/1000;
                        rectobj.Position(2) = coords(1,2);
                    else
                        rectobj.Position(4) = coords(1,2)-rectobj.Position(2);
                    end
                end
                event = eustoma.util.UniversalEvent;
                event.addprop('Pos');
                event.Pos = [rectobj.Position(2), (rectobj.Position(2)+rectobj.Position(4))];
                notify(obj, 'PositionChanged', event)
            end
        end
        
        function deactivate_movefcn(obj, src, eventdata)           
            set(obj.Fig,'WindowButtonMotionFcn',getappdata(obj.Fig,'initial_wbmfcn'));
            set(obj.Fig,'WindowButtonDownFcn',getappdata(obj.Fig,'initial_wbdfcn'));
            set(obj.Fig,'WindowButtonUpFcn',getappdata(obj.Fig,'initial_wbufcn'));
            
            notify(obj, 'DoneDrawing')
        end
        
    end
end
