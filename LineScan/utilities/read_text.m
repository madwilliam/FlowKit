function str = read_text(meta_name)
    fid = fopen(meta_name); 
    raw = fread(fid,inf); 
    str = char(raw'); 
    fclose(fid); 
end