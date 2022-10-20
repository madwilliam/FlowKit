weka_root = '/net/dk-server/bholloway/Zhongkai/mlout/';
mat_root = '/net/dk-server/bholloway/Zhongkai/FoG/';
tif_files = FileHandler.get_tif_files(mat_root);
mat_files = FileHandler.get_mat_files(mat_root);
weka_mat_files = FileHandler.get_mat_files(weka_root);
weka_tifs = FileHandler.get_tif_files(weka_root);

nweka = nume(weka_mat_files);
for wekai = 2:nweka
    weka_mat = weka_mat_files(wekai);
    file_name = FileHandler.strip_extensions(weka_mat.name);
    tif_path = FileHandler.get_file(tif_files,file_name);
    weka_mat_path = FileHandler.get_file(weka_mat_files,file_name);
    Plotter.show_flow_speed_around_stimulation_weka(mat_path,tif_path,weka_mat_path)
