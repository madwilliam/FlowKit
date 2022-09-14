function start_parallel()
p = gcp('nocreate'); 
if isempty(p)
    c = parcluster('local'); 
    nw = c.NumWorkers; 
    parpool(nw)
end
end
