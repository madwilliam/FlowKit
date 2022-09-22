function generate_analysis_result(meta_files,tif_files,pmt_files,out_dir)
shared_experiment = FileHandler.get_experiments_with_meta_and_tif(meta_files,tif_files);
for i = 1:numel(shared_experiment)
    file_name = shared_experiment(i);
    disp(append('working on ',file_name))
    tif_file = FileHandler.get_file(tif_files,file_name);
    image = FileHandler.load_image_data(tif_file);
    meta_file = FileHandler.get_file(meta_files,file_name);
    [SI,RoiGroups] = FileHandler.load_meta_data(meta_file);
    [dx_um,dt_ms] = get_dxdt(SI,RoiGroups);
    channels=SI.hChannels.channelSave;
    if stimulus_exists(image,channels,pmt_files,file_name)
        result=get_slope_from_line_scan(imcomplement(image),100,@two_step_radon);
        double_max_result=get_slope_from_line_scan(imcomplement(image),100,@double_max_radon);
        double_variance_result=get_slope_from_line_scan(imcomplement(image),100,@double_variance_radon);
        radon_window_size=round(40/dt_ms);
        flux = get_flux(result,dt_ms,radon_window_size);
        speed = result.slopes*dx_um/dt_ms;
        flux = flux.';
        speed=speed.';
        speed(speed==Inf)=max(speed(speed~=Inf));
        nsample = size(image,2);
        fileTime=nsample*dt_ms/1000;
        n_data = numel(speed);
        time_per_velocity_data_s = fileTime/n_data;
        [stimulus,duration] = get_stimulus(image,channels,pmt_files,file_name,nsample,n_data);
        duration_ms = duration*dt_ms;
        save(append(out_dir,'\',file_name,'.mat'),'speed','stimulus','flux','result', ...
            'time_per_velocity_data_s','dx_um','dt_ms','tif_file','meta_file','double_max_result',...
            'double_variance_result','duration_ms')
    end
end
end