function t = metavars_as_table( dlocs, vars )
%AS_TABLE Given a list of DataLocations, will return a table with columns
%'vars'
%   Detailed explanation goes here
    t = table();
    
    if isempty(vars)
       error('You must specify variable names as as a string list when combining multiple entries'); 
    end
    
    if isa(vars, 'char')
       error('Vars must be given as a list of strings, like: [string(...), string(...)]') 
    end
    
    for i = 1:length(dlocs)
        dloc = dlocs(i);
        row = dloc.saved_vars_as_table(vars);
        t = [t; row];
    end
    
end

