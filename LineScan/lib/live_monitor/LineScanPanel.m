classdef LineScanPanel < LiveRadonAnnalyzer %& dynamicprops
   properties
       monitor
   end
   methods
       function self = LineScanPanel(varargin)
          self@LiveRadonAnnalyzer(varargin{:}); 
          self.monitor = live_monitor;
          set(self.monitor.TotalPixelsEditField,'Value',self.n_pixel);
          set(self.monitor.nsamplestodisplayEditField,'Value',self.nsample_to_show);
          set(self.monitor.RadonchunksizeEditField,'Value',self.radon_chunk_size);
          self.initiate_data_fields();
          self.start_analysis_loop()
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
            self.raw_data = self.get_raw_data(self.counter);
            self.data_chunk = reshape(self.raw_data,self.n_pixel,[]);
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


