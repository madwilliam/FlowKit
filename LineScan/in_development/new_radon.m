image_path = '/net/dk-server/bholloway/Zhongkai/FoG/Pack-120821_03-12-22_OBISlaserPwr_9per_00005_roi_1.tif';
image = FileHandler.load_image_data(image_path);
test_radon_parameters(chunk, 1:180, 30,20, 1);
figure
%%
chunk = imcomplement(image(:,1:500));
% chunk = preprocess_data(chunk);
imagesc(chunk)
%%
thetas = 1:180;
[R,radius] = radon(chunk,thetas);
filted=imgaussfilt(R,10);
filtered = R-filted;
filtered(filtered<0)=0;
values = reshape(filtered,1,[]);
% X = values';
% [W,M,V,L,k,E] = EM_GM_fast(double(X),3,[],[],1,[]);
% mask = zeros(size(X));
% positive = E(:,1)<E(:,2);
% if mean(X(positive))<mean(X(~positive))
%     mask = E(:,1)>E(:,2);
% else
%     mask = E(:,1)<E(:,2);
% end
% mask = reshape(mask,size(R));
mask = filtered>(mean(values)+0.5*std(values));
% D = bwdist(~mask);
CC = bwconncomp(mask);
areas = cellfun(@(x) numel(x),CC.PixelIdxList);
good = arrayfun(@(x) x >50&&x<2000,areas);
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
    [~,id] = max(sub_region,[],'all');
    [x,y] = ind2sub(size(R),id);
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
RadonTools.visualize_result(ax1,ax2,data_chunk,R,local_max_index,local_max_r_and_theta)
%%
ermask = reshape(E(:,1)<E(:,2),size(R));
C = imfuse(R/max(max(R))*5,ermask,'falsecolor','Scaling','joint','ColorChannels',[1 2 0]);
imagesc(C)
%%
[max_theta,max_radius,max_val] = roi_radon(data_chunk,1:180);