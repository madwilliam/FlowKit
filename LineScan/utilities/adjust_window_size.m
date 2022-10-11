function adjust_window_size(out_dir)
    tif_files = FileHandler.get_tif_files(out_dir);
    mat_files = FileHandler.get_mat_files(out_dir);
    cluster = parcluster('local');
    tasks=[];
    while true
        file_name = input(['Enter file to analyze ' ...
               '\n enter 0 to exit \n'],'s');
        if str2num(file_name)==0
            break
        end
        try
            mat_path = FileHandler.get_file(mat_files,file_name);
            tif_path = FileHandler.get_file(tif_files,file_name);
           window_size = nan;
           load(mat_path,'result','start_time','end_time','dt_ms','dx_um');
           while true
               if isnan(window_size)
                   disp(['showing result with window size = ' num2str(result.windowsize*dt_ms) ...
                       ' ms, ' num2str(result.windowsize) ' sample.  Sample Rate:' num2str(1000/(result.windowsize*dt_ms))])
                   disp(['size: ' num2str(result.windowsize)])
               elseif window_size~=-1
                   disp(['showing result with window size = ' num2str(window_size*dt_ms) ' ms, '  ...
                       num2str(window_size) ' sample.  Sample Rate:' num2str(1000/(window_size*dt_ms))])
               end
               switch window_size
                   case 0
                       close(gcf)
                       break
                   case -1
                       if isnan(last_window)
                           disp('no change applied')
                           break
                       else
                           names = split(mat_path,'/');
                           tif_files = FileHandler.get_tif_files(out_dir);
                           mat_files = FileHandler.get_mat_files(out_dir);
                           file_name = FileHandler.strip_extensions(names{end});
                           job = createJob(cluster);
                           task = createTask(job,@analyze_file,0,{file_name,tif_files,mat_files,last_window});
                           tasks = [tasks,task];
                           submit(job);
                           disp(append('file reanalyzed with window size: ', num2str(last_window)))
                           close(gcf)
                           break
                       end
                   otherwise
                       Plotter.plot_with_window_size(result,start_time,end_time,tif_path,window_size)
                       pause(0.01)
                       last_window = window_size;
                       window_size = input(['Enter window size to try, ' ...
                           '\n enter -1 to recalculate with new windowsize ' ...
                           '\n enter 0 to exit \n']);
               end
               close(gcf)
           end
        catch
            ...
        end
    end
    disp('waiting for all jobs to finish')
    finished = arrayfun(@(task) strcmp(task.State,'finished'),tasks);
    while ~ all(finished)
        pause(5)
        disp(['waiting for all jobs to finish: ' num2str(sum(finished)) '/' num2str(numel(finished))])
        finished = arrayfun(@(task) strcmp(task.State,'finished'),tasks);
    end
    disp('existing, all job finished')
end
