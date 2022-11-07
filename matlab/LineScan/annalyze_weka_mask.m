weka_root = '/net/dk-server/bholloway/Zhongkai/matlab_filtered_unprocessed_mask/'; %ML output
mat_root = '/net/dk-server/bholloway/Zhongkai/Tifs and Mats/'; %original mat file locations
weka_files = FileHandler.get_tif_files(weka_root);
mat_files = FileHandler.get_mat_files(weka_root);
nfiles = numel(weka_files);
parfor filei = 1:nfiles
    weka_file = weka_files(filei);
    process_weka(weka_file,weka_root)
end
