out_dir='/net/dk-server/bholloway/Zhongkai/outpath';
tif_files = FileHandler.get_tif_files(out_dir);
mat_files = FileHandler.get_mat_files(out_dir);
file_name = 'PACK-050522-NoCut_05-19-22_00004_roi_1';
mat_path = FileHandler.get_file(mat_files,file_name);
tif_path = FileHandler.get_file(tif_files,file_name);
load(mat_path,'result','start_time','end_time');
Plotter.show_flow_speed_around_stimulation(mat_path,tif_path)