function plot_residuals(model,output_folder)
if nargin < 2
    output_folder = '';
end
%% residuals
f = figure;
model.plotResiduals('probability');
% Save
if ~isempty(output_folder)
    file_name = fullfile(output_folder,'residuals.png');
    begonia.path.make_dirs(file_name);
    export_fig(f,file_name);
    
    file_name = fullfile(output_folder,'model.txt');
    str = evalc('model');
    fid = fopen(file_name,'wt');
    fprintf(fid,'%s',str);
    fclose(fid);
end
end

