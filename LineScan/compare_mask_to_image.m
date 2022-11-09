weka_root = '/net/dk-server/bholloway/Zhongkai/up050522_mask/'; %ML output
mat_root = '/net/dk-server/bholloway/Zhongkai/Tifs and Mats/'; %original mat file locations
weka_files = FileHandler.get_tif_files(weka_root);
mat_files = FileHandler.get_mat_files(weka_root);
tif_files = FileHandler.get_tif_files(mat_root);
nfiles = numel(weka_files);
filei = 1;
weka_file = weka_files(filei);
file_name = FileHandler.strip_extensions(weka_file.name);
tif_path = FileHandler.get_file_path(tif_files,file_name);
tif = FileHandler.load_image_data(tif_path);

weka_path = fullfile(weka_root,weka_file.name);
mask = FileHandler.load_image_data(weka_path);
mask = WekaAnalyzer.preprocess_mask(mask);

figure
subplot(121)
imagesc(tif(:,1:1000))
subplot(122)
imagesc(mask(:,1:1000))