function [SI,RoiGroups] = parse_scan_image_meta(meta_name)
    fid = fopen(meta_name); 
    raw = fread(fid,inf); 
    str = char(raw'); 
    fclose(fid); 
    indices = strfind(str,'SI');
    start_of_last_SI_line = indices(end);
    indices = strfind(str(start_of_last_SI_line:end),'{');
    start_of_json = start_of_last_SI_line + indices(1)-1;
    RoiGroups = jsondecode(str(start_of_json:end)).RoiGroups;
    declear_SI = str(1:start_of_json-1);
    declear_SI = splitlines(declear_SI);
    for i =1:numel(declear_SI)
        eval([declear_SI{i} ';'])
    end
end