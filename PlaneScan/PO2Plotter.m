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
       function plot_fit_to_one_frame(framei,linei,O2Ptime,allpo2_data,idx_start,parameters)
            figure
            time = O2Ptime(idx_start:end);
            ydata = squeeze(allpo2_data(framei,linei,idx_start:end));
            decay_profile_function = @(c,xdata) (c(1)*exp(-xdata/c(2))+c(3));
            line_fit = decay_profile_function(parameters{framei,linei},time);
            clf
            hold on
            plot(time,ydata,'r')
            plot(time,line_fit,'k');
            hold off
       end
       function plot_fit_for_all_frames_from_one_line(idx_start,O2Ptime,line_fit,linei)
            figure
            time = O2Ptime(idx_start:end);
            lines = squeeze(line_fit(:,linei,:))';
            plot(time,lines);
            colororder(summer(size(lines,2)))
       end

       function plot_tau_across_frames_for_each_line(parameters,spacing)
            figure
            all_tau = [];
            nlines = size(parameters,2);
            for linei = 1:nlines
                ps = parameters(:,linei);
                taus = cellfun(@(element) element(2), ps)+linei*spacing;
                all_tau = [all_tau taus];
            end
            plot(all_tau,'r')
       end
   end
end