function [all_slopes,all_locations]=get_slope_from_all_stripes(data,windowsize,angles_to_detect)
    nlines=size(data,2);
    nsteps=floor(nlines/windowsize)-3;
    if ~exist('angles_to_detect')
      angles_to_detect=(90:160);
    end
    all_slopes = [];
    all_locations = [];
    slopes=zeros(nsteps,1);
    time=NaN*ones(nsteps,1);
    for k=1:nsteps
        data_chunk=data(:,1+(k-1)*windowsize:k*windowsize);
        data_chunk = preprocess_data(data_chunk);
        [theta,radius,ax1] = two_step_radon(data_chunk,angles_to_detect);
        [slopes,~,locations]= RadonTools.get_slope_intercept_and_location(radius,theta,size(data_chunk));
        nlines = numel(locations);
        x = 1:size(data_chunk,2);
        hold(ax1,'on')
        for linei = 1:nlines
            loaction = locations(linei);
            slope = slopes(linei);
            intercept = floor(size(data_chunk,1)/2)-slope .* loaction;
            y=slopes(linei)*x+intercept;
            plot(ax1,x,y,'color','red')
        end
        hold(ax1,'off')
        ylim(ax1,[1,size(data_chunk,1)])
        xlim(ax1,[1,size(data_chunk,2)])
        pause
        locations = locations+1+(k-1)*windowsize;
        all_slopes = [all_slopes slopes'];
        all_locations = [all_locations locations'];
    end
end

function [all_theta,all_radius,ax1] = two_step_radon(data_chunk,angles_to_detect)
    angles_fine=-2:.25:2;
    [R,radii]=radon(data_chunk,angles_to_detect);
    [radius_ids, theta_ids] = find_local_max(R);
    all_theta = zeros(numel(theta_ids),1);
    all_radius = zeros(numel(theta_ids),1);
    for i = 1:numel(theta_ids)
        max_theta = angles_to_detect(theta_ids(i));
        [R_fine,~]=radon(data_chunk,max_theta+angles_fine);
        theta_fine= get_max_variance_angle(R_fine,max_theta+angles_fine);
        [~,id] = min(angles_to_detect-theta_fine);
        [~,radius_id] = max(R(:,id));
        radius = radii(radius_id);
        all_theta(i) = theta_fine;
        all_radius(i) = radius;
    end
    Rgauss = imgaussfilt(R,2);
    figure
    ax1 = subplot(211);
    ax2 = subplot(212);
    imagesc(ax1,data_chunk)
    imagesc(ax2,Rgauss)
    hold(ax2,'on')
    for i = 1:numel(radius_ids)
        scatter(ax2,theta_ids(i),radius_ids(i))
    end
end

function [radius_ids, theta_ids] = find_local_max(R)
    Rgauss = imgaussfilt(R,2);
    Rgauss = Rgauss/max(max(Rgauss));
    R_T = Rgauss';
    [~, locs1] = findpeaks(Rgauss(:),'MinPeakProminence',0.7); % peaks along x
    [~, locs2] = findpeaks(R_T(:),'MinPeakProminence',0.7); % peaks along y
    data_size = size(Rgauss); % Gets matrix dimensions
    [col2, row2] = ind2sub(size(R_T), locs2); % Converts back to 2D indices
    locs2 = sub2ind(size(Rgauss), row2, col2); % Swaps rows and columns and translates back to 1D indices
    ind = intersect(locs1, locs2); % Finds common peak position
    [radius_ids, theta_ids] = ind2sub(data_size, ind); % to 2D indices
end

function max_variance_theta= get_max_variance_angle(R,angles_to_detect)
   variance=var(R);
   [~,max_variance_di]=max(variance);
   max_variance_theta=angles_to_detect(max_variance_di);  
end

function [slope,~,location ]= RadonTools.get_slope_intercept_and_location(radius,theta,image_size)
    nstripes = numel(radius);
    slope = zeros(nstripes,1);
    location = zeros(nstripes,1);
    image_center = image_size ./ 2 - 0.5;
    for i = 1:nstripes
        thetai = theta(i);
        slope(i) = 1/tand(thetai);
        local_max_center_xy = image_center([2,1]) + [cosd(thetai), -sind(thetai)] .* radius(i);
        intercept = local_max_center_xy(2)-slope(i) .* local_max_center_xy(1);
        location(i) = (image_center(2)-intercept)/slope(i);
    end
    [~,sort_id] = sort(location);
    location = location(sort_id);
    slope = slope(sort_id);
end