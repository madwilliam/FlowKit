function [local_max_theta,local_max_r,local_max_value] = roi_radon(data_chunk,angles_to_detect)
    [R,radius]=radon(data_chunk,angles_to_detect);
    filted=imgaussfilt(R,10);
    filtered = R-filted;
    filtered(filtered<0)=0;
    values = reshape(filtered,1,[]);
    mask = filtered>(mean(values)+0.5*std(values));
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
    local_max_index = [];
    local_max_r = [];
    local_max_theta = [];
    local_max_value = [];
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
        local_max_r = [local_max_r radius(x)];
        local_max_theta = [local_max_theta angles_to_detect(y)];
        local_max_value = [local_max_value R(x,y)];
    end
end