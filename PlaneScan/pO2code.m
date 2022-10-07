tiffile = '/home/zhw272/test/invivo/artA_stim100ms_30perc_00002.tif';
start_frame = 201;
pixel_dwell_time = 33.3;
fillfraction=0.9;
idx_start=round(5000/pixel_dwell_time)+400;
[stimulus_frames,po2_frames] = get_tiff_stack_information(tiffile,start_frame);
[lines,image_size] = get_lines(tiffile,start_frame);
nlines= numel(lines);
O2Ptime = get_po2_time(pixel_dwell_time,fillfraction,image_size);
nsample = numel(O2Ptime);
allpo2_data = TiffHandler.load_frames(tiffile,po2_frames,lines,nsample);
mean_per_line = squeeze(mean(allpo2_data));
%%
PO2Plotter.plot_linei_heatmap(allpo2_data,6)
PO2Plotter.plot_linei_line_plot(allpo2_data(150:end,:,:),6)
%%
[parameters,line_fit] = fit_po2_decay(mean_per_line,O2Ptime,idx_start,@(c,xdata) (c(1)*exp(-xdata/c(2))+c(3)));
PO2Plotter.compare_average_and_line_fit(O2Ptime(idx_start:end),mean_per_line(:,idx_start:end)',line_fit')
%%
[parameters,line_fit] = fit_every_frame(O2Ptime,allpo2_data,idx_start);
%%
PO2Plotter.plot_fit_to_one_frame(framei,linei,O2Ptime,allpo2_data,idx_start,parameters)
PO2Plotter.plot_fit_for_all_frames_from_one_line(idx_start,O2Ptime,line_fit,linei)
PO2Plotter.plot_tau_across_frames_for_each_line(parameters,5)
%%
plot(squeeze(mean(allpo2_data(1:10,5,:))))
[nframes,nchannels,~] = size(allpo2_data);
windowsize = 10;
nwindows = nframes-windowsize;
averaged_data = zeros(nwindows,size(allpo2_data,2),size(allpo2_data,3));
for channeli = 1:nchannels
    for windowi =1:nwindows
        windowstart = windowi;
        windowend = windowi+windowsize;
        averaged_data(windowi,channeli,:) = squeeze(mean(allpo2_data(windowstart:windowend,channeli,:)));
    end
end
%%
parpool('threads')
[parameters,line_fit] = fit_every_frame(O2Ptime,averaged_data,idx_start);
framei = 200;
linei = 5;
PO2Plotter.plot_fit_to_one_frame(framei,linei,O2Ptime,averaged_data,idx_start,parameters)
PO2Plotter.plot_tau_across_frames_for_each_line(parameters,3)