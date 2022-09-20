classdef PO2Plotter
   methods (Static)
       function plot_linei_heatmap(all_data,linei)
           figure
           imagesc(squeeze(all_data(1:end,linei,1:end)))
           title(append('signal from line: ',num2str(linei)))
       end

       function plot_linei_line_plot(all_data,linei)
           figure
           plot(squeeze(all_data(1:end,linei,1:end))')
           title(append('signal from line: ',num2str(linei)))
       end
       function compare_average_and_line_fit(time,average,line_fit)
           figure
           subplot(1,2,1)
           plot(time,average);
           colororder(summer(size(average,2)))
           title('average signal per line')
           subplot(1,2,2)
           plot(time,line_fit);
           colororder(summer(size(average,2)))
           title('fitted signal per line')
       end
   end
end