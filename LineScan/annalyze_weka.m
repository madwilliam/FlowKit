weka_root = '/net/dk-server/bholloway/Zhongkai/mlout/';
mat_root = '/net/dk-server/bholloway/Zhongkai/FoG/';
weka_files = FileHandler.get_tif_files(weka_root);
mat_files = FileHandler.get_mat_files(weka_root);
nfiles = numel(weka_files);
parfor filei = 1:nfiles
    weka_file = weka_files(filei);
    process_weka(weka_file,weka_root)
end
