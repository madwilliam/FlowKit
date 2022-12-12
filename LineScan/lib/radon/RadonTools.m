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
    
    function [slope,intercept,location] = get_slope_intercept_and_location(max_r,max_theta,image_size)
        image_center = image_size ./ 2 - 0.5;
        assert(numel(max_r)==numel(max_theta))
        n_lines = numel(max_r);
        slope = [];
        intercept = [];
        location = [];
        for i = 1:n_lines
            [slopei,intercepti,locationi] = RadonTools.get_single_slope_intercept_and_location(max_r(i),max_theta(i),image_center);
            slope = [slope slopei];
            intercept = [intercept intercepti];
            location = [location locationi];
        end
    end

    function [slope,intercept,location] = get_single_slope_intercept_and_location(max_r,max_theta,image_center)
        local_max_center_xy = image_center([2,1]) + [cosd(max_theta)', -sind(max_theta)']' .* max_r;
        slope = 1 ./ tand(max_theta);
        intercept = local_max_center_xy(2)-slope .* local_max_center_xy(1);
        location = (image_center(1)-intercept)./slope;
    end

    function visualize_result(ax1,ax2,data_chunk,R,local_max_index,local_max_r_and_theta)
        hold (ax2,'on')
        hold (ax1,'on')
        imagesc(ax2, R);
        imagesc(ax1, data_chunk);
        ax1.XLabel.String = 'frame';
        ax1.YLabel.String = 'Line scan intensity';
        ax1.DataAspectRatio = [1,1,1];
        ax2.XLabel.String = 'Theta idx';
        ax2.YLabel.String = 'r';
        for extremai = 1:size(local_max_index,1)
            pointi = local_max_index(extremai,:);
            r_and_theta = local_max_r_and_theta(extremai,:);
            [slope,intercept] = RadonTools.get_slope_intercept_and_location(r_and_theta(1),r_and_theta(2),size(data_chunk));
            xrange = 1:size(data_chunk,2);
            line_y = intercept + slope .* xrange;
            plot(ax1, xrange, line_y, '-.k', 'LineWidth', 2);
            scatter(ax2, pointi(2), pointi(1),500, 'r.');
        end
        xlim(ax1,[1 size(data_chunk,2)])
        ylim(ax1,[1 size(data_chunk,1)])
        xlim(ax2,[1 size(R,2)])
        ylim(ax2,[1 size(R,1)])
        set(ax1,'YDir','normal')
        set(ax2,'YDir','normal')
    end

   end
end