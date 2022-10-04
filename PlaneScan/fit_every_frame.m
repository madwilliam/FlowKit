function [parameters,line_fit] = fit_every_frame(O2Ptime,allpo2_data,idx_start)
    nsample = numel(O2Ptime);
    nlines = size(allpo2_data,2);
    nframes = size(allpo2_data,1);
    line_fit = zeros(nframes,nlines,nsample-idx_start+1);
    parameters = cell(nframes,nlines,1);
    parfor framei = 1:nframes
        for linei = 1:nlines
            xdata = O2Ptime(idx_start:end);
            ydata = squeeze(allpo2_data(framei,linei,idx_start:end));
            [parameters{framei,linei},line_fit(framei,linei,:)] = fit_exponential(xdata',ydata);
        end
    end
end