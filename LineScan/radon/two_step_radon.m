function [theta_fine,radius,max_val] = two_step_radon(data_chunk,angles_to_detect)
    angles_fine=-2:.25:2;
    [R,radii]=radon(data_chunk,angles_to_detect);
    theta= get_max_value_angle(R,angles_to_detect);
    [R_fine,~]=radon(data_chunk,theta+angles_fine);
    theta_fine= get_max_variance_minus_kurtosis_angle(R_fine,theta+angles_fine);
    if ~isnan(theta_fine)
        [~,theta_id] = min(abs(angles_to_detect-theta_fine));
        [~,radius_id] = max(R(:,theta_id));
        max_val= max(max(R));
        radius = radii(radius_id);
    else
        max_val = NaN;
        radius = NaN;
    end
end