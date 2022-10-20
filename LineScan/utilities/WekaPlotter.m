classdef WekaPlotter
   methods(Static)
       function all_results = parse_result_by_stimulation(weka_root,mat_root)
            weka_mat_files = FileHandler.get_mat_files(weka_root);
            mat_files = FileHandler.get_mat_files(mat_root);
            all_results = [];
            resample_frequency = 100;
            for i=1:numel( weka_mat_files )
                weka = weka_mat_files(i);
                file_name = FileHandler.strip_extensions(weka.name);
                mat_file = FileHandler.get_file(mat_files,file_name);
                weka_mat_file = FileHandler.get_file(weka_mat_files,file_name);
                mat = load( mat_file );
                load(weka_mat_file,'stripe_statistics')
                locations = cellfun(@(x) x.location ,stripe_statistics);
                speed_um_ms = cellfun(@(x) x.slope ,stripe_statistics)*mat.dx_um/mat.dt_ms;
                n_stimulus = numel( mat.start_time );  
                for stimulusi=1:n_stimulus 
                    [duration_ms,in_window,pre_stim,post_stim] = WekaPlotter.get_stim_window(mat,stimulusi,locations,stripe_statistics);
                    if sum(in_window) == 0
                        continue
                    end
                    speedi = speed_um_ms(in_window);
                    timei = (locations(in_window) - min(locations(in_window))+1)*mat.dt_ms;
                    [timei,id] = sort(timei);
                    speedi = speedi(id);
                    result = struct();
                    result.duration_ms = duration_ms;
                    result.file_name = [file_name '_stim_' num2str(stimulusi)];
                    result.speed = speedi;
                    result.time = timei/1000;
                    result.mean_pre_stim = mean(speed_um_ms(pre_stim));
                    result.mean_post_stim = mean(speed_um_ms(post_stim));
                    result.filtered = medfilt1(speedi,100);
                    result.standardized =  resample(result.filtered,result.time,resample_frequency);
                    all_results = [all_results result];
                end
            end
       end
    
       function all_file_info = organize_file_information(stimi_result)
            file_names = {stimi_result.file_name};
            animal_id_pattern = "Pack-" + digitsPattern(6);
            date_pattern = digitsPattern(2)+"-" +digitsPattern(2)+"-" +digitsPattern(2) ;
            vessel_pattern = ("Vessel-" +digitsPattern) | ("vessel"+digitsPattern)|("vessel-"+digitsPattern);
            date = cellfun(@(x) extract(x,date_pattern),file_names);
            vessel_id = cellfun(@(x) extract(x,vessel_pattern),file_names,'UniformOutput',false);
            animal_id = cellfun(@(x) extract(x,animal_id_pattern),file_names,'UniformOutput',false);
            n_experiment = numel(file_names);
            all_file_info = [];
            for expi = 1:n_experiment
                file_info = struct();
                file_info.animal_id = animal_id{expi}{1};
                if numel(vessel_id{expi})>0
                    file_info.vessel_id = vessel_id{expi}{1};
                else
                    file_info.vessel_id = 'none';
                end
                file_info.date = date{expi};
                all_file_info = [all_file_info file_info];
            end
       end

       function plot_all_trace_plus_average_grouped_by_vessel(all_file_info,stimi_result)
            n_animals = numel(unique({all_file_info.animal_id}));
            nplots = 0;
            for animali = unique({all_file_info.animal_id})
                is_animal = arrayfun(@(x) strcmp(x.animal_id,animali),all_file_info);
                animal_file = all_file_info(is_animal);
                nplots  = nplots + numel(unique({animal_file.vessel_id}));
            end
            figure
            plots_per_row = 4;
            nrows = ceil(nplots/plots_per_row);
            ploti = 1;
            all_mean_trace = cell(0);
            for animali = unique({all_file_info.animal_id})
                is_animal = arrayfun(@(x) strcmp(x.animal_id,animali),all_file_info);
                animal_file = all_file_info(is_animal);
                animal_result = stimi_result(is_animal);
                for vesseli = unique({animal_file.vessel_id})
                    is_vessel = arrayfun(@(x) strcmp(x.vessel_id,vesseli),animal_file);
                    vessel_file = animal_file(is_vessel);
                    vessel_result = animal_result(is_vessel);
                    subplot(plots_per_row,nrows,ploti)
                    hold on 
                    traces = [];
                    vessel_result = WekaPlotter.unify_standardized_trace(vessel_result);
                    for stimi = 1:size(vessel_result,2)
                        plot(vessel_result(:,stimi),'Color',[0,0,0,0.2])
                    end
                    mean_trace = mean(vessel_result');
                    all_mean_trace{end+1} = mean_trace;
                    plot(mean_trace,'Color','red')
                    [pks,locs] = findpeaks(mean_trace,'MinPeakProminence',0.01);
                    post_stim = locs(locs>1000);
                    loci = post_stim(1);
                    scatter(loci,mean_trace(loci),1000,'rx')
                    hold off
                    title({[animali{1} ' ' vesseli{1}],['tau = ' num2str((loci-1000)/100) ' s']})
                    ploti = ploti+1;
                end
            end
       end

       function print_animal_and_vessel_counts(all_file_info)
           for animali = unique({all_file_info.animal_id})
                disp(animali{1})
                is_animal = arrayfun(@(x) strcmp(x.animal_id,animali),all_file_info);
                animal_file = all_file_info(is_animal);
                for vesseli = unique({animal_file.vessel_id})
                    is_vessel = arrayfun(@(x) strcmp(x.vessel_id,vesseli),animal_file);
                    disp([vesseli{1} ' has ' num2str(sum(is_vessel)) ' recordings'])
                end
           end
       end

       function print_stimulation_counts(all_results)
            all_duration_ms = [all_results.duration_ms];
            for stimulationi = unique(all_duration_ms)
                disp([ 'stimulation duration ' num2str(stimulationi) ' ms'])
                disp(['total repeats ' num2str(sum(all_duration_ms==stimulationi))])
            end
       end
       
       function plot_mean_speed_before_and_after(stimi_result)
            figure
            hold on
            for stimi = 1:numel(stimi_result)
                resulti = stimi_result(stimi);
                plot([0,1],[resulti.mean_pre_stim,resulti.mean_post_stim])
            end
            hold off
       end

       function plot_filtered_trace_separately(stimi_result,stimulationi)
            figure
            hold on
            ploti = 1;
            tiledlayout(8,10, 'Padding', 'none', 'TileSpacing', 'compact'); 
            for stimi = 1:numel(stimi_result)
                resulti = stimi_result(stimi);
                speedi = resulti.speed;
                if isinf(mean(speedi))||all(isnan(speedi))
                    continue
                end
                timei = resulti.time;
                nexttile
                hold on
                plot(timei,speedi-resulti.mean_pre_stim)
                plot(timei,resulti.filtered-resulti.mean_pre_stim ,'LineWidth',3)
                line([10,10],[-10,10],'color','red')
                end_stimuli = 10+stimulationi/1000;
                line([end_stimuli,end_stimuli],[-10,10],'color','r')
                hold off
                ylim([-1.5,1.5])
                title(resulti.file_name)
                ploti = ploti+1;
            end
       end

       function plot_all_filtered_traces_standardize_direction(stimi_result)
            figure
            hold on 
            for stimi = 1:numel(stimi_result)
                resulti = stimi_result(stimi);
                if resulti.mean_pre_stim>0
                    speedi = resulti.filtered-resulti.mean_pre_stim;
                else
                    speedi = -(resulti.filtered-resulti.mean_pre_stim);
                end
                plot(resulti.time,speedi)
            end
            hold off
       end

       function plot_uncentered_filtered_traces(stimi_result)
            figure
            hold on 
            for stimi = 1:numel(stimi_result)
                resulti = stimi_result(stimi);
                plot(resulti.time,resulti.filtered)
            end
            hold off
       end

       function standardized = unify_standardized_trace(stimi_result)
            sign = arrayfun(@sign,[stimi_result.mean_pre_stim]);
            offset = [stimi_result.mean_pre_stim];
            standardized = {stimi_result.standardized};
            tuncated = cellfun(@(x) numel(x)<1700 ,standardized);
            standardized = standardized(~tuncated);
            nsamples = min(cellfun(@numel ,standardized));
            standardized = cellfun(@(x) x(1:nsamples),standardized,'UniformOutput',false);
            standardized = cell2mat(standardized);
            standardized = standardized./sign(~tuncated);
            offset = offset(~tuncated);
            standardized = standardized-offset./sign(~tuncated);
       end

       function plot_average_filtered_response(stimi_result)
            sign = arrayfun(@sign,[stimi_result.mean_pre_stim]);
            offset = [stimi_result.mean_pre_stim];
            standardized = {stimi_result.standardized};
            tuncated = cellfun(@(x) numel(x)<1700 ,standardized);
            standardized = standardized(~tuncated);
            nsamples = min(cellfun(@numel ,standardized));
            standardized = cellfun(@(x) x(1:nsamples),standardized,'UniformOutput',false);
            standardized = cell2mat(standardized);
            standardized = standardized./sign(~tuncated);
            offset = offset(~tuncated);
            figure
            hold on
            for i = standardized-offset./sign(~tuncated)
                plot(i,'Color',[0,0,0,0.2])
            end
            plot(mean((standardized-offset./sign(~tuncated))'),'Color','red','LineWidth',3)
       end

       function [duration_ms,in_window,pre_stim,post_stim] = get_stim_window(mat,stimulusi,locations,stripe_statistics)
            window_size_seconds = 10;
            offset_seconds = 0.5;
            start_time_samples = mat.start_time(stimulusi);
            end_time_samples = mat.end_time(stimulusi);
            start_time_ms = start_time_samples*mat.dt_ms;
            end_time_ms = end_time_samples*mat.dt_ms;
            duration_ms = end_time_ms - start_time_ms;
            duration_ms = WekaPlotter.standardize_stimulation_duration(duration_ms);
            window_size_samples = window_size_seconds*1000 / mat.dt_ms; 
            offset_samples = floor(offset_seconds*1000/ mat.dt_ms);
            analysis_start_samples = floor( start_time_samples - window_size_samples - offset_samples ); 
            if analysis_start_samples < 1
                analysis_start_samples = 1;
            end
            analysis_end_time_samples = floor(end_time_samples + offset_samples + window_size_samples);
            if analysis_end_time_samples > max(locations)
                analysis_end_time_samples = max(locations)+1;
            end
            in_window = cellfun(@(x) x.location>analysis_start_samples && x.location<analysis_end_time_samples ,stripe_statistics);
            pre_stim = cellfun(@(x) x.location>analysis_start_samples && x.location< start_time_samples - offset_samples ,stripe_statistics);
            post_stim = cellfun(@(x) x.location>end_time_samples + offset_samples  && x.location<analysis_end_time_samples ,stripe_statistics);
       end

       function duration_ms = standardize_stimulation_duration(duration_ms)
            if duration_ms > 0 && duration_ms < 0.9
                duration_ms = 0.1;
            elseif duration_ms > .9 && duration_ms < 1.25
                duration_ms = 1;
            elseif duration_ms > 9 && duration_ms < 12.5
                duration_ms = 10;
            elseif duration_ms > 90 && duration_ms < 130
                duration_ms = 100;
            elseif duration_ms > 900 && duration_ms < 1250
                duration_ms = 1000;
            elseif duration_ms > 1900 && duration_ms < 2250
                duration_ms = 2000;
            else
                disp(duration_ms)
                disp("non-ten base stim");
            end
            if numel(duration_ms)>1
                disp(duration_ms)
            end
       end
   end
end
