function generate_analysis_result(out_dir)
    tif_files = FileHandler.get_tif_files(out_dir);
    mat_files = FileHandler.get_mat_files(out_dir);
    nfiles = numel(mat_files);
    parfor i = 1:nfiles 
        try
            matfile = mat_files(i);
            file_name = FileHandler.strip_extensions(matfile.name);
            analyze_file(file_name,tif_files,mat_files);
        catch ME
            log_error(file_name,ME,out_dir);
        end
    end
end