function html = wrap_in_template(content, template_file)

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
    html = replace(template, "{CONTENT}", content); 
end

