out_dir='Z:\Zhongkai\BH_DiffDivGauss\temp\';
tif_files = FileHandler.get_tif_files(out_dir);
mat_files = FileHandler.get_mat_files(out_dir);

%% sigle file
file_name = "Z:\Zhongkai\BH_DiffDivGauss\temp\Pack-050522-NoCut_05-17-22_Vessel-2_CBF_00001_roi_1";
mat_path = FileHandler.get_file_path(mat_files,file_name);
tif_path = FileHandler.get_file_path(tif_files,file_name);
load(mat_path,'result','start_time','end_time');
Plotter.show_flow_speed_around_stimulation(mat_path,tif_path)

%% adjust_window_size
adjust_window_size(out_dir)


%% batch
out_dir='/net/dk-server/bholloway/Zhongkai/FoG';
figure_dir = '/net/dk-server/bholloway/Zhongkai/FoGout';
batch_examine_result(out_dir,figure_dir)
