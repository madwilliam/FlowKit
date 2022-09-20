tiffile = 'C:\Users\dklab\data\Oxyphor2Presonantexamples\invivo\artA_stim100ms_30perc_00002.tif';
start_frame = 201;
pixel_dwell_time = 33.3;
fillfraction=0.9;
[stimulus_frames,po2_frames] = get_tiff_stack_information(tiffile,start_frame);
lines = get_lines(tiffile,start_frame);
n_pixel_per_line = size(image,2);
nlines= numel(lines);
%%
O2Ptime = get_po2_time(pixel_dwell_time,fillfraction,num2cell(size(image)));
nsample = numel(O2Ptime);
%%
allpo2_data = TiffHandler.load_frames(tiffile,po2_frames,lines,nsample);
%%
PO2Plotter.plot_linei_heatmap(allpo2_data,6)
%%
PO2Plotter.plot_linei_line_plot(allpo2_data(150:end,:,:),6)
%%
idx_start=round(5000/pixel_dwell_time)+400;
[parameters,line_fit] = fit_po2_decay(mean_per_line,O2Ptime,idx_start,@(c,xdata) (c(1)*exp(-xdata/c(2))+c(3)));
PO2Plotter.compare_average_and_line_fit(O2Ptime(idx_start:end),mean_per_line(:,idx_start:end)',line_fit')
