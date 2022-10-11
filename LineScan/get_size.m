function size_var = get_size(var)
    name = getVarName(var);
    size = whos(name);
    size_var = size.bytes;
end

function out = getVarName(var)
    out = inputname(1);
end