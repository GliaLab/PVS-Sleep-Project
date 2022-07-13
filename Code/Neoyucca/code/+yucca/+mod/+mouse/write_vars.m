function write_vars( trial )
%WRITE_VARS Summary of this function goes here
%   Detailed explanation goes here
    mdata = yucca.mod.mouse.read(trial);
    
    trial.save_var('Mouse', mdata);
    trial.save_var('MouseCID', mdata.CageID);
    trial.save_var('MouseAID', mdata.MouseID);
    trial.save_var('MouseEM', mdata.EarMark);
    trial.save_var('MouseNote', mdata.Note);
    
end

