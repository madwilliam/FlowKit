tiffile = '/home/zhw272/test/invivo/artA_stim100ms_30perc_00002.tif';
start_frame = 201;
pixel_dwell_time = 33.3;
fillfraction=0.9;
[stimulus_frames,po2_frames] = get_tiff_stack_information(tiffile,start_frame);
[lines,image_size] = get_lines(tiffile,start_frame);
nlines= numel(lines);
%%
O2Ptime = get_po2_time(pixel_dwell_time,fillfraction,image_size);
nsample = numel(O2Ptime);
%%
allpo2_data = TiffHandler.load_frames(tiffile,po2_frames,lines,nsample);
%%
PO2Plotter.plot_linei_heatmap(allpo2_data,6)
%%
PO2Plotter.plot_linei_line_plot(allpo2_data(150:end,:,:),6)
%%
idx_start=round(5000/pixel_dwell_time)+400;
mean_per_line = squeeze(mean(allpo2_data));
[parameters,line_fit] = fit_po2_decay(mean_per_line,O2Ptime,idx_start,@(c,xdata) (c(1)*exp(-xdata/c(2))+c(3)));
PO2Plotter.compare_average_and_line_fit(O2Ptime(idx_start:end),mean_per_line(:,idx_start:end)',line_fit')
%%
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

save(fullfile('/home/zhw272/test/invivo/','save.mat'),'line_fit','parameters')
%%
load(fullfile('/home/zhw272/test/invivo/','save.mat'),'line_fit','parameters')
%%
figure
framei = 100;
linei = 10;
xdata = O2Ptime(idx_start:end);
ydata = squeeze(allpo2_data(framei,linei,idx_start:end));
decay_profile_function = @(c,xdata) (c(1)*exp(-xdata/c(2))+c(3));
line_fit = decay_profile_function(parameters{framei,linei},xdata);
clf
hold on
plot(xdata,ydata,'r')
plot(time,line_fit,'k');
hold off
%%

figure
time = O2Ptime(idx_start:end);
lines = squeeze(line_fit(:,linei,:))';
plot(time,lines);
colororder(summer(size(lines,2)))
title('average signal per line')
%%
clf
hold on 
linei = 3;
ps = parameters(:,linei);
taus = cellfun(@(element) element(2), ps);
plot(taus,'r')
tp = mean(squeeze(allpo2_data(:,linei,:))');
plot(tp*180,'b')
hold off
%%
% subplot(1,2,2)
% plot(time,line_fit);
% colororder(summer(size(average,2)))
% title('fitted signal per line')
