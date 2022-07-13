classdef EpisodeMarker < handle
    
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
        scan
    end
    
    methods
        function obj = EpisodeMarker(scan)
            obj.scan = scan;
            if ~scan.has_var('recrig')
                begonia.logging.log(1,'Missing linked labview trial');
                return;
            end
            if ~scan.find_dnode('recrig').has_var('ephys')
                begonia.logging.log(1,'Missing ECoG');
                return;
            end

            states = {'Empty','Remove','Vessel Baseline'};
            
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
            
            ax(1) = axes('Parent',panel2);
            ephys = scan.find_dnode('recrig').load_var('ephys');

            t = seconds(ephys.Time);
            ecog = ephys.ecog;
            emg = ephys.emg;
            ecog_fs = ephys.Properties.SampleRate;
            ordr = 10;

            begonia.logging.log(1,'Filtering ECoG');
            aa = designfilt('bandpassiir','FilterOrder',ordr, ...
                'HalfPowerFrequency1',0.5,'HalfPowerFrequency2',30, ...
                'SampleRate',ecog_fs);
            ecog_filt = filter(aa, ecog);
            plot(t,ecog_filt)
            title('ECoG 0.5 - 30 Hz');
            
            begonia.logging.log(1,'Loading vessel data');
            diameter_red = scan.load_var('diameter_red');
            vessels_red = scan.load_var('vessels_red');
            begonia.logging.log(1,'Finished');
            
            ax_cnt = 1;
            for i = 1:height(diameter_red)
                ax_cnt = ax_cnt + 1;
                ax(ax_cnt) = axes('Parent',panel2);
                diameter_t = (0:length(diameter_red.diameter{i})-1) / diameter_red.vessel_fs(i);
                plot(diameter_t,diameter_red.diameter{i});
                title('Diameter (pixels)');

                ax_cnt = ax_cnt + 1;
                ax(ax_cnt) = axes('Parent',panel2);
                mat = vessels_red.vessel_red{i};
                imagesc(mat,'XData',diameter_t);
            end
            
            set(ax,'ActivePositionProperty','position')

            ax_ep = axes('Parent',panel2);
            ax_ep.ActivePositionProperty = 'position';
            title('Episodes');

            panel2.Spacing = 30;
            panel2.Padding = 20;
            
            obj.ax_ep = ax_ep;
            linkaxes([ax,ax_ep],'x');
            
            xlim([t(1),t(end)]);
            
            if scan.has_var('recrig')
                episode_table_display_only = scan.find_dnode('recrig').load_var('sleep_episodes',table);
            end
            
            if isempty(episode_table_display_only)
                obj.episode_table_display_only = table;
            else
                obj.episode_table_display_only = episode_table_display_only;
            end
            obj.episode_table = scan.load_var('baseline_episodes',table);
            
            obj.current_state = 'Empty';
            obj.plot_episodes();
        end
        
        function on_close(self,s,e)
            if isempty(self.episode_table)
                begonia.logging.log(1,'No baseline episodes to save');
                self.scan.clear_var('baseline_episodes');
            else
                baseline_episodes = self.episode_table;
                begonia.logging.log(1,'Saving baseline episodes');
                self.scan.save_var(baseline_episodes);
            end
            delete(self.figure);
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

