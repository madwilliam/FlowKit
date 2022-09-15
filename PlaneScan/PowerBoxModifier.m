classdef PowerBoxModifier
   properties
      hSI
      panel
      image
      nx
      ny

   end
   methods
       function self = PowerBoxModifier(hSI)
           self.hSI = hSI;
           self.panel = PowerboxModPanel;
           self.image = hSI.hDisplay.lastAveragedFrame{3};
           [self.ny,self.nx] = size(self.image);
           imagesc(self.panel.UIAxes,self.image)
           xlim(self.panel.UIAxes,[0 self.nx])
           ylim(self.panel.UIAxes,[0 self.ny])
       end
   end
end