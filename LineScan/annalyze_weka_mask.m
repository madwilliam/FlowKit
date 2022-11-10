weka_root = '/scratch/line_scan_ben/matlab_filtered_unprocessed_mask/'; %ML output
mat_root = '/scratch/line_scan_ben/Tifs and Mats/'; %original mat file locations
weka_files = FileHandler.get_tif_files(weka_root);
mat_files = FileHandler.get_mat_files(weka_root);
nfiles = numel(weka_files);
for filei = 1:nfiles
    weka_file = weka_files(filei);
    process_weka(weka_file,weka_root)
end
