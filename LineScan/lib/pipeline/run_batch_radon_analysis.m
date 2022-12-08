function run_batch_radon_analysis(out_dir,radon_step_size,radon_function,step_factor)
    if ~exist('radon_function','var') == 1
        radon_function = @two_step_radon;
    end
    if ~exist('step_factor','var') == 1
        step_factor = 0.25;
    end
    tif_files = FileHandler.get_tif_files(out_dir);
    mat_files = FileHandler.get_mat_files(out_dir);
    nfiles = numel(mat_files);
    for i = 1:nfiles 
        try
            matfile = mat_files(i);
            file_name = FileHandler.strip_extensions(matfile.name);
            analyze_file_with_radon(file_name,tif_files,mat_files,radon_step_size,@radon_function,step_factor);
        catch ME
            log_error(file_name,ME,out_dir);
        end
    end
end