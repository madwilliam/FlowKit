classdef RadonAnnalyzer
   properties
      radon_window_size
      radon_function
      step_factor
   end
   methods
      function self = RadonAnnalyzer(radon_function,step_factor)
        self.step_factor = step_factor;
        self.radon_function = radon_function;
      end

      function result=get_slope_from_line_scan(self,radon_image)
            stepsize=floor(self.step_factor*self.radon_window_size);
            nsample = size(radon_image,2);
            nsteps=floor(nsample/stepsize)-3;
            result.locations=[];
            result.slopes=[];
            result.windowsize = self.radon_window_size;
            result.stepsize = stepsize;
            for k=1:nsteps
                result.time(k)=1+(k-1)*stepsize+self.radon_window_size/2;
                data_chunk=radon_image(:,1+(k-1)*stepsize:(k-1)*stepsize+self.radon_window_size);
                data_chunk = preprocess_data(data_chunk);
                [theta,radius,~] = self.radon_function(data_chunk,1:179);
                if numel(radius)>0
                    [slopes,locations] = get_slope_and_location(radius,theta,size(data_chunk));
                    result.slopes = [result.slopes slopes];
                    result.locations = [result.locations locations+1+(k-1)*stepsize];
                end
            end
      end

      function analyze_file_with_radon(self,file_name,tif_files,mat_files)
            disp(append('working on ',file_name));
            mat_path = FileHandler.get_file_path(mat_files,file_name);
            load(mat_path,'has_stimulus','dx_um','dt_ms');
            tif_path = FileHandler.get_file_path(tif_files,file_name);
            image = FileHandler.load_image_data(tif_path);
            if has_stimulus
                self.radon_window_size=get_chunksize_from_dt(dt_ms);
                result=self.get_slope_from_line_scan(image);
                rectified_slopes = rectify_signal(result.slopes,1);
                result.slopes = rectify_signal(rectified_slopes,1);
%                 cell_count_per_second = get_flux(result,dt_ms);
                speed = self.get_speed(result,dt_ms,dx_um);            
                nsample = size(image,2);
                fileTime=nsample*dt_ms/1000;
                n_data = numel(speed);
                time_per_velocity_data_s = fileTime/n_data;
                save(mat_path,'speed','result', ...
                    'time_per_velocity_data_s','tif_path','-append');
        
                save(mat_path,'time_per_velocity_data_s','tif_path','-append');
            end
        end
        
        function speed = get_speed(self,result,dt_ms,dx_um)
            speed = result.slopes*dx_um/dt_ms;
            speed=speed.';
            speed(speed==Inf)=max(speed(speed~=Inf));
        end

        function run_batch_radon_analysis(self,out_dir)
            tif_files = FileHandler.get_tif_files(out_dir);
            mat_files = FileHandler.get_mat_files(out_dir);
            nfiles = numel(mat_files);
            parfor i = 1:nfiles 
                try
                    matfile = mat_files(i);
                    file_name = FileHandler.strip_extensions(matfile.name);
                    self.analyze_file_with_radon(file_name,tif_files,mat_files);
                catch ME
                    log_error(file_name,ME,out_dir);
                end
            end
        end
   end
end