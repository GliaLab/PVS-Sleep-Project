%                                  (`-..________....---''  ____..._.-`
%                                   \\`._______.._,.---'''     ,'
%                                   ; )`.      __..-'`-.      /
%                                  / /     _.-' _,.;;._ `-._,'
%                                 / /   ,-' _.-'  //   ``--._``._
%                               ,','_.-' ,-' _.- (( =-    -. `-._`-._____
%                             ,;.''__..-'   _..--.\\.--'````--.._``-.`-._`.
%              _          |\,' .-''        ```-'`---'`-...__,._  ``-.`-.`-.`.
%   _     _.-,'(__)\__)\-'' `     ___  .          `     \      `--._
% ,',)---' /|)          `     `      ``-.   `     /     /     `     `-.
% \_____--.  '`  `               __..-.  \     . (   < _...-----..._   `.
%  \_,--..__. \\ .-`.\----'';``,..-.__ \  \      ,`_. `.,-'`--'`---''`.  )
%            `.\`.\  `_.-..' ,'   _,-..'  /..,-''(, ,' ; ( _______`___..'__
%                    ((,(,__(    ((,(,__,'  ``'-- `'`.(\  `.,..______   SSt
%                                                       ``--------..._``--.__

% HERE BE DRAGONS

% When given a list of DataLocation objects, a list of actions and a list
% of varilable names, this class will provide a GUI to view and edit those
% DataLocation objects. 

classdef DataViewer < handle
    %DATAVIEWER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Figure
        RawData
        TableData
        Actions
        
        MetaVarsListed
        MetaVarsEditable
        
        SelectedData
        SelectedMetaVars
        
        UITable
        UIVarInput
        
        ShowingSkipped
    end
    
    methods
        
         function obj = DataViewer(data, actions, metavars, position)
             
            if ~isa(data, 'begonia.data_management.DataLocation')
                error('Data needs to be derived from DataCollection');
            end
             
            if ~isa(actions, 'yucca.gui.dview.DataViewerAction') && ~isempty(actions)
                error('Actions parameter needs to be a list of yucca.gui.dview.DataViewerAction');
            end
            
            obj.ShowingSkipped = true;
            
            obj.UITable = [];
            obj.RawData = data;
            obj.SelectedData = [];
            obj.SelectedMetaVars = [];
            obj.Actions = [obj.getDefaultActions() actions];
            %obj.MetaVarsListed = metavars;
            [obj.MetaVarsListed, obj.MetaVarsEditable] = obj.parseMetavarList(metavars);
            
            obj.setupGUI();
            obj.loadData();
            obj.loadUITable();
            
            if nargin > 3
                obj.Figure.Position = position;
            end
         end
    
         
    end
    
    methods(Access= private)
        
        function [vars_clean, editable] = parseMetavarList(~, vars)
            vars_clean = {};
            editable = true(1,1);
            for i = 1:length(vars)
                editable(i) = startsWith(char(vars{i}), '!'); % detect exclamation mark
                vars_clean{i} = replace(vars{i}, '!', '');  % remove exlamation mark
            end

        end
        
        function setupGUI(obj)
            obj.Figure = figure('Visible','on','Position',[100,100,1000,700]);
            obj.Figure.Name = ['Data Viewer for ' num2str(length(obj.RawData)) ' x ''' class(obj.RawData) ''' objects'];
             
            varstr = join(obj.MetaVarsListed, ',');
            
            % keyvboard events:
            obj.Figure.KeyPressFcn = @obj.handleKeyDown;
            
             % reload button:
            reload_button = uicontrol(obj.Figure, 'Style','pushbutton', 'String','Reload','Position',[10,670,100,20]);
            toggle_skip_button = uicontrol(obj.Figure, 'Style','pushbutton', 'String','Toggle skipped','Position',[10,645,100,20]);

            obj.UIVarInput = uicontrol(obj.Figure, 'Style','edit', 'String',varstr,'Position',[120,670,500,20]);
            loadall_button = uicontrol(obj.Figure, 'Style','pushbutton', 'String','Load all','Position',[630,670,100,20]);

            reload_button.Callback = @obj.handleReloadClick;
            toggle_skip_button.Callback = @obj.handleToggleSkippedClick
            obj.UIVarInput.Callback = @obj.handleVarlistInput;
            loadall_button.Callback = @obj.handleLoadallClick;
            
            % load action buttons:
            for i = 1:length(obj.Actions)
                action = obj.Actions(i);
                if action.IsSpacer
                    continue;
                end
                
                ctrl_type = 'pushbutton';
                if action.IsLabel
                   ctrl_type = 'text';
                end
                
                pos = [880, 670  - (20 * (i-1)) - (5*(i-1)) , 100, 20];
                action.Button = uicontrol(obj.Figure, 'Style',ctrl_type, 'String',action.Title,'Position', pos, 'HorizontalAlignment', 'Left');
                action.Button.HorizontalAlignment = 'Left';
                action.Button.Callback = @(src, ev) obj.handleActionClicked(action);
                action.Button.Enable = 'off';
                
                
            end
         end
         
        
        function loadData(obj)

            % build table:
            metavars = obj.MetaVarsListed;
            cells = yucca.gui.dview.metavars_as_table(obj.RawData, metavars);
            
            % remove skipped rows if asked:
            if ~obj.ShowingSkipped && any(contains(cells.Properties.VariableNames, 'Skip'))
                cells = cells(~strcmp(cells{:,'Skip'}, 'x'),:)
            end

            
            % transform an construct cell array for uitable:
            obj.TableData = cell(size(cells, 1), size(cells, 2));
            h = size(cells, 1);
            w = size(cells, 2);
            
            for y = 1:w
                for x = 1:h
                    celldata = cells{x,y};
                    % try convert cell:
                    try
                        if isnumeric(celldata{:})
                            obj.TableData(x,y) = cellstr(num2str(celldata{:}));
                        else
                            obj.TableData(x,y) = cellstr(char(celldata{:}));
                        end                 
                    catch
                        obj.TableData(x,y) = cellstr(['(' class(celldata{:}) ')']);
                    end

                end
            end
            
 
 
        end
        
        function loadUITable(obj)
                
            % delete existing table if any, but keep column widths:
            if ~isempty(obj.UITable)
                %delete(obj.UITable);
                obj.UITable.Data = obj.TableData;
                obj.UITable.ColumnName = obj.MetaVarsListed;
                return;
            end
            
            % create table:
            figpos = getpixelposition(obj.Figure);
            obj.UITable = uitable(obj.Figure ,'Data',obj.TableData,'Position',[0 0 figpos(3)-(figpos(3)*0.14) figpos(4)-(figpos(4)*0.09)]);
            obj.UITable.ColumnName = obj.MetaVarsListed;
            obj.UITable.ColumnEditable = obj.MetaVarsEditable;
            
            
            % add callbacks:
            obj.UITable.CellSelectionCallback = @obj.handleTableClick;
            obj.UITable.KeyPressFcn = @obj.handleKeyDown;
            obj.UITable.CellEditCallback = @obj.handleCellEdited;
            
            % set scaling:
            set( findall( obj.Figure, '-property', 'Units' ), 'Units', 'Normalized' )
            %obj.UITable.ColumnWidth = column_widths;
        end

        function updateActionAvailability(obj)
            
            for i = 1:length(obj.Actions)
                action = obj.Actions(i);
                action.Button.Enable = 'on';
            end
            
        end
        
        %% Event handlers:
        function handleKeyDown(obj, ~, ev)
            if strcmp(ev.Key, 'space')
                obj.sendToOpen();
            end
        end
        
         
        function handleReloadClick(obj, ~, ~)
            varstr = obj.UIVarInput.String;
            vars = split(varstr, ',');
            vars = strtrim(vars);
            obj.MetaVarsListed = vars;
            
            % rerender table:
            obj.loadData();
            obj.loadUITable();
            obj.updateActionAvailability();
        end
        
        
        function handleToggleSkippedClick(obj, ~, ~)
            obj.ShowingSkipped = ~obj.ShowingSkipped;
            
            % reload table:
            obj.loadData();
            obj.loadUITable();
        end
        
        
        function handleTableClick(obj, ~, ev)
            indicies = unique(ev.Indices(:,1));
            
            % get selected metavars:
            varindicies = unique(ev.Indices(:,2));
            metavars = obj.MetaVarsListed(varindicies);
            
            % get the selected data:
            obj.SelectedData = [];
            for i = 1:length(indicies)
                data = obj.RawData(indicies(i));
                obj.SelectedData = [obj.SelectedData; data];
            end

            % select metavars:
            obj.SelectedMetaVars = obj.MetaVarsListed(varindicies);
            
            
            % update available buttons:
            obj.updateActionAvailability();
        end
        
        % Callback to handle the event that a cell is edited. Basically
        % writes the new data with save_var.
        function handleCellEdited(obj, src, ev)
            obj.SelectedData.save_var(char(obj.SelectedMetaVars), ev.NewData);
        end
        

        function handleVarlistInput(obj, src, ev)
            
        end
        
        
        function handleLoadallClick(obj, src, ev)
            
            str = {'Name', char(obj.RawData.MetaVars)};
            str = str(~cellfun('isempty',str));  
            str = strjoin(str, ',');
            obj.UIVarInput.String = str;
            
            % simualte event:
            obj.handleReloadClick([], []);
        end
        
        
        function handleActionClicked(obj, action)
            obj.Figure.Name = '**WORKING**';
            drawnow;
            disp(action.Title);
            %action.Button.Enable = 'off';
            action.Callback(obj.SelectedData);
            %action.Button.Enable = 'on';
            obj.Figure.Name = '';
            obj.handleReloadClick();
        end
        
        function actions = getDefaultActions(obj)              
            a_to_ws = yucca.gui.dview.DataViewerAction('-> workspace');
            a_to_ws.Callback = @(data) obj.sendToWorkspace();
            
            a_to_open = yucca.gui.dview.DataViewerAction('Open (space)');
            a_to_open.Callback = @(data) obj.sendToOpen();
            
            a_to_table = yucca.gui.dview.DataViewerAction('Export to table');
            a_to_table.Callback = @(data) obj.sendToTable();
            
            a_to_mat = yucca.gui.dview.DataViewerAction('Export all vars');
            a_to_mat.Callback = @(data) obj.sendToMat();

            
            a_setnum = yucca.gui.dview.DataViewerAction('Set NUM variable');
            a_setnum.Callback = @(data) obj.manuelSetVarNUM(data);
            
            a_clear_var = yucca.gui.dview.DataViewerAction('Clear selected var');
            a_clear_var.Callback = @(data) obj.clearSelectedVar(data);
            
            a_clearall = yucca.gui.dview.DataViewerAction('Clear all vars on selected');
            a_clearall.Callback = @(data) obj.clearVarsOnSelected(data);

            a_spacer = yucca.gui.dview.DataViewerAction('Space');
            a_spacer.IsSpacer = 1;
            
            a_project_label = yucca.gui.dview.DataViewerAction('Project tools:');
            a_project_label.IsLabel = 1;
            
            actions = [a_to_ws a_to_open a_to_table a_to_mat a_spacer a_setnum a_clear_var a_clearall a_spacer a_project_label];
        end
        
        function clearVarsOnSelected(obj, data)
            varnames = unique(obj.SelectedData.MetaVars);
            obj.clearVariables_(varnames);
        end
        
        function clearSelectedVar(obj, data)
            varnames = obj.SelectedMetaVars;
            obj.clearVariables_(varnames);
        end
        
        function clearVariables_(obj, varnames)
            question = ['This cannot be undone: Are you sure you wish to delete FOR SELECTED DATA: ' varnames' ];
            question = char(join(question));
            choice = questdlg(question, 'Delete these variables', ' Cancel');
            
            if strcmp(choice, 'Yes')
                for i = 1:length(varnames)
                    varname = char(varnames(i));
                    for j = 1:length(obj.SelectedData)
                        obj.SelectedData(j).clear_var(varname);
                    end
                end
            end
        end

        
        function manuelSetVarNUM(obj, data)
            prompt = {'Varname','Number'};
            dlg_title = 'Input numeric variable manually';
            num_lines = 1;
            answer = inputdlg(prompt,dlg_title,num_lines);
            if length(answer) == 2
                for i = 1:length(data)
                    data(i).save_var(answer{1}, str2double(answer{2}));
                end
            end
        end
        
        
        function editComment(obj, data)
            tag = data(1).load_var('Tags');
            comment = data(1).load_var('Comment');
            
            prompt = {'Tags:','Comment:'};
            dlg_title = 'Input';
            num_lines = 4;
            
            if isa(tag, 'cell') && isa(comment, 'cell')
                defaultans = {tag{1}, comment{1}};
            else
                defaultans = {'', ''};
            end
            answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
            
            if length(answer) == 2
                for i = 1:length(data)
                    data(i).save_var('Tags', answer(1));
                    data(i).save_var('Comment', answer(2));
                end
            end
        end
        
        
        % Method to send current object to the MatLab workspace for poking
        % at it with whatever your heart desires:
        function sendToWorkspace(obj)
            tbl = cell2table(obj.TableData);
            colnames = arrayfun( @(x) char(x) ,obj.MetaVarsListed', 'UniformOutput', 0);
            tbl.Properties.VariableNames = colnames;
            
            assignin('base', 'data_', [obj.RawData]);
            assignin('base', 'sdata_', [obj.SelectedData]);
            assignin('base', 'metavar_', [obj.SelectedMetaVars]);
            assignin('base', 'table_', [tbl]);
            disp('Set variables: data_ , (all) sdata_ (selected), metavar_, table_');
        end
        
        
        % Method to export the current object(s) to a Excel spreadshit, for
        % those who swing that way:
        function sendToTable(obj)
            [fname,fpath] = uiputfile('Table.xlsx','Save file name (extention sets type)');
            
            tbl = cell2table(obj.TableData);
            colnames = arrayfun( @(x) char(x) ,obj.MetaVarsListed', 'UniformOutput', 0);
            tbl.Properties.VariableNames = colnames;
            
            fullpath = fullfile(fpath, fname);
            writetable(tbl, fullpath);
        end
        
        
        % Method to open the path provided externally or internally:
        function sendToOpen(obj)
            
            % we need to determine if this is a metavar or a property:
            data = obj.SelectedData(1);
            varname = char(obj.SelectedMetaVars(1));
            var = data.load_var(varname, []);
            
            % if the variable was not loaded, we try loading it s a
            % property:
            try
                if ~isstruct(var) && ~any(var)
                    var = data.(varname);
                end
            catch
                
            end

            % try dumping in different ways:
            try
                yucca.gui.dview.open_somehow(char(var));
                assignin('base', 'opened_', var);
                disp('Added to : opened_ (might not show in variable workspace before loading');
            catch
                yucca.gui.dview.open_somehow(var);
                assignin('base', 'opened_', var);
                disp('Added to : opened_ (might not show in variable workspace before loading');
            end
        end
        
        
        % Method to save current object to a .mat file:
        function sendToMat(obj)
             
            [fname,fpath] = uiputfile('All metadata.mat', 'Save file name (extention sets type)');
            fullpath = fullfile(fpath, fname);
            
            vars = [{'Name', 'Path'} yucca.gui.dview.all_metavars(obj.SelectedData)];

            data = struct();
            data.exported = datetime();
            data.file = fullpath;
            data.items = [];
            
            for i = 1:length(obj.SelectedData)
                item = obj.SelectedData(i);
                item_data = item.as_struct(vars);
                
                data.items = [data.items ; item_data];
            end
            
            save(fullpath, 'data');
            disp(['Export done - wrote: ' fullpath]);
        end
        
    end
end






















