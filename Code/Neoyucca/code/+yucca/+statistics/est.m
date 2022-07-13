function [estimates,p_values,model] = est(varargin)
p = inputParser;
p.addRequired('response',...
    @(x) validateattributes(x,{'numeric'},{}));
p.addRequired('predictor_1',...
    @(x) validateattributes(x,{'categorical'},{}));
p.addRequired('predictor_2',...
    @(x) validateattributes(x,{'categorical'},{}));
p.addParameter('log_transform',false);
% Hack to allow 'predictor_2' be an optional positional input and still
% have parameter pairs work.
if nargin == 2
    varargin = [varargin(1:2),{categorical}];
end
if nargin > 2 && ischar(varargin{3})
    varargin = [varargin(1:2),{categorical},varargin(3:end)];
end
p.parse(varargin{:});
begonia.util.dump_inputParser_vars_to_caller_workspace(p);

if isempty(predictor_2)
    tbl = table(response,predictor_1);
    [estimates,p_values,model] = begonia.statistics.estimate( ...
        tbl,'response','predictor_1','', ...
        'log_transform',log_transform);
else
    tbl = table(response,predictor_1,predictor_2);
    [estimates,p_values,model] = begonia.statistics.estimate( ...
        tbl,'response','predictor_1','predictor_2', ...
        'log_transform',log_transform);
end

end

