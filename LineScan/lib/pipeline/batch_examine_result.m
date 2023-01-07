function batch_examine_result(tif_dir,mat_dir,out_dir)
if ~ exist(out_dir)
    mkdir(out_dir)
end
tif_files = FileHandler.get_tif_files(tif_dir);
mat_files = FileHandler.get_mat_files(tif_dir);
radon_mat_files = FileHandler.get_mat_files(mat_dir);
nfiles = numel(mat_files);
parfor filei = 1:nfiles
    try
        file_name = FileHandler.strip_extensions(mat_files(filei).name);
        mat_path = FileHandler.get_file_path(mat_files,file_name);
        radon_mat_path = FileHandler.get_file_path(radon_mat_files,file_name);
        tif_path = FileHandler.get_file_path(tif_files,file_name);
        save_path = fullfile(out_dir,append(file_name));
        RadonBackPlotter.save_flow_speed_around_stimulation(radon_mat_path,mat_path,tif_path,save_path)
    catch
        disp(file_name)
    end
end
end