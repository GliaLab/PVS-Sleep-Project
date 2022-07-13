function expanded = expandStringDlocVars(str, dloc)
%EXPANDSTRINGDLOCVARS Expands names in string with dloc variables
%   Given a string containing {$varname} patterns, will replace pattern
%   with the value of the mentioned variable.

    expr = '{(\$.*?)}';
    matches = regexp(str, expr, 'match');
    expanded = str;
    
    for match = matches
        match_str = char(match);
        varname = match_str(3:end-1);
        value = ['{ERR:NOT_FOUND:' varname '}'];
        if dloc.has_var(varname)
            value = dloc.load_var(varname);
            if ~isa(value, 'char') && ~isa(value, 'string')
               value = ['{ERR:TYPE_NOT_CHAR:' class(value) '}'];
            end
        end
        expanded = strrep(expanded, match_str, value);
    end
end