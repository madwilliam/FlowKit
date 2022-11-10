output = '/net/dk-server/bholloway/Zhongkai/new_batch_mask/'; 
input = '/net/dk-server/bholloway/Zhongkai/new_batch/';
tif_files = FileHandler.get_tif_files(input);
nfiles = numel(tif_files);
for filei = 1:nfiles
    tif_file = tif_files(filei);
    file_name = FileHandler.strip_extensions(tif_file.name);
    tif_path = FileHandler.get_file_path(tif_files,file_name);
    tif = FileHandler.load_image_data(tif_path);
    mask = create_mask_low_snr(tif);
    imwrite(mask,fullfile(output,tif_file.name),'tiff');
end
