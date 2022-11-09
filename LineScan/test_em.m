weka_root = '/net/dk-server/bholloway/Zhongkai/matlab_filtered_unprocessed_mask/'; %ML output
mat_root = '/net/dk-server/bholloway/Zhongkai/FoG_DivByGaus/filtered new batch/'; %original mat file locations
tif_files = FileHandler.get_tif_files(mat_root);
mat_files = FileHandler.get_mat_files(mat_root);

file_name = FileHandler.strip_extensions(tif_files(1).name);
tif_path = FileHandler.get_file_path(tif_files,file_name);
tif = FileHandler.load_image_data(tif_path);

chunk = tif(:,1:10000);
chunk = imgaussfilt(chunk,1);
imagesc(chunk)
imagesc(tif(:,1:1000))


X = reshape(chunk,[],1);
X_pos = X(X>0);
[W,M,V,L,k,E] = EM_GM_fast(double(X_pos),2,[],[],1,[]);
mask = zeros(size(X));
positive = E(:,1)<E(:,2);
if mean(X_pos(positive))>mean(X_pos(~positive))
    mask(X>0) = E(:,1)>E(:,2);
else
    mask(X>0) = E(:,1)<E(:,2);
end
mask = reshape(mask,size(chunk));

imagesc(mask(:,1:1000))

Plot_GM(X_pos,k,W,M,V)