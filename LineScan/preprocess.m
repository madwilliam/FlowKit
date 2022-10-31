tif_root = "/net/dk-server/bholloway/Zhongkai/FoG";
out = "/net/dk-server/bholloway/Zhongkai/matlab_filtered"; 
tif_files = FileHandler.get_tif_files(tif_root);

parfor i = 1:numel(tif_files)
    file_name = FileHandler.strip_extensions(tif_files(i).name);
    tif_path = FileHandler.get_file_path(tif_files,file_name);
    tif = FileHandler.load_image_data(tif_path);
    equalize = histeq(tif);
    blurr = imgaussfilt(equalize,[5,1000],'Padding','circular');
    result = equalize-blurr;
    imwrite(result,fullfile(out,[file_name '.tif']),'tiff');
end
%%

all_tiff_path = "/net/dk-server/bholloway/Zhongkai/Tifs and Mats";
all_tif_files = FileHandler.get_tif_files(all_tiff_path);
all_names = {all_tif_files.name};
all_name_processed = {tif_files.name};
unprocessed = setdiff(all_names,all_name_processed);
file_name = FileHandler.strip_extensions(unprocessed(1));
tif_path = FileHandler.get_file_path(all_tif_files,file_name);
tif = FileHandler.load_image_data(tif_path);
tif_chunk = tif(:,1:5000);
imagesc(tif_chunk)
histogram(reshape(tif_chunk,[],1))
histogram(reshape(equalize,[],1))
%%
equalize = histeq(tif_chunk);
blurr = imgaussfilt(equalize,[5,1000],'Padding','circular');
result = equalize-blurr;
imagesc(equalize)
imagesc(blurr)
imagesc(result)
%%
upout = "/net/dk-server/bholloway/Zhongkai/matlab_filtered_unprocessed"; 
for i = 1:numel(unprocessed)
    file_name = unprocessed{i}(1:end-4);
    tif_path = FileHandler.get_file_path(all_tif_files,file_name);
    tif = FileHandler.load_image_data(tif_path);
    equalize = histeq(tif);
    blurr = imgaussfilt(equalize,[5,1000],'Padding','circular');
    result = equalize-blurr;
    imwrite(result,fullfile(upout,[file_name '.tif']),'tiff');
end
