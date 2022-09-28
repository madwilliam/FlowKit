out_dir='Y:\Zhongkai\outpath';
tif_files = FileHandler.get_tif_files(out_dir);
mat_files = FileHandler.get_mat_files(out_dir);
mat_path = FileHandler.get_file(mat_files,file_name);
tif_path = FileHandler.get_file(tif_files,file_name);
Plotter.show_flow_speed_around_stimulation(mat_path,tif_path,1)