function generate_analysis_result(out_dir)
    tif_files = FileHandler.get_tif_files(out_dir);
    mat_files = FileHandler.get_mat_files(out_dir);
    assert(length(tif_files)==length(mat_files))
    nfiles = numel(mat_files);
    for i = 1:nfiles 
        matfile = mat_files(i);
        file_name = FileHandler.strip_extensions(matfile.name);
        disp(append('working on ',file_name))
        mat_path = FileHandler.get_file(mat_files,file_name);
        load(mat_path,'has_stimulus','dx_um','dt_ms')
        tif_path = FileHandler.get_file(tif_files,file_name);
        image = FileHandler.load_image_data(tif_path);
        if has_stimulus
            radon_window_size=get_chunksize_from_dt(dt_ms);
            radon_image = imcomplement(image);
            result=get_slope_from_line_scan(radon_image,radon_window_size,@two_step_radon);
            cell_count_per_second = get_flux(result,dt_ms);
            speed = get_speed(result,dt_ms,dx_um);            
            nsample = size(image,2);
            fileTime=nsample*dt_ms/1000;
            n_data = numel(speed);
            time_per_velocity_data_s = fileTime/n_data;
            save(mat_path,'speed','cell_count_per_second','result', ...
                'time_per_velocity_data_s','tif_path','-append')
        end
    end
end
function speed = get_speed(result,dt_ms,dx_um)
    speed = result.slopes*dx_um/dt_ms;
    speed=speed.';
    speed(speed==Inf)=max(speed(speed~=Inf));
end