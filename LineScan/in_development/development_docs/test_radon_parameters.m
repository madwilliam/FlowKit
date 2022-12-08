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

%     n_extrema = numel(result.local_max_theta);
%     for i =1:n_extrema
%         plot_extremai(i,result,data_chunk,R,local_max)
%     end
    
    if visualize
        visualize_result(data_chunk,R,result,local_max,range_of_angles_to_detect,max_number_of_extrema)
    end
end

function plot_extremai(extremai,result,data_chunk,R,local_max)
    [slope,intercept] = get_slope_and_intercept(result,extremai);
    extremax = local_max.sub(extremai,2);
    extremay = local_max.sub(extremai,1);
    span = 10;
    r_start_x = floor(extremax-span);
    r_start_y = floor(extremay-span);
    if r_start_x<=0
        r_start_x=1;
    end
    if r_start_y<=0
        r_start_y=1;
    end
    figure
    ax1=subplot(311);
    ax2=subplot(312);
    ax3=subplot(313);
    hold(ax1,'on')
    hold(ax2,'on')
    hold(ax3,'on')
    imagesc(ax1,R(r_start_y:r_start_y+2*span,r_start_x:r_start_x+2*span))
    scatter(ax1,10,10,'rx');
    xlim(ax1,[1 span*2])
    ylim(ax1,[1 span*2])
    xrange = 1:size(data_chunk,2);
    line_y = intercept + slope .* xrange;
    imagesc(ax2,data_chunk);
    plot(ax2, xrange, line_y, '-.k', 'LineWidth', 2);
    xlim(ax2,[1 size(data_chunk,2)])
    ylim(ax2,[1 size(data_chunk,1)])
    imagesc(ax3, R);
    scatter(ax3,extremax,extremay,'rx');
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

function visualize_result(data_chunk,R,result,local_max,range_of_angles_to_detect,max_number_of_extrema)
    figure;
    nplot = 3; 
    ax1 = subplot(nplot, 1,1);
    ax2 = subplot(nplot, 1,2);
    ax3 = subplot(nplot, 1,3);
    hold (ax2,'on')
    hold (ax1,'on')
    imagesc(ax2, R);
    imagesc(ax1, data_chunk);
    ax1.XLabel.String = 'frame';
    ax1.YLabel.String = 'Line scan intensity';
    ax1.DataAspectRatio = [1,1,1];
    ax2.XLabel.String = 'Theta idx';
    ax2.YLabel.String = 'r';
    imagesc(ax3, R);
    for extremai = 1:max_number_of_extrema
        [slope,intercept] = get_slope_and_intercept(result,extremai);
        xrange = 1:size(data_chunk,2);
        line_y = intercept + slope .* xrange;
        plot(ax1, xrange, line_y, '-.k', 'LineWidth', 2);
        scatter(ax2, local_max.sub(extremai,2), local_max.sub(extremai,1), 'rx');
    end
    Plotter.plot_standard_deviation(range_of_angles_to_detect,result.r_std_vs_theta,ax3)
    xlim(ax1,[1 size(data_chunk,2)])
    ylim(ax1,[1 size(data_chunk,1)])
    set(ax1,'YDir','normal')
    set(ax2,'YDir','normal')
    set(ax3,'YDir','normal')
end

function [slope,intercept] = get_slope_and_intercept(result,extremai)
    local_max_radius = result.local_max_r(extremai);
    local_max_theta = result.local_max_theta(extremai);
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