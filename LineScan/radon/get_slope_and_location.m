function [slope,location,intercept]= get_slope_and_location(max_r,max_theta,image_size)
    slope = 1/tand(max_theta);
    image_center = image_size ./ 2;
    local_max_center_xy = image_center([2,1]) + [cosd(max_theta), -sind(max_theta)] .* max_r;
    intercept = local_max_center_xy(2)-slope .* local_max_center_xy(1);
    location = (image_center(1)-intercept)/slope;
end