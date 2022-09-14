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

       function plot_detected_stripes(image,locations,slopes,time)
            figure
            ax1 = subplot(2,1,1);
            ax2 = subplot(2,1,2);
            hold(ax1,'on')
            imagesc(ax1,image)
            nlines = numel(locations);
            x = 1:size(image,2);
            for linei = 1:nlines
                loaction = locations(linei);
                slope = slopes(linei);
                intercept = floor(size(image,1)/2)-slope .* loaction;
                y=slopes(linei)*x+intercept;
                plot(ax1,x,y,'color','red')
            end
            plot(ax2,time,slopes)
            ylim(ax1,[1,size(image,1)])
            xlim(ax1,[1,size(image,2)])
       end
   end
end