classdef RadonTools
   methods (Static)
    function max_value_theta= get_max_value_angle(R,angles_to_detect)
       [~,max_variance_di]=max(max(R));
       max_value_theta=angles_to_detect(max_variance_di);  
    end
    
    function max_value_theta= get_max_variance_angle(R,angles_to_detect)
       variance=var(R);
       [~,max_variance_di]=max(variance);
       max_value_theta=angles_to_detect(max_variance_di);  
    end
    
    function theta_fine = two_level_radon(data_chunk,selection_function)
        angles_fine=-2:.25:2;
        angles_to_detect = 1:179;
        [R,~]=radon(data_chunk,angles_to_detect);
        theta= selection_function(R,angles_to_detect);
        [R_fine,~]=radon(data_chunk,theta+angles_fine);
        theta_fine= selection_function(R_fine,theta+angles_fine);
    end

    function local_max_center_xy = get_local_center(max_r,max_theta,image_size)
        image_center = image_size ./ 2 - 0.5;
        local_max_center_xy = image_center([2,1]) + [cosd(max_theta), -sind(max_theta)] .* max_r;
    end
    
    function [slope,intercept] = get_slope_and_intercept(max_r,max_theta,image_size)
        image_center = image_size ./ 2 - 0.5;
        local_max_center_xy = image_center([2,1]) + [cosd(max_theta), -sind(max_theta)] .* max_r;
        slope = 1 ./ tand(max_theta);
        intercept = local_max_center_xy(2)-slope .* local_max_center_xy(1);
    end

   end
end