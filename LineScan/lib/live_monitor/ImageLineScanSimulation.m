classdef ImageLineScanSimulation
       properties
           image_data
           panel
       end
       methods
           function self = ImageLineScanSimulation(image_path,npoints_to_display)
               self.image_data = FileHandler.load_image_data(image_path);
               get_raw_data = @(counter) self.get_raw_data(counter);
               nsample=size(self.image_data,1);
               if ~exist('npoints_to_display')
                  npoints_to_display=100;
               end
               self.panel = LineScanPanel(get_raw_data,nsample,npoints_to_display);
           end

           function data = get_raw_data(self,counter)
               data = self.image_data(:,(counter-1)*300+1:counter*300);
           end
       end

end