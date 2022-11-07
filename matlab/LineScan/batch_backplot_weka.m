weka_root = '/net/dk-server/bholloway/Zhongkai/matlab_filtered_unprocessed_mask/';
out_dir = '/net/dk-server/bholloway/Zhongkai/Tifs and Mats/';
figure_dir = '/net/dk-server/bholloway/Zhongkai/lowsnr_weka_backplot/';
if ~ exist(figure_dir)
    mkdir(figure_dir)
end
tif_files = FileHandler.get_tif_files(out_dir);
mat_files = FileHandler.get_mat_files(out_dir);
weka_mat_files = FileHandler.get_mat_files(weka_root);
nfiles = numel(mat_files);
for filei = 1:nfiles
    try
        file_name = FileHandler.strip_extensions(mat_files(filei).name);
        mat_path = FileHandler.get_file_path(mat_files,file_name);
        weka_mat_path = FileHandler.get_file_path(weka_mat_files,file_name);
        tif_path = FileHandler.get_file_path(tif_files,file_name);
        save_path = fullfile(figure_dir,append(file_name));
        Plotter.save_flow_speed_around_stimulation_weka(mat_path,tif_path,weka_mat_path,save_path)
    catch
        disp(file_name)
    end
end