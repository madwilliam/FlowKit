classdef LineScanAnnalyzer < handle %& dynamicprops
   properties
       panel
       n_pixel
       radon_chunk_size
       dx
       dt
       n_sample
       slopes
       time
       data
       use_physical_units
       chunk_to_examine
       current_line
       k
   end
   methods
       function self = LineScanAnnalyzer(data,chunk_size)
          [self.n_pixel,self.n_sample] = size(data);
          self.data = data;
          self.panel = LineScanAnnalyzerPanel;
          hold(self.panel.UIAxes_2,'on')
          if exist('chunk_size')
              disp(['setting chunk_size = ' num2str(chunk_size)])
              set(self.panel.RadonchunksizeEditField,'Value',chunk_size);
              self.radon_chunk_size = chunk_size;
          end
          [self.slopes,self.time]=get_slope_from_line_scan(self.data,self.radon_chunk_size);
          self.update_values()
          self.update_plot()
          self.main()
       end

       function update_plot(self)
          [self.slopes,self.time]=get_slope_from_line_scan(self.data,self.radon_chunk_size);
          hold(self.panel.UIAxes_2,'off')
          imagesc(self.panel.UIAxes,self.data,'XData', [0 0], 'YData', [0 0])
          stepsize = 0.25*self.radon_chunk_size;
          self.k = self.panel.ChunkToExamineEditField.Value;
          chunk_start = 1+(self.k-1)*stepsize;
          chunk_end = (self.k-1)*stepsize+self.radon_chunk_size;
          line(self.panel.UIAxes,[chunk_start,chunk_start],[-1,self.n_pixel+1],'color','r')
          line(self.panel.UIAxes,[chunk_end,chunk_end],[-1,self.n_pixel+1],'color','r')
          plot(self.panel.UIAxes_2,self.time,self.slopes)
          hold(self.panel.UIAxes_2,'on')
          self.current_line = line(self.panel.UIAxes_2,[1,1],[-100,100],'color','r');
          self.update_line()
          ylim(self.panel.UIAxes_2,[-2,2])
          xlim(self.panel.UIAxes,[0 self.n_sample])
          ylim(self.panel.UIAxes,[0,self.n_pixel])
       end

      function main(self)
          while true
                self.update_values()
                pause(0.1)
          end
      end

      function update_line(self)
        if self.chunk_to_examine<1
            self.chunk_to_examine = 1;
        elseif self.chunk_to_examine>numel(self.time)
            self.chunk_to_examine = numel(self.time);
        end
        time_to_examine = self.time(self.chunk_to_examine);
        self.current_line.XData = [time_to_examine time_to_examine];
      end
      
        function update_values(self)
            if strcmp(self.panel.UnitsButtonGroup.SelectedObject.Text,'Physical Unit')
                self.use_physical_units = true;
            else
                self.use_physical_units = false;
            end
            self.dx = self.panel.dxEditField.Value;
            self.dt = self.panel.dtEditField.Value;
            if self.k ~= self.panel.ChunkToExamineEditField.Value
                self.k = self.panel.ChunkToExamineEditField.Value;
                self.update_plot()
            end
            if self.radon_chunk_size ~= self.panel.RadonchunksizeEditField.Value
                self.radon_chunk_size = self.panel.RadonchunksizeEditField.Value;
                self.update_plot()
            end
            self.chunk_to_examine = self.panel.ChunkToExamineEditField.Value;
            self.update_line()
        end
   end
end


