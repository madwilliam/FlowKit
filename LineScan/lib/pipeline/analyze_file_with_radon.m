function analyze_file_with_radon(file_name,tif_files,mat_files,radon_window_size,radon_function,step_factor)
    if ~exist('radon_function','var') == 1
        radon_function = @two_step_radon;
    end
    if ~exist('step_factor','var') == 1
        step_factor = 0.25;
    end
    disp(append('working on ',file_name));
    mat_path = FileHandler.get_file_path(mat_files,file_name);
    load(mat_path,'has_stimulus','dx_um','dt_ms');
    tif_path = FileHandler.get_file_path(tif_files,file_name);
    image = FileHandler.load_image_data(tif_path);
    if has_stimulus
        if ~exist('radon_window_size','var')
            radon_window_size=get_chunksize_from_dt(dt_ms);
        end
        result=get_slope_from_line_scan(image,radon_window_size,@radon_function);
        rectified_slopes = rectify_signal(result.slopes,1);
        result.slopes = rectify_signal(rectified_slopes,1);
        cell_count_per_second = get_flux(result,dt_ms);
        speed = get_speed(result,dt_ms,dx_um);            
        nsample = size(image,2);
        fileTime=nsample*dt_ms/1000;
        n_data = numel(speed);
        time_per_velocity_data_s = fileTime/n_data;
        save(mat_path,'speed','cell_count_per_second','result', ...
            'time_per_velocity_data_s','tif_path','-append');

        save(mat_path,'time_per_velocity_data_s','tif_path','-append');
    end
end

function speed = get_speed(result,dt_ms,dx_um)
    speed = result.slopes*dx_um/dt_ms;
    speed=speed.';
    speed(speed==Inf)=max(speed(speed~=Inf));
end