function batch_examine_result(out_dir,figure_dir)
if ~ exist(figure_dir)
    mkdir(figure_dir)
end
tif_files = FileHandler.get_tif_files(out_dir);
mat_files = FileHandler.get_mat_files(out_dir);
nfiles = numel(mat_files);
parfor filei = 1:nfiles
    try
        file_name = FileHandler.strip_extensions(mat_files(filei).name);
        mat_path = FileHandler.get_file(mat_files,file_name);
        tif_path = FileHandler.get_file(tif_files,file_name);
        save_path = fullfile(figure_dir,append(file_name));
        Plotter.save_flow_speed_around_stimulation(mat_path,tif_path,save_path)
    catch
        disp(file_name)
    end
end
end