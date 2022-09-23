function generate_analysis_result(pmt_files,out_dir)
    tif_files = FileHandler.get_tif_files(out_dir);
    mat_files = FileHandler.get_mat_files(out_dir);
    assert(length(tif_files)==length(mat_files))
    nfiles = numel(mat_files);
    for i = 1:nfiles 
        file_name = FileHandler.strip_extensions(matfile.name);
        matfile = mat_files(i);
        disp(append('working on ',matfile.name))
        mat_path = FileHandler.get_file(mat_files,file_name);
        load(mat_path,'has_stimulus','dx_um','dt_ms')
        tif_path = FileHandler.get_file(tif_files,file_name);
        image = FileHandler.load_image_data(tif_path);
        if has_stimulus
            radon_window_size=get_chunksize_from_dt(dt_ms);
            radon_image = imcomplement(image);
            result=get_slope_from_line_scan(radon_image,radon_window_size,@two_step_radon);
%             double_max_result=get_slope_from_line_scan(radon_image,radon_window_size,@double_max_radon);
%             double_variance_result=get_slope_from_line_scan(radon_image,radon_window_size,@double_variance_radon);
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
            save(mat_path,'speed','stimulus','flux','result', ...
                'time_per_velocity_data_s','tif_path','duration_ms','-append')
        end
    end
end