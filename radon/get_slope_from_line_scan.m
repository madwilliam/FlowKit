function [slopes,time,locations,rval]=get_slope_from_line_scan(data,windowsize,angles_to_detect)
    stepsize=.25*windowsize;
    nlines=size(data,2);
    nsteps=floor(nlines/stepsize)-3;
    if ~exist('angles_to_detect')
      angles_to_detect=(90:160);
    end
    locations=zeros(nsteps,1);
    rval=zeros(nsteps,1);
    slopes=zeros(nsteps,1);
    time=NaN*ones(nsteps,1);
    for k=1:nsteps
        time(k)=1+(k-1)*stepsize+windowsize/2;
        data_chunk=data(:,1+(k-1)*stepsize:(k-1)*stepsize+windowsize);
        data_chunk = preprocess_data(data_chunk);
        [theta,radius,max_val] = two_step_radon(data_chunk,angles_to_detect);
        [slopes(k),locations(k) ]= get_slope_and_location(radius,theta,size(data_chunk));
        locations(k) = locations(k)+1+(k-1)*stepsize;
        rval(k) = max_val;
    end
end

function [theta_fine,radius,max_val] = two_step_radon(data_chunk,angles_to_detect)
    angles_fine=-2:.25:2;
    [R,radii]=radon(data_chunk,angles_to_detect);
    theta= get_max_value_angle(R,angles_to_detect);
    [R_fine,~]=radon(data_chunk,theta+angles_fine);
    theta_fine= get_max_variance_angle(R_fine,theta+angles_fine);
    [~,id] = min(angles_to_detect-theta_fine);
    [~,radius_id] = max(R(:,id));
    max_val= max(max(R));
    radius = radii(radius_id);
end

function max_value_theta= get_max_value_angle(R,angles_to_detect)
   [~,max_variance_di]=max(max(R));
   max_value_theta=angles_to_detect(max_variance_di);  
end

function max_variance_theta= get_max_variance_angle(R,angles_to_detect)
   variance=var(R);
   [~,max_variance_di]=max(variance);
   max_variance_theta=angles_to_detect(max_variance_di);  
end

function [slope,location ]= get_slope_and_location(max_r,max_theta,image_size)
    slope = 1/tand(max_theta);
    image_center = image_size ./ 2 - 0.5;
    local_max_center_xy = image_center([2,1]) + [cosd(max_theta), -sind(max_theta)] .* max_r;
    intercept = local_max_center_xy(2)-slope .* local_max_center_xy(1);
    location = (image_center(2)-intercept)/slope;
end