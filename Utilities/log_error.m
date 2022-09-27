function log_error(file_name,ME,output_dir)
    log_file = fullfile(output_dir,'error_log.txt');
    if ~isfile(log_file)
        fid = fopen(log_file, 'w');
    else
        fid = fopen(log_file, 'a+');
    end
    fprintf(fid, '======================================\n%s\n%s\n%s\n', file_name,ME.identifier,ME.message);
    fclose(fid)
end