classdef Plotter
   methods (Static)
       function plot_line(array,xrange,slope,intercept,ax)
        imagesc(ax, array);
        ax.XLabel.String = 'frame';
        ax.YLabel.String = 'Line scan intensity';
        ax.DataAspectRatio = [1,1,1];
        line_y = intercept + slope .* xrange;
        hold(ax, 'on');
        plot(ax, xrange, line_y, '-.k', 'LineWidth', 2);
       end

       function plot_radon(R,mark_location,ax)
        imagesc(ax, R);
        ax.XLabel.String = 'Theta idx';
        ax.YLabel.String = 'r';
        hold(ax, 'on');
        scatter(ax, mark_location(1), mark_location(2), 'rx');
       end

       function plot_standard_deviation(angles,std,ax)
        [max_std,max_id] = max(std);
        max_std_theta = angles(max_id);
        plot(ax, angles, std); 
        hold(ax, 'on');
        line(ax, [max_std_theta, max_std_theta],...
            [0, max_std], 'Color', 'g');    
        ax.XLabel.String = 'Theta (degrees)';
        ax.YLabel.String = 'Standard deviation';
       end

       function plot_detected_stripes(image,radon_result,start_and_stop)
            figure
            ax1 = subplot(2,1,1);
            ax2 = subplot(2,1,2);
            hold(ax1,'on')
            slope_time_points = start_and_stop(1):start_and_stop(2);
            start_and_stop_image = 1+(start_and_stop-1)*radon_result.stepsize+radon_result.windowsize/2;
            image_time_points = start_and_stop_image(1):start_and_stop_image(2);
            image_chunk = image(1:radon_result.downsample_factor:end,image_time_points);
            imagesc(ax1,image_chunk)
            locations = radon_result.locations(slope_time_points);
            time = radon_result.time(slope_time_points);
            slopes = radon_result.slopes(slope_time_points);
%             plotting_results.locations = radon_result.locations(slope_time_points);
%             plotting_results.time = radon_result.time(slope_time_points);
%             plotting_results.slopes = radon_result.slopes(slope_time_points);
%             [locations,slopes,time] = find_speed_per_cell(plotting_results);
            nlines = numel(locations);
            x = 1:size(image,2);
            for linei = 1:nlines
                loaction = locations(linei);
                slope = slopes(linei);
                intercept = floor(size(image_chunk,1)/2)-slope .* loaction;
                y=slopes(linei)*x+intercept;
                plot(ax1,x,y,'color','red')
            end
            plot(ax2,time,slopes)
            ylim(ax1,[1,size(image_chunk,1)])
            xlim(ax1,[1,size(image_chunk,2)])
            xlim(ax2,[1,max(time)])
            ylim(ax2,[-5,5])
       end
   end
end