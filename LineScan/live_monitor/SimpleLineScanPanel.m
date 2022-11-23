classdef SimpleLineScanPanel < LiveRadonAnnalyzer %& dynamicprops
    properties
       figure
       ax
    end
    methods
        function self = SimpleLineScanPanel(varargin)
            self@LiveRadonAnnalyzer(varargin{:}); 
            self.figure = figure;
            self.ax = axes(self.figure);
            self.active = true;
            self.initiate_data_fields();
            self.start_analysis_loop()
        end
        function update_plot(self)
            plot(self.ax,self.slope_data)
%             xlim(self.ax,[0,size(self.display_data,2)])
%             ylim(self.ax,[0,size(self.display_data,1)])
        end

    end
end