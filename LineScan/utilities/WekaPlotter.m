classdef WekaPlotter
   methods(Static)
       function all_results = parse_result_by_stimulation(weka_root,mat_root,offset_seconds,window_size_seconds)
            weka_mat_files = FileHandler.get_mat_files(weka_root);
            mat_files = FileHandler.get_mat_files(mat_root);
            all_results = [];
            resample_frequency = 100;
            for i=1:numel( weka_mat_files )
                try
                    weka = weka_mat_files(i);
                    file_name = FileHandler.strip_extensions(weka.name);
                    mat_file = FileHandler.get_file_path(mat_files,file_name);
                    weka_mat_file = FileHandler.get_file_path(weka_mat_files,file_name);
                    mat = load( mat_file );
                    load(weka_mat_file,'stripe_statistics')
                    results = WekaPlotter.get_result_from_tif_and_stripes(stripe_statistics,mat,offset_seconds,window_size_seconds,resample_frequency,file_name);
                    all_results = [all_results results];
                catch
                    disp(stimulusi)
                end
            end
       end

       function all_results = parse_result_by_stimulation_radon(mat_root,offset_seconds,window_size_seconds)
            mat_files = FileHandler.get_mat_files(mat_root);
            all_results = [];
            resample_frequency = 100;
            for i=1:numel( mat_files )
                try
                    file = mat_files(i);
                    file_name = FileHandler.strip_extensions(file.name);
                    mat_file = FileHandler.get_file_path(mat_files,file_name);
                    mat = load( mat_file );
                    stripe_statistics = cell(0);
                    n_stripes = numel(mat.result.locations);
                    for stripei = 1:n_stripes
                        stripe.slope = mat.result.slopes(stripei);
                        stripe.location = mat.result.locations(stripei);
                        stripe_statistics{end+1} = stripe;
                    end
                    %load(weka_mat_file,'stripe_statistics')
                    results = WekaPlotter.get_result_from_tif_and_stripes(stripe_statistics,mat,offset_seconds,window_size_seconds,resample_frequency,file_name);
                    all_results = [all_results results];
                catch
                    disp(stimulusi)
                end
            end
       end

       function results = get_result_from_tif_and_stripes(stripe_statistics,mat,offset_seconds,window_size_seconds,resample_frequency,file_name)
            locations = cellfun(@(x) x.location ,stripe_statistics);
            [locations,id] = sort(locations);
            stripe_statistics = stripe_statistics(id);
            ispositive = cellfun(@(x) x.location>0 ,stripe_statistics);
            stripe_statistics = stripe_statistics(ispositive);
            locations = cellfun(@(x) x.location ,stripe_statistics);
            speed_um_ms = cellfun(@(x) x.slope ,stripe_statistics)*mat.dx_um/mat.dt_ms;
            time = locations*mat.dt_ms/1000;
            time(time==inf)=0;
            [standardized,ty] =  resample(speed_um_ms,time,resample_frequency);
            filtered = medfilt1(standardized,20);
            n_stimulus = numel( mat.start_time );  
            results = [];
            for stimulusi=1:n_stimulus 
                try
                    [duration_ms,in_window,pre_stim,post_stim,pre_stim_standard,post_stim_standard,in_window_standard] ...
                        = WekaPlotter.get_stim_window(mat,stimulusi,locations,...
                        stripe_statistics,max(time),resample_frequency,...
                        offset_seconds,window_size_seconds);
                    if sum(in_window) == 0
                        continue
                    end
                    result = struct();
                    result.duration_ms = duration_ms;
                    result.file_name = [file_name '_stim_' num2str(stimulusi)];
                    result.speed = speed_um_ms(in_window);
                    result.time = time(in_window)-min(time(in_window));
                    if numel(ty)<numel(in_window_standard)
                        diff = numel(in_window_standard)-numel(ty);
                        in_window_standard = in_window_standard(1:end-diff);
                        post_stim_standard = post_stim_standard(1:end-diff);
                        pre_stim_standard = pre_stim_standard(1:end-diff);
                    end
                    result.time_standard = ty(in_window_standard);
                    result.speed_standard = filtered(in_window_standard);
                    result.time_pre_stim_standard = ty(pre_stim_standard);
                    result.speed_pre_stim = speed_um_ms(pre_stim);
                    result.time_pre_stim = time(pre_stim)-min(time(pre_stim));
                    result.time_post_stim_standard = ty(post_stim_standard);
                    result.speed_post_stim = speed_um_ms(post_stim);
                    result.time_post_stim = time(post_stim)-min(time(post_stim));
                    result.filtered_speed_pre_stim = filtered(pre_stim_standard);
                    result.filtered_speed_post_stim = filtered(post_stim_standard);
                    sign_change = sign(mean(result.filtered_speed_pre_stim));
                    result.mean_pre_stim = mean(result.filtered_speed_pre_stim)*sign_change;
                    result.mean_post_stim = mean(result.filtered_speed_post_stim)*sign_change;
                    result.delta_mean = result.mean_pre_stim-result.mean_post_stim;
                    result.area_under_the_curve_pre_stim = sum(result.filtered_speed_pre_stim)*sign_change;
                    result.area_under_the_curve_post_stim = sum(result.filtered_speed_post_stim)*sign_change;
                    result.delta_area = result.area_under_the_curve_post_stim-result.area_under_the_curve_pre_stim;
                    result.peak_pre_stim = max(result.filtered_speed_pre_stim*sign_change);
                    result.peak_post_stim = max(result.filtered_speed_post_stim*sign_change);
                    result.sign_change = sign_change;
                    result.delta_peak = result.peak_post_stim-result.peak_pre_stim;
                    results = [results result];
                catch
                    disp(file_name)
                end
            end
       end

       function timei = location_to_time(locations,mat)
           timei = (locations - min(locations)+1)*mat.dt_ms/1000;
       end
    
       function all_file_info = organize_file_information(stimi_result)
            file_names = {stimi_result.file_name};
            vessel_id = LineScanFileNameHandler.get_vessel_identifyer(file_names);
            animal_id = LineScanFileNameHandler.get_animal_id(file_names);
            rois = LineScanFileNameHandler.get_roi(file_names);
            power_mW = LineScanFileNameHandler.get_power(file_names);
            n_experiment = numel(file_names);
            all_file_info = [];
            for expi = 1:n_experiment
                try
                    file_info = struct();
                    file_info.animal_id = animal_id{expi}{1};
                    if isempty(vessel_id{expi})
                        file_info.vessel_id=nan;
                    else
                        file_info.vessel_id = vessel_id{expi}{1};
                    end
                    file_info.roi = rois{expi}{1};
                    file_info.power_mw = power_mW(expi);
                    all_file_info = [all_file_info file_info];
                catch
                    disp(expi)
                end
            end
       end

       function results = print_nomality_test(all_file_info,stimi_result,pre_stim_field,post_stim_field)
            results = [];
            for animali = unique({all_file_info.animal_id})
                disp(animali{1})
                is_animal = arrayfun(@(x) strcmp(x.animal_id,animali),all_file_info);
                animal_file = all_file_info(is_animal);
                animal_result = stimi_result(is_animal);
                for vesseli = unique({animal_file.vessel_id})
                    disp(vesseli{1})
                    is_vessel = arrayfun(@(x) strcmp(x.vessel_id,vesseli),animal_file);
                    vessel_result = animal_result(is_vessel);
                    pre_stim = arrayfun(@(x) getfield(x,pre_stim_field),vessel_result);
                    post_stim = arrayfun(@(x) getfield(x,post_stim_field),vessel_result);
                    [H_pre, p_pre, ~] = swtest(pre_stim);
                    [H_post, p_post, ~] = swtest(post_stim);
                    if ~H_pre
                        cprintf('_red', [pre_stim_field ' is normally distributed' append(', p=',num2str(p_pre)) '\n'])
                    else
                        disp([pre_stim_field ' is not normally distributed' append(', p=',num2str(p_pre))])
                    end
                    if ~H_post
                        cprintf('_red', [post_stim_field ' is normally distributed' append(', p=',num2str(p_post)) '\n'])
                    else
                        disp([post_stim_field ' is not normally distributed' append(', p=',num2str(p_post))])
                    end
                    resulti = struct();
                    resulti.animali = animali;
                    resulti.vesseli = vesseli;
                    resulti.p_pre = p_pre;
                    resulti.p_post = p_post;
                    results = [results resulti];
                end
            end
       end

       function results = print_comparison_test(all_file_info,stimi_result,pre_stim_field,post_stim_field)
            results = [];
            for animali = unique({all_file_info.animal_id})
                disp(animali{1})
                is_animal = arrayfun(@(x) strcmp(x.animal_id,animali),all_file_info);
                animal_file = all_file_info(is_animal);
                animal_result = stimi_result(is_animal);
                for vesseli = unique({animal_file.vessel_id})
                    disp(vesseli{1})
                    is_vessel = arrayfun(@(x) strcmp(x.vessel_id,vesseli),animal_file);
                    vessel_result = animal_result(is_vessel);
                    pre_stim = arrayfun(@(x) getfield(x,pre_stim_field),vessel_result);
                    post_stim = arrayfun(@(x) getfield(x,post_stim_field),vessel_result);
                    [H_pre, p_pre, ~] = swtest(pre_stim);
                    [H_post, p_post, ~] = swtest(post_stim);
                    if ~H_pre && ~H_post
                        test = 't-test';
                        [h,p] = ttest(pre_stim,post_stim);
                    else
                        test = 'wilcoxon signed rank test';
                        [p,h,stats] = signrank(pre_stim,post_stim);
                    end
                    if h
                        cprintf('_red', ['groups are significantly different from ' test ' ' append(', p=',num2str(p)) '\n'])
                    else
                        disp(['groups are not significantly different from ' test ' ' append(', p=',num2str(p))])
                    end
                    resulti = struct();
                    resulti.animali = animali;
                    resulti.vesseli = vesseli;
                    resulti.p = p;
                    results = [results resulti];
                end
            end
       end



       function [pre_stims,post_stims,info] = get_trail_data(all_file_info,stimi_result,pre_stim_field,post_stim_field)
            pre_stims = {};
            post_stims = {};
            info = {};
            for animali = unique({all_file_info.animal_id})
                is_animal = arrayfun(@(x) strcmp(x.animal_id,animali),all_file_info);
                animal_file = all_file_info(is_animal);
                animal_result = stimi_result(is_animal);
                for vesseli = unique({animal_file.vessel_id})
                    is_vessel = arrayfun(@(x) strcmp(x.vessel_id,vesseli),animal_file);
                    vessel_result = animal_result(is_vessel);
                    pre_stim = arrayfun(@(x) getfield(x,pre_stim_field),vessel_result);
                    post_stim = arrayfun(@(x) getfield(x,post_stim_field),vessel_result);
                    pre_stims{end+1} = pre_stim;
                    post_stims{end+1} = post_stim;
                    info{end+1} = [animali{1} '_' vesseli{1}];
                end
            end
       end

       function plot_group_box_plot(pre_stims,post_stims,info)
            all_stims = cell(0);
            type = cell(0);
            for i = 1:numel(post_stims)
                all_stims{end+1}=pre_stims{i};
                all_stims{end+1}=post_stims{i};
                type{end+1} = 'pre';
                type{end+1} = 'post';
            end
            g = [];
            x = [];
            element_type = {};
            for i = 1:numel(all_stims)
                x = [x all_stims{i}];
                g = [g i*ones(size(all_stims{i}))];
                for j = 1:numel(all_stims{i})
                    element_type{end+1} = type{i};
                end
            end
            positions = 1:numel(all_stims);
            before_positions = 1:2:numel(all_stims);
            after_positions = 2:2:numel(all_stims);
            tick_positions = (before_positions+after_positions)/2;
            h = boxchart(g,x,'GroupByColor',element_type);
            set(h,'linewidth',2) 
            set(gca,'xtick',tick_positions) 
            set(gca,'xticklabel',info,'Fontsize',10) 
            hold on
            swarmchart(g,x,[],'k')
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
                    if ploti==5
                        disp('')
                    end
                    is_vessel = arrayfun(@(x) strcmp(x.vessel_id,vesseli),animal_file);
                    vessel_file = animal_file(is_vessel);
                    vessel_result = animal_result(is_vessel);
                    %subplot(plots_per_row,nrows,ploti)
                    hold on 
                    traces = [];
                    [vessel_trace,time] = WekaPlotter.unify_standardized_trace(vessel_result);
                    for stimi = 1:size(vessel_trace,2)
                        plot(time,vessel_trace(:,stimi),'Color',[0,0,0,0.2])
                    end
                    mean_trace = mean(vessel_trace');
                    all_mean_trace{end+1} = mean_trace;
                    plot(time,mean_trace,'Color','red')

                    [val,id] = max(mean_trace);
%                     [pks,locs] = findpeaks(mean_trace,'MinPeakProminence',0.1);
%                     post_stim = locs(locs>1000);
%                     loci = post_stim(1);
                    scatter(time(id),val,1000,'rx')
                    hold off
                    title({[animali{1} ' ' vesseli{1}],['tau = ' num2str((id-1000)/100) ' s']})
                    ploti = ploti+1;
%                     try
%                         ylim([mean(mean_trace)-0.8*std(mean_trace),mean(mean_trace)+0.8*std(mean_trace)])
%                     catch
%                         ylim([0,3])
%                     end
                    ylim([0,2])
                end
            end
       end

       function plot_histogram_grouped_by_vessel(all_file_info,stimi_result)
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
                    WekaPlotter.plot_rbc_histogram(vessel_result,animali,vesseli)
%                     hold on 
%                     pre = [];
%                     post = [];
%                     for i = numel(vessel_result)
%                         pre = [pre vessel_result(i).speed_pre_stim'*vessel_result(i).sign_change];
%                         post = [post vessel_result(i).speed_post_stim'*vessel_result(i).sign_change];
%                     end
%                     all = [pre post];
%                     bins = linspace(min(all)*0.8,max(all)*1.2,20);
%                     histogram(pre,bins)
%                     histogram(post,bins)
%                     hold off
%                     [h,p] = ttest2(pre,post);
%                     if h
%                         title({['\color{red}' animali{1} ' ' vesseli{1}],['t = ' num2str(p)]})
%                     else
%                         title({[animali{1} ' ' vesseli{1}],['t = ' num2str(p)]})
%                     end
                    ploti = ploti+1;
                end
            end
       end

       function plot_rbc_histogram(vessel_result,animal,vessel,nbins)
            hold on 
            pre = [];
            post = [];
            for i = numel(vessel_result)
                pre = [pre vessel_result(i).speed_pre_stim'*vessel_result(i).sign_change];
                post = [post vessel_result(i).speed_post_stim'*vessel_result(i).sign_change];
            end
            all = [pre post];
            bins = linspace(min(all)*0.8,max(all)*1.2,nbins);
            histogram(pre,bins)
            histogram(post,bins)
            hold off
            [h,p] = ttest2(pre,post);
            if h
                title({['\color{red}' animal ' ' vessel],['t = ' num2str(p)]})
            else
                title({[animali{1} ' ' vesseli{1}],['t = ' num2str(p)]})
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

       function plot_unfiltered_trace_separately(stimi_result,window_size_seconds)
            figure
            hold on
            ploti = 1;
            ncol = 4;
            nrow = ceil(numel(stimi_result)/ncol);
            tiledlayout(nrow,ncol, 'Padding', 'none', 'TileSpacing', 'compact'); 
            for stimi = 1:numel(stimi_result)
                resulti = stimi_result(stimi);
                speedi = resulti.speed*resulti.sign_change;
                if isinf(mean(speedi))||all(isnan(speedi))
                    continue
                end
                timei = resulti.time;
                timei = timei-min(timei);
                nexttile
                hold on
                plot(timei,speedi ,'LineWidth',3)
                ylim([min(speedi),max(speedi)])
                xlim([0,2*window_size_seconds])
                ploti = ploti+1;
            end
       end

       function plot_filtered_trace_separately(stimi_result,window_size_seconds)
            figure
            hold on
            ploti = 1;
            ncol = 4;
            max_row = 5;
            nplot = ceil(numel(stimi_result)/ncol/max_row);
            tiledlayout(max_row,ncol, 'Padding', 'none', 'TileSpacing', 'compact'); 
            for stimi = 1:numel(stimi_result)
                resulti = stimi_result(stimi);
                speedi = resulti.speed_standard*resulti.sign_change;
                if isinf(mean(speedi))||all(isnan(speedi))
                    continue
                end
                timei = resulti.time_standard;
                timei = timei-min(timei);
                nexttile
                hold on
                plot(timei,speedi ,'LineWidth',3)
                ylim([min(speedi),max(speedi)])
                line([window_size_seconds,window_size_seconds],[-10,10],'color','r')
                scatter(1.5*window_size_seconds,resulti.mean_post_stim,500,'r.')
                scatter(1.5*window_size_seconds,resulti.peak_post_stim,500,'b.')
                scatter(0.5*window_size_seconds,resulti.mean_pre_stim,500,'g.')
                scatter(0.5*window_size_seconds,resulti.peak_pre_stim,500,'m.')
                hold off
                xlim([0,2*window_size_seconds])
                name = resulti.file_name;
                name = split(name,'_');
                name = strjoin(name,' ');
                id = strfind(name,'vessel');
                title(name)
%                 [h,p] = ttest2(resulti.speed_pre_stim,resulti.speed_post_stim);
%                 if isempty(id)
%                     title(name)
%                 else
%                     if isnan(h)
%                         title({name(1:id-1),name(id:end),['t test not siginificant p=' num2str(p)]})
%                     else
%                         if h
%                             title({name(1:id-1),name(id:end),['\color{red} t test siginificant p=' num2str(p)]})
%                         else
%                             title({name(1:id-1),name(id:end),['t test not siginificant p=' num2str(p)]})
%                         end
%                     end
%                 end
                if ploti==20
                    figure
                    tiledlayout(max_row,ncol, 'Padding', 'none', 'TileSpacing', 'compact'); 
                    ploti=1;
                end
                ploti = ploti+1;
            end
       end

       function plot_all_filtered_traces_standardize_direction(stimi_result)
            figure
            hold on 
            for stimi = 1:numel(stimi_result)
                resulti = stimi_result(stimi);
                timei = resulti.time_standard;
                speedi = resulti.speed_standard*resulti.sign_change-resulti.mean_pre_stim;
                plot(timei-min(timei),speedi)
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

       function [standardized,time] = unify_standardized_trace(stimi_result)
            offset = [stimi_result.mean_pre_stim];
            sign = [stimi_result.sign_change];
            if size(stimi_result(1).filtered_speed_pre_stim,1)==1
                standardized = arrayfun(@(x) [x.filtered_speed_pre_stim x.filtered_speed_post_stim]' , stimi_result,'UniformOutput',false);
            else
                standardized = arrayfun(@(x) [x.filtered_speed_pre_stim' x.filtered_speed_post_stim']' , stimi_result,'UniformOutput',false);
            end
            [nsamples,id] = min(cellfun(@numel ,standardized));
            standardized = cellfun(@(x) x(1:nsamples),standardized,'UniformOutput',false);
            standardized = cell2mat(standardized);
            standardized = standardized./sign;
%             standardized = standardized-offset./sign;
            if size(stimi_result(1).filtered_speed_pre_stim,1)==1
                time= [stimi_result(id).time_pre_stim_standard stimi_result(id).time_post_stim_standard];
            else
                time= [stimi_result(id).time_pre_stim_standard' stimi_result(id).time_post_stim_standard'];
            end
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

       function [duration_ms,in_window,pre_stim,post_stim,pre_stim_standard,...
               post_stim_standard,in_window_standard] = get_stim_window(mat,stimulusi,...
               locations,stripe_statistics,duration,sampling_frequency,offset_seconds,window_size_seconds)
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
            start_time_standard = floor(start_time_ms/1000*sampling_frequency);
            end_time_standard = floor(end_time_ms/1000*sampling_frequency);
            offset_standard = floor(offset_seconds*sampling_frequency);
            window_size_standard = floor(window_size_seconds*sampling_frequency);
%             disp([stimulusi mat.tif_path])
%             if strcmp(mat.tif_path,'/net/dk-server/bholloway/Zhongkai/FoG/Pack-050522-NoCut_06-13-22_vessel-10_00001_roi_1.tif')
%                 disp('')
%             end
            standard_duration = floor(duration*sampling_frequency);
            standard_start = start_time_standard-window_size_standard;
            if standard_start <0
                standard_start=1;
            end
            standard_end = end_time_standard+window_size_standard;
            if standard_end > standard_duration
                standard_end = standard_duration;
            end
            pre_stim_standard = zeros(standard_duration,1);
            pre_stim_standard(standard_start:end_time_standard-offset_standard) = 1;
            post_stim_standard = zeros(standard_duration,1);
            post_stim_standard(end_time_standard+offset_standard:standard_end) = 1;
            in_window_standard = zeros(standard_duration,1);
            in_window_standard(standard_start:standard_end)=1;
            pre_stim_standard = pre_stim_standard==1;
            post_stim_standard = post_stim_standard==1;
            in_window_standard = in_window_standard==1;
       end

       function duration_ms = standardize_stimulation_duration(duration_ms)
            if duration_ms > 0 && duration_ms < 0.9
                duration_ms = 0.1;
            elseif duration_ms > .9 && duration_ms < 1.25
                duration_ms = 1;
            elseif duration_ms > 8 && duration_ms < 12.5
                duration_ms = 10;
            elseif duration_ms > 18 && duration_ms < 21
                duration_ms = 20;
            elseif duration_ms > 80 && duration_ms < 130
                duration_ms = 100;
            elseif duration_ms > 500 && duration_ms < 1250
                duration_ms = 1000;
            elseif duration_ms > 1900 && duration_ms < 2250
                duration_ms = 2000;
            elseif duration_ms > 145000 && duration_ms < 200000
                duration_ms = 200000;
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
