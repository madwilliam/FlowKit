path = 'C:\Users\Montana\Documents\Server_Data and Analysis\Test\';
out_dir='C:\Users\Montana\Documents\Server_Data and Analysis\Test\';
meta_files = FileHandler.get_meta_files(path);
tif_files = FileHandler.get_tif_files(path);
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
    fileTime=size(image,2)*dt/1000; 
    n_data = numel(speed);
    sample_per_data = size(image,2)/n_data;
    time = fileTime/n_data;
    channels=SI.hChannels.channelSave; 
    if channels(end) == 4
        pmt_file = FileHandler.get_file(pmt_files,file_name);
        fid=fopen([pmt_file.folder '\' pmt_file.name],'r');
        M=fread(fid,'int16=>int16');
        M=M(2:2:end);
        M=int16(M);
        n = numel(M)/n_data;
        stimulus = M(1 : floor(n) : end);
        stimulus=int16(stimulus(1:n_data));
    else
        space_average = mean( image,1 );
        [ ~, stimulation_start ] = max( space_average );
        n_max_index = sum( (space_average == intmax(class(image)) ) );
        if n_max_index ~= 0
            [start_time,end_time] = find_event_start_and_end_time(space_average == intmax(class(image)));
            id = find(start_time==stimulation_start);
            stimulation_end = end_time(id);
            stimulus = zeros(1 , n_data);
            stimulation_start = floor(stimulation_start/sample_per_data);
            stimulation_end = floor(stimulation_end/sample_per_data);
            stimulus(stimulation_start:stimulation_end)=1;
        else
            stimulus = NaN;
        end
    end
    save(append(out_dir,'\',file_name,'.mat'),'speed','stimulus','flux','time')
end