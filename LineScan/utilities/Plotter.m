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

       function plot_stripes_on_image(axis,locations,slopes,n_pixel,nframes)
            nlines = numel(locations);
            x = 1:nframes;
            for linei = 1:nlines
                loaction = locations(linei);
                slope = slopes(linei);
                intercept = n_pixel/2-slope .* loaction;
                y=slopes(linei)*x+intercept;
                plot(axis,x,y,'color','white','LineWidth',1.5)
            end
       end

       function plot_detected_stripes(image,radon_result,start_and_stop)
            figure
            ax1 = subplot(2,1,1);
            ax2 = subplot(2,1,2);
            hold(ax1,'on')
            slope_time_points = start_and_stop(1):start_and_stop(2);
            start_and_stop_image = 1+(start_and_stop-1)*radon_result.stepsize+radon_result.windowsize/2;
            start_and_stop_image = floor(start_and_stop_image);
            image_time_points = start_and_stop_image(1):start_and_stop_image(2);
            image_chunk = image(1:radon_result.downsample_factor:end,image_time_points);
            imagesc(ax1,image_chunk)
            locations = radon_result.locations(slope_time_points)-start_and_stop_image(1)+1;
            time = radon_result.time(slope_time_points);
            slopes = radon_result.slopes(slope_time_points);
            Plotter.plot_stripes_on_image(ax1,locations,slopes,size(image_chunk,1),size(image_chunk,2))
            plot(ax2,time,slopes)
            ylim(ax1,[1,size(image_chunk,1)])
            xlim(ax1,[1,size(image_chunk,2)])
            xlim(ax2,[min(time),max(time)])
            ylim(ax2,[-5,5])
       end

       function show_flow_speed_around_stimulation(mat_path,tif_path)
           load(mat_path,'result','start_time','end_time');
           nstimulus = numel(start_time);
           image = FileHandler.load_image_data(tif_path);
           down_sampling_factor = 3;
           for stimulationi = 1:nstimulus
               figure
               start_time = start_time(stimulationi);
               end_time = end_time(stimulationi);
               chunk_offset = 15000;
               chunk_length = 1000;
               stimulus_chunk_start = start_time-chunk_offset;
               stimulus_chunk_end = end_time+chunk_offset;
               stimulus_image = image(:,stimulus_chunk_start:stimulus_chunk_end);
               in_chunk = arrayfun(@(location) location> stimulus_chunk_start && ...
                   location<stimulus_chunk_end,result.locations);
               imagers = imresize(stimulus_image, 'bilinear', 'Scale', [1/down_sampling_factor,...
                   1/down_sampling_factor]);
               [axes, ~] = tight_subplot(10,1,[.01 .01],[.01 .01],[.01 .01]);
               fig_chunk_start = floor((start_time-stimulus_chunk_start)/down_sampling_factor);
               fig_chunk_end = floor((end_time-stimulus_chunk_start)/down_sampling_factor);
               pointer = 0;
               for i =1:10
                   hold(axes(i),'on')
                   start_image = (i-1)*chunk_length+1;
                   end_image = i*chunk_length;
                   image_chunk = imagers(:,start_image:end_image);
                   [npixels,nframes] = size(image_chunk);
                   imagesc(axes(i),image_chunk)
                   set(gca,'XTick',[])
                   start_speed = start_image*down_sampling_factor;
                   end_speed = end_image*down_sampling_factor;
                   in_stripe = arrayfun(@(location) location> start_speed && ...
                       location<end_speed,result.locations(in_chunk)-stimulus_chunk_start);
                   locations = result.locations(in_chunk)-stimulus_chunk_start+1-pointer*down_sampling_factor;
                   locations = locations(in_stripe);
                   slopes = result.slopes(in_chunk);
                   slopes = slopes (in_stripe);
                   locations = locations/down_sampling_factor;
                   Plotter.plot_stripes_on_image(axes(i),locations,slopes,npixels,nframes)
                   Plotter.plot_stimulus_start_and_stop(axes(i),fig_chunk_start,...
                   fig_chunk_end,pointer,chunk_length,npixels,nframes);
                   hold(axes(i),'off')
                   pointer=pointer+chunk_length;
               end
           end
       end

       function plot_stimulus_start_and_stop(axis,fig_chunk_start,...
               fig_chunk_end,pointer,chunk_length,npixels,nframes)
           if fig_chunk_start>pointer && fig_chunk_start < pointer+chunk_length
               line_x = fig_chunk_start - pointer;
               line(axis,[line_x,line_x],[1,npixels],'Color','k')
           end
           if fig_chunk_end>pointer && fig_chunk_end < pointer+chunk_length
               line_x =  fig_chunk_end - pointer;
               line(axis,[line_x,line_x],[1,npixels],'Color','k')
           end
           xlim(axis,[1,nframes])
           ylim(axis,[1,npixels])
       end

       function speed_coordinate = image_to_speed_coordinates(image_coordinates,mat_path)
           load(mat_path,'time_per_velocity_data_s','dt_ms');
           sample_per_v_data = time_per_velocity_data_s*1000/dt_ms;
           speed_coordinate = floor(image_coordinates/sample_per_v_data)+1;
       end

       function image_coordinate = speed_to_image_coordinates(speed_coordinates,mat_path)
           load(mat_path,'time_per_velocity_data_s','dt_ms');
           sample_per_v_data = time_per_velocity_data_s*1000/dt_ms;
           image_coordinate = floor(speed_coordinates*sample_per_v_data)+1;
       end

       function plot_speed(axis,start_image,end_image,mat_path,chunk_length,npixels)
           load(mat_path,'speed');
           start_speed = Plotter.image_to_speed_coordinates(start_image,mat_path);
           end_speed = Plotter.image_to_speed_coordinates(end_image,mat_path);
           speed_time = linspace(1,chunk_length,(end_speed-start_speed+1));
           plot(axis,speed_time,speed(1,start_speed:end_speed)+floor(npixels/2),'r')
       end
   end
end
