tiffile = 'C:\Users\dklab\data\Oxyphor2Presonantexamples\invivo\artA_stim100ms_30perc_00002.tif';
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
[parameters,line_fit] = fit_po2_decay(mean_per_line,O2Ptime,idx_start,@(c,xdata) (c(1)*exp(-xdata/c(2))+c(3)));
PO2Plotter.compare_average_and_line_fit(O2Ptime(idx_start:end),mean_per_line(:,idx_start:end)',line_fit')
%%
nsample = numel(O2Ptime);
nlines = size(allpo2_data,2);
nframes = size(allpo2_data,1);
line_fit = zeros(nframes,nlines,nsample-idx_start+1);
c0 = [1 40 0];
options.Algorithm='levenberg-marquardt';
options.FunctionTolerance=1e-25;
parameters = cell(nframes,nlines,1);
decay_profile_function = @(c,xdata) (c(1)*exp(-xdata/c(2))+c(3));
parfor j = 1:nframes
    for i = 1:nlines
        xdata = O2Ptime(idx_start:end);
        ydata = allpo2_data(j,i,idx_start:end);
        decay_profile =       @(c) decay_profile_function(c,xdata);
        decay_profile_error = @(c) (ydata - decay_profile(c));
        cAll =  lsqnonlin(decay_profile_error , ...
            c0, [],[],options);
        parameters{j,i} = cAll;
        line_fit(j,i,:) = decay_profile(parameters{j,i});
    end
end

save('save.mat','line_fit','parameters')