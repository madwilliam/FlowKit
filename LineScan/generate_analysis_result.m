function generate_analysis_result(meta_files,tif_files,pmt_files,out_dir)
shared_experiment = FileHandler.get_experiments_with_meta_and_tif(meta_files,tif_files);
for i = 1:numel(shared_experiment)
    file_name = shared_experiment(i);
    disp(append('working on ',file_name))
    image = FileHandler.load_image_data(tif_files,file_name);
    [SI,RoiGroups] = FileHandler.load_meta_data(meta_files,file_name);
    [dx,dt] = get_dxdt(SI,RoiGroups);
    [raw_slopes,time,locations]=get_slope_from_line_scan(imcomplement(image),100);
    flux = get_flux(raw_slopes,time,locations,dt,100);
    speed = raw_slopes*dx/dt;
    flux = flux.';
    speed=speed.';
    speed(speed==Inf)=max(speed(speed~=Inf));
    nsample = size(image,2);
    fileTime=nsample*dt/1000;
    n_data = numel(speed);
    time_per_data = fileTime/n_data;
    channels=SI.hChannels.channelSave;
    stimulus = get_stimulus(image,channels,pmt_files,file_name,nsample,n_data);
    save(append(out_dir,'\',file_name,'.mat'),'speed','stimulus','flux','time', ...
        'time_per_data','dx','dt','locations','raw_slopes')
end
end