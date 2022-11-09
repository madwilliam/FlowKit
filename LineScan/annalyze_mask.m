weka_root = '/net/dk-server/bholloway/Zhongkai/up050522_mask/'; %ML output
mat_root = '/net/dk-server/bholloway/Zhongkai/Tifs and Mats/'; %original mat file locations
weka_files = FileHandler.get_tif_files(weka_root);
mat_files = FileHandler.get_mat_files(weka_root);
tif_files = FileHandler.get_tif_files(mat_root);
nfiles = numel(weka_files);
for filei = 1:nfiles
    weka_file = weka_files(filei);
    file_name = FileHandler.strip_extensions(weka_file.name);
    tif_path = FileHandler.get_file_path(tif_files,file_name);
    tif = FileHandler.load_image_data(tif_path);
    process_mask(weka_file,weka_root)
end
