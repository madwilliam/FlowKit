function [result] = test_radon_parameters(data_chunk, range_of_angles_to_detect, extrema_window, ...
    max_number_of_extrema, visualize)

    if isempty(range_of_angles_to_detect)
        range_of_angles_to_detect = (0 : 179).';
    end
    if isrow(range_of_angles_to_detect)
        range_of_angles_to_detect = range_of_angles_to_detect.';
    end
    
    if nargin < 5
        visualize = false;
    end
    [R, radius] = radon(data_chunk, range_of_angles_to_detect);
    local_max = get_local_extremas(R,extrema_window,'max',max_number_of_extrema);
    local_min = get_local_extremas(R,extrema_window,'min',max_number_of_extrema);
    result = package_result(data_chunk,R,range_of_angles_to_detect,local_max,local_min,radius);
    
    if visualize
        visualize_result(data_chunk,R,result,local_max,range_of_angles_to_detect)
    end
end


function result = package_result(data_chunk,R,range_of_angles_to_detect,local_max,local_min,radius)
    [n_pixels, n_lines] = size(data_chunk);
    result = struct;
    result.image_center = [n_pixels, n_lines] ./ 2 - 0.5;
    result.theta = range_of_angles_to_detect;
    result.r_std_vs_theta = std(R, 1, 1, 'omitnan');
    [result.max_std, result.std_peak_theta] = max(result.r_std_vs_theta);
    result.std_peak_theta = range_of_angles_to_detect(result.std_peak_theta);
    result.rt_mean = mean(R(:), 'omitnan');
    result.rt_std_mean = mean(result.r_std_vs_theta, 'omitnan');
    result.local_max_theta = range_of_angles_to_detect(local_max.sub(:, 2));
    result.local_max_r = radius(local_max.sub(:, 1));
    result.local_max_val = local_max.v;
    result.local_min_theta = range_of_angles_to_detect(local_min.sub(:, 2));
    result.local_min_r = radius(local_min.sub(:, 1));
    result.local_min_val = local_min.v;
end

function visualize_result(data_chunk,R,result,local_max,range_of_angles_to_detect)
    [slope,intercept] = get_slope_and_intercept(result);
    figure;
    nplot = 3; 
    ax1 = subplot(nplot, 1,1);
    ax2 = subplot(nplot, 1,2);
    ax3 = subplot(nplot, 1,3);
    Plotter.plot_line(data_chunk,1:size(data_chunk,2),slope,intercept,ax1)
    Plotter.plot_radon(R,flip(local_max.sub),ax2)
    Plotter.plot_standard_deviation(range_of_angles_to_detect,result.r_std_vs_theta,ax3)
    set(ax1,'YDir','normal')
    set(ax2,'YDir','normal')
    set(ax3,'YDir','normal')
end

function [slope,intercept] = get_slope_and_intercept(result)
    local_max_radius = result.local_max_r(1);
    local_max_theta = result.local_max_theta(1);
    local_max_center_xy = result.image_center([2,1]) + [cosd(local_max_theta), -sind(local_max_theta)] .* local_max_radius;
    slope = 1 ./ tand(local_max_theta);
    intercept = local_max_center_xy(2)-slope .* local_max_center_xy(1);
end

function local_extrema = get_local_extremas(data,extrema_window,type,max_number_of_extrema)
    local_extrema = get_local_extrema(data, extrema_window, type);
    [~, n_extrema] = sort(local_extrema.v, 'descend');
    if numel(n_extrema) > max_number_of_extrema
        n_extrema = n_extrema(1 : max_number_of_extrema);
    end
    local_extrema = fun_structure_field_slicing_by_index(local_extrema, n_extrema, 1);
end