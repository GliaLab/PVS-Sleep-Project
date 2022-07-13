classdef EpisodeMarker < handle
    % gui_handle = begonia.gui.EpisodeMarker(trace_table,states,episodes_display_only,episodes)
    % 
    % After the episodes have been marked they can be extracted from the
    % gui_handle.episode_table property. 
    %
    % Example use:
    % gui_handle = begonia.gui.EpisodeMarker(trace_table,{'NREM','IS','REM'},[],existing_sleep_episodes);
    % uiwait(gui_handle.figure);
    % % Get the marked episodes from the GUI.
    % sleep_episodes = gui_handle.episode_table;
    %
    % Input parameters:
    % trace_table           - Table of traces, must contains 3 columns:
    %                       "trace", "trace_name" and "t". Here is an example:
%                              trace                    trace_name                       t         
%                         ________________    _______________________________    __________________
%                         {1×17285 double}    {'Filtered ECoG (0.5 - 30 Hz)'}    {17285×1   double}
%                         {1×576   double}    {'Delta (0.5 - 4 Hz) RMS'     }    {    1×576 double}
%                         {1×576   double}    {'Theta (5 - 9 Hz) RMS'       }    {    1×576 double}
%                         {1×576   double}    {'Sigma (10 - 16 Hz) RMS'     }    {    1×576 double}
%                         {1×576   double}    {'Theta/(Theta+Delta) Ratio'  }    {    1×576 double}
%                         {1×17285 double}    {'Filtered EMG (0-100 Hz)'    }    {17285×1   double}
    % 
    % states                - Cell array of char of states that can be
    %                         selected in the GUI. 
    %
    % episodes_display_only - (Optional) Table of episodes that will be displayed but
    %                         cannot be edited with the GUI. Can be empty. Example below:
%                             state    state_start    state_end    state_duration
%                             _____    ___________    _________    ______________
%                             NREM         63.9          82.7           18.8     
%                             IS           98.3         108.3             10     
%                             REM         130.5         141.8           11.3    
% 
    % episodes              - (Optional) Can be empty. Table must have same
    %                         format as episodes_display_only. These
    %                         episodes will be preloaded and can be edited
    %                         with the GUI. Useful for loading episodes
    %                         from a previous execution. 
    
    
    properties (SetAccess = private)
        trace_table
        states
        current_state
        state_btns
        brush_down
        episode_table
        ax_ep
        txtbox
        episode_table_display_only
        figure
    end
    
    methods
        function obj = EpisodeMarker(trace_table,states,episode_table_display_only,prev_episode_table)
            if nargin < 3
                episode_table_display_only = table;
            end
            if nargin < 4
                prev_episode_table = table;
            end
            
            if isempty(prev_episode_table)
                prev_episode_table = table;
            end
            
            states = {'Empty','Remove',states{:}};
            
            obj.trace_table = trace_table;
            obj.states = states;
            
            f = figure();
            f.Position(3:4) = [1200,800];
            f.CloseRequestFcn = @obj.on_close;
            obj.figure = f;
            
            b = brush(f);
            b.ActionPreCallback = @obj.brush_pre_callback;
            b.ActionPostCallback = @obj.brush_post_callback;
            
            hbox1 = uix.HBox('Parent',f);
            
            panel1 = uix.VBox('Parent',hbox1);
            panel2 = uix.VBox('Parent',hbox1);
            hbox1.Widths = [400,-1];
            %% Fill panel 1
            for i = 1:length(states)
                state_btns(i) = uicontrol('Style','togglebutton','Parent',panel1);
                state_btns(i).String = states{i};
                state_btns(i).Callback = @obj.on_state_btn_click;
            end
            obj.state_btns = state_btns;
            
            obj.txtbox = uitable(panel1);
            obj.txtbox.ColumnName = {'Episode','Start','End','Duration'};
            
            panel1.Heights(:) = 30;
            panel1.Heights(end) = -1;
            panel1.Padding = 20;
            panel1.Spacing = 5;
            %% Fill panel 2 with traces
            obj.trace_table.line(:) = gobjects;
            if ismember('group',obj.trace_table.Properties.VariableNames)
                [G,tmp] = findgroups(obj.trace_table(:,{'group'}));
                for i = 1:height(tmp)
                    tmp = uicontainer('Parent',panel2);
                    ax(i) = axes('Parent',tmp);
                    J = find(G == i)';
                    hold on
                    for j = J
                        obj.trace_table.line(j) = plot(obj.trace_table.t{j}, ...
                            obj.trace_table.trace{j}, ...
                            'DisplayName',char(obj.trace_table.trace_name(j)));
                    end
                    l = legend(ax(i));
                    title(char(obj.trace_table.group(j)));
                    ax(i).Position = [0.05,0.15,0.95,0.70];
                end
                tmp = uicontainer('Parent',panel2);
                ax_ep = axes('Parent',tmp);
                ax_ep.Position = [0.05,0.15,0.95,0.70];
                title('Episodes');
            
                panel2.Spacing = 0;
                panel2.Padding = 20;
            else
                for i = 1:height(obj.trace_table)
                    ax(i) = axes('Parent',panel2);
                    obj.trace_table.line(i) = plot(obj.trace_table.t{i},obj.trace_table.trace{i});
                    title(obj.trace_table.trace_name{i});
                end
                set(ax,'ActivePositionProperty','position')

                ax_ep = axes('Parent',panel2);
                ax_ep.ActivePositionProperty = 'position';
                title('Episodes');

                panel2.Spacing = 30;
                panel2.Padding = 20;
            end
            
            obj.ax_ep = ax_ep;
            linkaxes([ax,ax_ep],'x');
            
            t0 = min(cellfun(@min,obj.trace_table.t));
            t1 = max(cellfun(@max,obj.trace_table.t));
            xlim([t0,t1]);
            
            if isempty(episode_table_display_only)
                obj.episode_table_display_only = episode_table_display_only;
            else
                episode_table_display_only = episode_table_display_only(:,{'state','state_start','state_end','state_duration'});
                obj.episode_table_display_only = episode_table_display_only;
            end
            obj.episode_table = prev_episode_table;
            
            obj.current_state = 'Empty';
            obj.plot_episodes();
        end
        
        function set.current_state(self,val)
            I = strcmp(val,self.states);

            for i = 1:length(self.state_btns)
                self.state_btns(i).Value = I(i);
            end
            
            self.current_state = val;
        end
    end
    
    methods (Access = private)
        function on_state_btn_click(self,s,e)
            self.current_state = s.String;
        end
        
        function brush_pre_callback(self,s,e)
            self.brush_down = e.Axes.CurrentPoint(1,1);
        end
        
        function on_close(self,s,e)
            % Save the changes done to the traces to the trace table.
            % Removed samples are saved as NaN. 
            if ismember('line',self.trace_table.Properties.VariableNames)
                for i = 1:height(self.trace_table)
                    I = ~ismember(self.trace_table.t{i}, ...
                        self.trace_table.line(i).XData);
                    trace = self.trace_table.trace{i};
                    trace(I) = nan;
                    self.trace_table.trace{i} = trace;
                end
            end
            delete(self.figure);
        end

        function brush_post_callback(self,s,e)
            if isequal(self.current_state,'Empty')
                return;
            end
            
            brush_down = self.brush_down;
            brush_up = e.Axes.CurrentPoint(1,1);
            
            t1 = min(brush_down,brush_up);
            t2 = max(brush_down,brush_up);
            
            t1 = round(t1,1);
            t2 = round(t2,1);
            
            if isequal(self.current_state,'Remove')
                new_ep = {};
                for i = 1:height(self.episode_table)
                    st = self.episode_table.state_start(i);
                    en = self.episode_table.state_end(i);
                    if t1 > st && t1 < en && t2 > en
                        self.episode_table.state_end(i) = t1;
                    elseif t2 > st && t2 < en && t1 < st
                        self.episode_table.state_start(i) = t2;
                    elseif t1 < st && t2 > en
                        % Will be removed further down.
                        self.episode_table.state_start(i) = 0;
                        self.episode_table.state_end(i) = 0;
                        self.episode_table.state_duration(i) = 0;
                    elseif t1 > st && t2 < en
                        tbl = table;
                        tbl.state = self.episode_table.state(i);
                        tbl.state_start = t2;
                        tbl.state_end = self.episode_table.state_end(i);
                        tbl.state_duration = tbl.state_end - tbl.state_start;
                        new_ep{end+1} = tbl;
                        
                        self.episode_table.state_end(i) = t1;
                    end
                end
                self.episode_table = cat(1,self.episode_table,new_ep{:});
            else
                % Merge overlapping episodes of the same kind.
                remove_ep = false(height(self.episode_table),1);
                for i = 1:height(self.episode_table)
                    if self.episode_table.state(i) ~= self.current_state
                        continue;
                    end
                    
                    st = self.episode_table.state_start(i);
                    en = self.episode_table.state_end(i);
                    if (t1 > st && t1 < en) || (t2 > st && t2 < en) ...
                            || (t1 > st && t2 < en) || (st > t1 && en < t2)
                        t1 = min(st,t1);
                        t2 = max(en,t2);
                        remove_ep(i) = true;
                    end
                end
                self.episode_table(remove_ep,:) = [];
                
                % Remove overlapping episodes.
                new_ep = {};
                for i = 1:height(self.episode_table)
                    st = self.episode_table.state_start(i);
                    en = self.episode_table.state_end(i);
                    if t1 > st && t1 < en && t2 > en
                        self.episode_table.state_end(i) = t1;
                    elseif t2 > st && t2 < en && t1 < st
                        self.episode_table.state_start(i) = t2;
                    elseif t1 < st && t2 > en
                        % Will be removed further down.
                        self.episode_table.state_start(i) = 0;
                        self.episode_table.state_end(i) = 0;
                        self.episode_table.state_duration(i) = 0;
                    elseif t1 > st && t2 < en
                        tbl = table;
                        tbl.state = self.episode_table.state(i);
                        tbl.state_start = t2;
                        tbl.state_end = self.episode_table.state_end(i);
                        tbl.state_duration = tbl.state_end - tbl.state_start;
                        new_ep{end+1} = tbl;
                        
                        self.episode_table.state_end(i) = t1;
                    end
                end
                self.episode_table = cat(1,self.episode_table,new_ep{:});
                
                tbl = table;
                tbl.state = categorical({self.current_state});
                tbl.state_start = t1;
                tbl.state_end = t2;
                tbl.state_duration = t2 - t1;
                
                tbl = cat(1,self.episode_table,tbl);
                self.episode_table = tbl;
            end
            
            % Remove episodes with zero or negative duration.
            if ~isempty(self.episode_table)
                self.episode_table.state_duration = self.episode_table.state_end - self.episode_table.state_start;
                self.episode_table = sortrows(self.episode_table,'state_start');
                self.episode_table(self.episode_table.state_duration <= 0,:) = [];
            end
            
            self.plot_episodes();
        end
        
        function plot_episodes(self)
            cla(self.ax_ep);
            self.txtbox.Data = [];
            
            tbl = cat(1,self.episode_table,self.episode_table_display_only);
            if ~isempty(tbl)
                axes(self.ax_ep);
                yucca.plot.plot_episodes(tbl.state, ...
                    tbl.state_start, tbl.state_end);
            end
            if ~isempty(self.episode_table)
                tmp = self.episode_table;
                tmp.state = cellstr(tmp.state);
                tmp = table2cell(tmp);
                self.txtbox.Data = tmp;
            end
        end
    end
end

