function run_script(script_name)
% This is a helper function to run Matlab code from the terminal. First the
% code to this project is added to the path then code is run using eval. If
% the code crashes Matlab is exited with an error as well. This function is
% mainly used by DVC from the dvc.yaml file.
addpath(genpath('Code'));
try
    eval(script_name);
catch e
    disp(e.getReport('extended'));
    % Exit Matlab with an error.
    exit(1);
end
% Exit Matlab successfully.
exit(0);

end

