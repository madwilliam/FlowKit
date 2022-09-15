path = 'Y:\Data and Analysis\Data\Two Photon Directory';
tiff_path = 'Y:\Data and Analysis\Analysis';
out_dir='C:\Users\dklab\Desktop\test';
meta_files = FileHandler.get_meta_files(path);
tif_files = FileHandler.get_tif_files(tiff_path);
pmt_files = FileHandler.get_pmt_files(path);
[shared_experiment,meta_no_tif,tif_no_meta] = FileHandler.get_experiments_with_meta_and_tif(meta_files,tif_files);
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
    time = fileTime/n_data;
    channels=SI.hChannels.channelSave; 
    stimulus = get_stimulus(channels,pmt_files,file_name,nsample,n_data);
    save(append(out_dir,'\',file_name,'.m'),'speed','stimulus','flux','time')
end