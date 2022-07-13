function html = table_to_html(tab, cell_funcs, template_file)
    
    if nargin < 3
        template = "{CONTENT}";   % enpty remplate by default
    else
        % load the template:
        if ~exist(template_file, 'file')
            base = fileparts(mfilename('fullpath'));
            base = fullfile(base, '../../html_templates/');
            repo_tempfile = fullfile(base, template_file);
            if exist(repo_tempfile, 'file')
                template_file = repo_tempfile;
            else
                error("Could not load template file " + template_file);
            end 
        end
        
        template = fileread(template_file);
    end
    
    if nargin < 2
        cell_funcs = containers.Map;
    end

    
    % render the table:
    headings = tab.Properties.VariableNames;
    
    html = "<table><thead><tr>";
    
    % table: headings:
    for h = headings
        html = html + "<th>" + h + "</th>";
    end
    html = html + "</tr></thead><tbody>";
    
    % table: body:
    for r = 1:height(tab)
        row = tab(r,:);
        
        html = html + newline + "<tr>";
        
        for h = headings
            if any(contains(cell_funcs.keys, h{:}))
                func = cell_funcs(h{:});
                val = func(row.(h{:}));
            else
                val = string(row.(h{:}));
            end
            
            
            html = html + "<td>" + val + "</td>";
        end
    
        
        html = html + "</tr>";
    end
    
    html = html + newline + "</tbody></table>";
    
    % wrap in template if requested to do so:
    html = replace(template, "{CONTENT}", html); 
    end


