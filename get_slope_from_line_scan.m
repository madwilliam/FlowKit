function [slopes,time]=get_slope_from_line_scan(data,windowsize)
    stepsize=.25*windowsize;
    nlines=size(data,2);
    nsteps=floor(nlines/stepsize)-3;
    angles_to_detect=(0:179);
    slopes=zeros(nsteps,1);
    time=NaN*ones(nsteps,1);
    for k=1:nsteps
        time(k)=1+(k-1)*stepsize+windowsize/2;
        data_chunk=data(:,1+(k-1)*stepsize:(k-1)*stepsize+windowsize);
        data_chunk = preprocess_data(data_chunk);
        theta = two_step_radon(data_chunk,angles_to_detect);
        slopes(k)=1/tand(theta);
    end
end

function theta_fine = two_step_radon(data_chunk,angles_to_detect)
    angles_fine=-2:.25:2;
    [R,~]=radon(data_chunk,angles_to_detect);
    theta= get_max_value_angle(R,angles_to_detect);
    [R_fine,~]=radon(data_chunk,theta+angles_fine);
    theta_fine= get_max_value_angle(R_fine,theta+angles_fine);
    disp(theta_fine)
end

function data = preprocess_data(data)
    mean_data = mean(data,2);
    mean_data = repmat(mean_data,1,size(data,2));
    mean_data = cast(mean_data,class(data));
    data = data-mean_data;
%     data = imgaussfilt(data,5);
end

function max_value_theta= get_max_value_angle(R,angles_to_detect)
   [~,max_variance_di]=max(max(R));
   max_value_theta=angles_to_detect(max_variance_di);  
end

function max_value_theta= get_max_variance_angle(R,angles_to_detect)
   variance=var(R);
   [~,max_variance_di]=max(variance);
   max_value_theta=angles_to_detect(max_variance_di);  
end