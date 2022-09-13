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
          self.use_physical_units = false;
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
          axInnerPos1 = self.panel.UIAxes.InnerPosition;
          axInnerPos2 = self.panel.UIAxes_2.InnerPosition;
          axInnerPos3 = self.panel.UIAxes2.InnerPosition;
          [self.slopes,self.time,locations]=get_slope_from_line_scan(self.data,self.radon_chunk_size);
          flux = get_flux(self.slopes,self.time,locations,self.dt,self.radon_chunk_size);
          if self.use_physical_units
              self.slopes = self.slopes*self.dx/self.dt;
              self.time = self.time*self.dt;
          end
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
          plot(self.panel.UIAxes2,(1:numel(flux))*0.1,flux)
          ylim(self.panel.UIAxes_2,[min(self.slopes)-1,max(self.slopes)+1])
          xlim(self.panel.UIAxes_2,[0 max(self.time)])
          xlim(self.panel.UIAxes,[0 self.n_sample])
          ylim(self.panel.UIAxes,[0,self.n_pixel])
          innerPosDiff1 = axInnerPos1 - self.panel.UIAxes.InnerPosition;  
          innerPosDiff2 = axInnerPos2 - self.panel.UIAxes_2.InnerPosition;  
          innerPosDiff3 = axInnerPos3 - self.panel.UIAxes2.InnerPosition;  
          self.panel.UIAxes.Position = self.panel.UIAxes.Position + innerPosDiff1;
          self.panel.UIAxes_2.Position = self.panel.UIAxes_2.Position + innerPosDiff2;
          self.panel.UIAxes2.Position = self.panel.UIAxes2.Position + innerPosDiff3;
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
                if self.use_physical_units ~= true
                    self.use_physical_units = true;
                    self.update_plot();
                end
            else
                if self.use_physical_units ~= false
                    self.use_physical_units = false;
                    self.update_plot();
                end
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


