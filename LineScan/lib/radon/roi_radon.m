function [local_max_theta,local_max_r,local_max_value,R,local_max_index,refined_mask] = roi_radon(data_chunk,angles_to_detect,varargin)
    if ~exist('varargin','var')
        varargin = {5,3,50,2000};
    end
    [sigma,threshold,min_size,max_size] = deal(varargin{:});
    [R,radius]=radon(data_chunk,angles_to_detect);
    [good_connected_components,refined_mask] = find_refined_masks(R,sigma,threshold,min_size,max_size);
    [local_max_index,local_max_r,local_max_theta,local_max_value] = get_local_max_values_and_indes(R,good_connected_components,radius,angles_to_detect);
end

function [good_connected_components,refined_mask] = find_refined_masks(R,sigma,threshold,min_size,max_size)
    filted=imgaussfilt(R,sigma);
    filtered = R-filted;
    filtered(filtered<0)=0;
    values = reshape(filtered,1,[]);
    mask = filtered>(mean(values)+threshold*std(values));
    CC = bwconncomp(mask);
    areas = cellfun(@(x) numel(x),CC.PixelIdxList);
    good = arrayfun(@(x) x >min_size&&x<max_size,areas);
    good_connected_components = CC.PixelIdxList(good);
    refined_mask = zeros(size(R));
    for i = good_connected_components
        [x,y] = ind2sub(size(R),i{1});
        for j = 1:numel(i{1})
            refined_mask(x(j),y(j))=1;
        end
    end
end

function [local_max_index,local_max_r,local_max_theta,local_max_value] = get_local_max_values_and_indes(R,good_connected_components,radius,angles_to_detect)
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
        local_max_r = [local_max_r radius(x)];
        local_max_theta = [local_max_theta angles_to_detect(y)];
        local_max_value = [local_max_value R(x,y)];
    end
end