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
       function show_flow_speed_around_stimulation(mat_path,tif_path,stimulationi)
           image = FileHandler.load_image_data(tif_path);
           load(mat_path,'speed','time_per_velocity_data_s','dt_ms','start_time','end_time');
           start_time = start_time(stimulationi);
           end_time = end_time(stimulationi);
           chunk_offset = 15000;
           chunk_length = 1000;
           stimulus_chunk_start = start_time-chunk_offset;
           stimulus_chunk_end = end_time+chunk_offset;
           stimulus_image = image(:,stimulus_chunk_start:stimulus_chunk_end);
           imagers = imresize(stimulus_image, 'bilinear', 'Scale', [1/3,1/3]);
           sample_per_v_data = time_per_velocity_data_s*1000/dt_ms;
           [axes, ~] = tight_subplot(10,1,[.01 .01],[.01 .01],[.01 .01]);
           fig_chunk_start = floor((start_time-stimulus_chunk_start)/3);
           fig_chunk_end = floor((end_time-stimulus_chunk_start)/3);
           pointer = 0;
           for i =1:10
               hold(axes(i),'on')
               start_image = (i-1)*chunk_length+1;
               end_image = i*chunk_length;
               image_chunk = imagers(:,start_image:end_image);
               start_speed = floor(start_image*3/sample_per_v_data)+1;
               end_speed = floor(end_image*3/sample_per_v_data);
               speed_time = linspace(1,chunk_length,(end_speed-start_speed+1));
               imagesc(axes(i),image_chunk)
               plot(axes(i),speed_time,speed(1,start_speed:end_speed)+floor(size(image_chunk,1)/2),'r')
               set(gca,'XTick',[])
               hold(axes(i),'off')
               if fig_chunk_start>pointer && fig_chunk_start < pointer+chunk_length
                   line_x = fig_chunk_start - pointer;
                   line(axes(i),[line_x,line_x],[1,size(image_chunk,1)],'Color','k')
               end
               if fig_chunk_end>pointer && fig_chunk_end < pointer+chunk_length
                   line_x =  fig_chunk_end - pointer;
                   line(axes(i),[line_x,line_x],[1,size(image_chunk,1)],'Color','k')
               end
               xlim(axes(i),[1,size(image_chunk,2)])
               ylim(axes(i),[1,size(image_chunk,1)])
               pointer=pointer+chunk_length;
           end
       end
   end
end
