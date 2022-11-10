% mat_root = '/net/dk-server/bholloway/Zhongkai/Tifs and Mats/'; %original mat file locations
mat_root = '/net/dk-server/bholloway/Zhongkai/new_batch/'; %original mat file locations
tif_files = FileHandler.get_tif_files(mat_root);
filename = FileHandler.strip_extensions(tif_files(1).name);
path = FileHandler.get_file_path(tif_files,filename);
tif = FileHandler.load_image_data(path);
chunk = tif(:,5000:6000);

mask = imbinarize(chunk,'adaptive');

figure
imagesc(mask)
imagesc(chunk)
imagesc(BW2)
imagesc(closeBW)
imagesc(dist)

se = strel('disk',8);
closeBW = imclose(mask,se);
dist = bwdist(~mask);
mask = dist>3;

BW2 = edge(chunk,'canny',0.3,8);



%%
%DoG
A = imgaussfilt(chunk,[1,3]);
B = imgaussfilt(chunk,[1,300]);
diff = ~((B-A)>0);
se = strel('disk',6);
closeBW = imclose(diff,se);

imagesc(closeBW)
imagesc(BW2)
imagesc(~((B-A)>0))