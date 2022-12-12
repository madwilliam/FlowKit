image_path = '/net/dk-server/bholloway/Zhongkai/Pack-100322 Tifs and Mats/diving_vessel_-180um_7xx_00011_roi_1.tif';
image = FileHandler.load_image_data(image_path);
test_radon_parameters(chunk, 1:180, 30,20, 1);
figure
%%
chunk = image(:,1:500);
chunk = preprocess_data(chunk);
imagesc(chunk)
%%
thetas = 1:180;
[R,radius] = radon(chunk,thetas);
filted=imgaussfilt(R,5);
filtered = R-filted;
filtered(filtered<0)=0;
values = reshape(filtered,1,[]);
mask = filtered>(mean(values)+3*std(values));
CC = bwconncomp(mask);
areas = cellfun(@(x) numel(x),CC.PixelIdxList);
good = arrayfun(@(x) x >30&&x<1000,areas);
good_connected_components = CC.PixelIdxList(good);
refined_mask = zeros(size(R));
for i = good_connected_components
    [x,y] = ind2sub(size(R),i{1});
    for j = 1:numel(i{1})
        refined_mask(x(j),y(j))=1;
    end
end
%%
imagesc(mask)
imagesc(refined_mask)
imagesc(R)
imagesc(filtered)
imagesc(filted)
%%
local_max_index = [];
local_max_r_and_theta = [];
for i = good_connected_components
    refined_mask = zeros(size(R));
    [x,y] = ind2sub(size(R),i{1});
    for j = 1:numel(i{1})
        refined_mask(x(j),y(j))=1;
    end
    sub_region = R;
    sub_region(~refined_mask) = 0;
    variance = zeros(size(refined_mask,2),1);
    for columni = 1:size(refined_mask,2)
        this_column = refined_mask(:,columni);
        if any(this_column)
            values = R(:,columni);
            values = values(find(this_column));
            variance(columni) = var(values);
        end
    end
    [~,y] = max(variance);
    R_values = R(:,y);
    this_column = refined_mask(:,y);
    in_mask_ids = find(this_column);
    values = R_values(in_mask_ids);
    [~,id] = max(values);
    x = in_mask_ids(id);
    local_max_index = [local_max_index [x,y]'];
    local_max_r_and_theta = [local_max_r_and_theta [radius(x),thetas(y)]'];
end
local_max_index = local_max_index';
local_max_r_and_theta = local_max_r_and_theta';
%%
figure
ax = gca;
sub_region = R;
sub_region(~refined_mask) = sub_region(~refined_mask)*0.5;
imagesc(ax,sub_region)
set(ax,'YDir','normal')
%%
figure
ax1=subplot(211);
ax2=subplot(212);
RadonTools.visualize_result(ax1,ax2,chunk,R,local_max_index,local_max_r_and_theta)
%%
ermask = reshape(E(:,1)<E(:,2),size(R));
C = imfuse(R/max(max(R))*5,ermask,'falsecolor','Scaling','joint','ColorChannels',[1 2 0]);
imagesc(C)
%%
[max_theta,max_radius,max_val] = roi_radon(data_chunk,1:180);
%%
annalyzer = RadonAnnalyzer(@roi_radon,1);
annalyzer.run_batch_radon_analysis(out_dir);
%%
a = local_max_index;
b = local_max_r_and_theta;
%%
varargin = {5,3,30,1000};
[local_max_theta,local_max_r,~,R,local_max_index,refined_mask] = roi_radon(chunk,1:180,varargin{:});
local_max_r_and_theta = [local_max_r',local_max_theta'];
R(~refined_mask) = R(~refined_mask)*0.5;
RadonTools.visualize_result(ax1,ax2,chunk,R,local_max_index',local_max_r_and_theta)