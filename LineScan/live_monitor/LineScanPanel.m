classdef LineScanPanel < handle %& dynamicprops
   properties
       monitor
       raw_data
       data_chunk
       n_pixel
       data_range
       radon_chunk_size
       dx
       dt
       nsample_to_show
       slope_data
       display_time
       display_data
       get_raw_data
       n_sample
       active
       counter
       pause_time
       start_y
       end_y
   end
   methods
       function self = LineScanPanel(get_raw_data,nsample,npoints_to_display)
          self.pause_time = 1;
          self.counter = 1;
          self.get_raw_data = get_raw_data;
          self.monitor = live_monitor;
          if exist('nsample')
              disp(['setting nsamples = ' num2str(nsample)])
              set(self.monitor.TotalPixelsEditField,'Value',nsample);
          end
          if exist('npoints_to_display')
              disp(['setting npoints_to_display = ' num2str(npoints_to_display)])
              set(self.monitor.nsamplestodisplayEditField,'Value',npoints_to_display);
          end
          self.start_plotting_loop()
      end

      function start_plotting_loop(self)
          while true
              if self.active
                  disp('plotting')
                  self.update_live_panel()
              else
                  self.update_values();
                  self.start_live_panel();
              end
              pause(self.pause_time)
          end
      end
      
      function start_live_panel(self)
            self.update_values();
            self.raw_data = self.get_raw_data(self.counter);
            self.data_chunk = reshape(self.raw_data,self.n_pixel,[]);
            self.n_sample = size(self.data_chunk,2);
            self.initialize_data_fields();
      end
      
      function update_live_panel(self)
            self.update_values();
            self.raw_data = self.get_raw_data(self.counter);
            self.data_chunk = reshape(self.raw_data,self.n_pixel,[]);
            self.n_sample = size(self.data_chunk,2);
            self.data_chunk = self.data_chunk(self.data_range(1):self.data_range(2),:);
            result=get_slope_from_line_scan(self.data_chunk,self.radon_chunk_size,@max_and_variance_radon);
            self.update_data(result.slopes,result.time)
            self.update_plot()
            self.counter = self.counter + 1;
      end
        
        function update_values(self)
            self.active = self.monitor.ActiveButton.Value;
            self.dx = self.monitor.dxEditField.Value;
            self.dt = self.monitor.dtEditField.Value;
            self.nsample_to_show = self.monitor.nsamplestodisplayEditField.Value;
            self.radon_chunk_size = self.monitor.RadonchunksizeEditField.Value;
            pixel_start = self.monitor.pixelstartEditField.Value;
            pixel_end = self.monitor.pixelendEditField.Value;
            self.n_pixel = self.monitor.TotalPixelsEditField.Value;
            if pixel_start < 1 || pixel_start >pixel_end || pixel_start > self.n_pixel
                pixel_start = 1;
            end
            if pixel_end <1 || pixel_end< pixel_start || pixel_end > self.n_pixel
                pixel_end = self.n_pixel;
            end
            self.data_range = [pixel_start pixel_end];
            self.pause_time = 1/self.monitor.SamplingRateEditField.Value;
            self.start_y = self.monitor.ystartEditField.Value;
            self.end_y = self.monitor.yendEditField.Value;
        end

        function initialize_data_fields(self)
            self.slope_data = zeros(1,self.nsample_to_show);
            self.display_time = zeros(1,self.nsample_to_show);
            data_per_chunk = (self.n_sample-self.radon_chunk_size)/floor(self.radon_chunk_size*0.25)+1;
            self.display_data = zeros(self.data_range(2)-self.data_range(1)+1,floor(self.nsample_to_show/data_per_chunk*self.n_sample));
        end
        
        function update_data(self,slopes,time)
            n_new_points = length(slopes);
            assert(n_new_points<self.nsample_to_show)
            self.slope_data = circshift(self.slope_data,-n_new_points);
            self.display_time = circshift(self.display_time,-n_new_points);
            self.display_data = circshift(self.display_data,-self.n_sample,2);
            self.display_time(end-n_new_points+1:end) = time+self.display_time(end-n_new_points);
            self.slope_data(end-n_new_points+1:end) = slopes;
            self.display_data(:,end-self.n_sample+1:end) = self.data_chunk;
        end

        function update_plot(self)
            plot(self.monitor.UIAxes,self.slope_data*self.dx/self.dt)
            imagesc(self.monitor.UIAxes_2,self.display_data,'XData', [0 0], 'YData', [0 0])
            xlim(self.monitor.UIAxes_2,[0,size(self.display_data,2)])
            ylim(self.monitor.UIAxes_2,[0,size(self.display_data,1)])
            ylim(self.monitor.UIAxes,[self.start_y,self.end_y])
        end
   end
end


