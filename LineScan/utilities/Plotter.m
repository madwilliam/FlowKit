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
       function save_flow_speed_around_stimulation(mat_path,tif_path,save_path)
           function save_figure(stimulationi)
               set(gcf, 'Visible', 'off');
               H = getframe(gcf);
               imwrite(H.cdata, append(save_path,'_stimulation',num2str(stimulationi),'.png'));
               close(gcf)
           end
           Plotter.show_flow_speed_around_stimulation(mat_path,tif_path,@save_figure)
       end
        
       function show_flow_speed_around_stimulation(mat_path,tif_path,save_function)
           if ~exist('save_function','var')
                save_function = nan;
                show_plot = true;
           else
               show_plot = false;
           end
           load(mat_path,'result','start_time','end_time');
           nstimulus = numel(start_time);
           image = FileHandler.load_image_data(tif_path);
           down_sampling_factor = 3;
           for stimulationi = 1:nstimulus
               f = figure;
               if show_plot==false
                   set(gcf, 'Visible', 'off');
               end
               start_timei = start_time(stimulationi);
               end_timei = end_time(stimulationi);
               chunk_offset = 15000;
               chunk_length = 1000;
               [imagers,all_slopes,all_locations] = Plotter.get_plotting_information(image,start_timei,end_timei,chunk_offset,chunk_length,result,down_sampling_factor);
               Plotter.plot_strips(imagers,all_locations,all_slopes,start_timei,...
                   end_timei,chunk_offset,chunk_length,down_sampling_factor,show_plot)
               if isa(save_function,'function_handle')
                   save_function(stimulationi);
               end
           end
        end
        
       function [imagers,all_slopes,all_locations] = get_plotting_information(image,...
               start_timei,end_timei,chunk_offset,chunk_length,result,down_sampling_factor)
            imagers = Plotter.get_donsampled_image(image,start_timei,end_timei,chunk_offset,down_sampling_factor);
            [all_slopes,all_locations] = Plotter.parse_slopes_and_locations(chunk_length,result,down_sampling_factor,start_timei,end_timei,chunk_offset);
       end
       function [all_slopes,all_locations] = parse_slopes_and_locations(chunk_length,result,down_sampling_factor,start_timei,end_timei,chunk_offset)
            stimulus_chunk_start = start_timei-chunk_offset;
            stimulus_chunk_end = end_timei+chunk_offset;
            in_chunk = arrayfun(@(location) location> stimulus_chunk_start && ...
               location<stimulus_chunk_end,result.locations);
            pointer = 0;
            all_slopes = cell(10);
            all_locations = cell(10);
            for i =1:10
               start_image = (i-1)*chunk_length+1;
               end_image = i*chunk_length;
               start_speed = start_image*down_sampling_factor;
               end_speed = end_image*down_sampling_factor;
               in_stripe = arrayfun(@(location) location> start_speed && ...
                   location<end_speed,result.locations(in_chunk)-stimulus_chunk_start);
               locations = result.locations(in_chunk)-stimulus_chunk_start+1-pointer*down_sampling_factor;
               locations = locations(in_stripe);
               slopes = result.slopes(in_chunk);
               all_slopes{i} = slopes (in_stripe);
               all_locations{i} = locations/down_sampling_factor;
               pointer=pointer+chunk_length;
            end
       end
      
       function [imagers,stimulus_image] = get_donsampled_image(image,start_timei,end_timei,chunk_offset,down_sampling_factor)
            stimulus_chunk_start = start_timei-chunk_offset;
            stimulus_chunk_end = end_timei+chunk_offset;
            stimulus_image = image(:,stimulus_chunk_start:stimulus_chunk_end);
            imagers = imresize(stimulus_image, 'bilinear', 'Scale', [1/down_sampling_factor,...
               1/down_sampling_factor]);
       end
       
       function plot_with_window_size(result,start_time,end_time,tif_path,window_size,title)
           if ~exist('title','var')
                title = '';
           end
           nstimulus = numel(start_time);
           image = FileHandler.load_image_data(tif_path);
           down_sampling_factor = 3;
           for stimulationi = 1:nstimulus
               start_timei = start_time(stimulationi);
               end_timei = end_time(stimulationi);
               chunk_offset = 15000;
               chunk_length = 1000;
               [imagers,stimulus_image] = Plotter.get_donsampled_image(image,...
                   start_timei,end_timei,chunk_offset,down_sampling_factor);
               if isnan(window_size)
                   [all_slopes,all_locations] = Plotter.parse_slopes_and_locations(chunk_length,result,down_sampling_factor,start_timei,end_timei,chunk_offset);
               else
                   [all_slopes,all_locations] = Plotter.recalculate_slope_and_location(stimulus_image,window_size,down_sampling_factor,chunk_length);
               end
               Plotter.plot_strips(imagers,all_locations,all_slopes,start_timei,end_timei,chunk_offset,chunk_length,down_sampling_factor,true,title)
           end
       end

       function [all_slopes,all_locations] = recalculate_slope_and_location(stimulus_image,window_size,down_sampling_factor,chunk_length)
            result=get_slope_from_line_scan(stimulus_image,window_size,@two_step_radon);
            pointer = 0;
            all_slopes = cell(10);
            all_locations = cell(10);
            for i =1:10
               start_image = (i-1)*chunk_length+1;
               end_image = i*chunk_length;
               start_speed = start_image*down_sampling_factor;
               end_speed = end_image*down_sampling_factor;
               in_stripe = arrayfun(@(location) location> start_speed && ...
                   location<end_speed,result.locations);
               locations = result.locations-pointer*down_sampling_factor;
               locations = locations(in_stripe);
               slopes = result.slopes;
               all_slopes{i} = slopes (in_stripe);
               all_locations{i} = locations/down_sampling_factor;
               pointer=pointer+chunk_length;
            end
       end

       function plot_strips(image,locations,slopes,start_timei,end_timei,chunk_offset,chunk_length,down_sampling_factor,show_plot,title)
           if ~exist('show_plot','var')
                show_plot = true;
           end
           if ~exist('title','var')
                title = '';
           end
           stimulus_chunk_start = start_timei-chunk_offset;
           fig_chunk_start = floor((start_timei-stimulus_chunk_start)/down_sampling_factor);
           fig_chunk_end = floor((end_timei-stimulus_chunk_start)/down_sampling_factor);
           if show_plot
               f = figure;
           else
               f = figure('Visible','Off');
           end
           [axes, ~] = tight_subplot(10,1,[.01 .01],[.01 .01],[.01 .01]);
           set(get(axes(end), 'title'), 'string', title)
           set(get(axes(end), 'title'), 'FontSize', 18)
           set(get(axes(end), 'title'), 'Color', [0,0,0])
           pointer = 0;
           for i =1:10
               hold(axes(i),'on')
               start_image = (i-1)*chunk_length+1;
               end_image = i*chunk_length;
               image_chunk = image(:,start_image:end_image);
               [npixels,nframes] = size(image_chunk);
               imagesc(axes(i),image_chunk)
               set(gca,'XTick',[])
               Plotter.plot_stripes_on_image(axes(i),locations{i},slopes{i},npixels,nframes)
               Plotter.plot_stimulus_start_and_stop(axes(i),fig_chunk_start,...
               fig_chunk_end,pointer,chunk_length,npixels,nframes);
               hold(axes(i),'off')
               pointer=pointer+chunk_length;
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
