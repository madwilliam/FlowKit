mat_path = "/net/dk-server/bholloway/Zhongkai/FoG";
mat_files = dir( strcat( mat_path, '/**/*.mat' ) );
all_duration_ms = [];
lout = [];
speed = cell(0);
time = cell(0);
filenames = cell(0);
fs  = [];
for i=1:numel( mat_files )
    mat = load( (fullfile( mat_path, mat_files(i).name) ) );
    n_stimulus = numel( mat.start_time );  
    for stimulusi=1:n_stimulus 
        start_time_ms = mat.dt_ms*(mat.start_time(stimulusi));
        end_time_ms = mat.dt_ms*(mat.end_time(stimulusi));
        duration_ms = end_time_ms - start_time_ms;
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
        all_duration_ms = [all_duration_ms duration_ms];
        filenames{end+1} = [mat_files(i).name '_stim_' num2str(stimulusi)];
        fs = [fs mat.time_per_velocity_data_s];
        
        window_size_seconds = 10; 
        window_size_samples = window_size_seconds / mat.time_per_velocity_data_s; 
        offset_seconds = 0.5; 
        offset_samples = floor(offset_seconds/ mat.time_per_velocity_data_s);
        start_time_samples = floor(start_time_ms / 1000 / mat.time_per_velocity_data_s);
        end_time_samples = floor(end_time_ms/ 1000 / mat.time_per_velocity_data_s);
        
        analysis_start_samples = floor( start_time_samples - window_size_samples - offset_samples ); 
        if analysis_start_samples < 1
            analysis_start_samples = 1;
        end
        
        speed_prior = mat.speed( analysis_start_samples : start_time_samples - offset_samples );
        speed_prior_time = linspace(analysis_start_samples,start_time_samples - ...
            offset_samples,numel(speed_prior))*mat.time_per_velocity_data_s;
        
        analysis_end_time_samples = floor(end_time_samples + offset_samples + window_size_samples);
        if analysis_end_time_samples > numel( mat.speed )
            analysis_end_time_samples = numel( mat.speed - 1);
        end
        
        speed_post = mat.speed( (end_time_samples + offset_samples ) : ( analysis_end_time_samples ) );
        speed_post_time = linspace(end_time_samples + offset_samples,analysis_end_time_samples...
           ,numel(speed_post))*mat.time_per_velocity_data_s;
        speed{end+1} = [speed_prior speed_post];
        time{end+1} = [speed_prior_time speed_post_time];

%         figure
%         hold on 
%         plot(speed_prior_time,speed_prior)
%         plot(speed_post_time,speed_post)
%         hold off
%         ylim([-3,0])
        
%         speed_prior_mean = mean( speed_prior( isfinite( speed_prior ) ) );
%         speed_post_mean = mean( speed_post( isfinite( speed_post ) ) );
%         mT = num2str( stimulusi );
%         newName = append( {mat_files(i).name}, " stim_", mT );
%         
%         lout = [ lout; newName, duration_ms, speed_prior_mean, speed_post_mean, speed_post_mean / speed_prior_mean ];
    end
end
%%
for stimulationi = unique(all_duration_ms)
    disp([ 'stimulation duration ' num2str(stimulationi) ' ms'])
    disp(['total repeats ' num2str(sum(all_duration_ms==stimulationi))])
end
%%
stimulationi = 100;
is_stimulationi = all_duration_ms==stimulationi;
nstim = sum(is_stimulationi);
speed_for_stimulationi = speed(is_stimulationi);
time_for_stimulationi = time(is_stimulationi);
title_for_stimulationi = filenames(is_stimulationi);
fs_for_stimulationi = fs(is_stimulationi);
%%

counter = 0;
for stimi = 1:nstim
    speedi = speed_for_stimulationi{stimi};
    if isinf(mean(speedi))
        continue
    end
    counter=counter+1;
end
disp(counter)
%%
figure
hold on
ploti = 1;

tiledlayout(8,10, 'Padding', 'none', 'TileSpacing', 'compact'); 

for stimi = 1:nstim
    fsi = fs_for_stimulationi(stimi);
    titlei = title_for_stimulationi{stimi};
    speedi = speed_for_stimulationi{stimi};
    if isinf(mean(speedi))||all(isnan(speedi))
        continue
    end
    speedi = speedi-mean(speedi);
    timei = time_for_stimulationi{stimi};
    timei = timei-timei(1);
%     subplot(8,10,ploti)
    nexttile
    hold on
    plot(timei,speedi)
%     plot(timei,lowpass(speedi,5,1/fsi))
    plot(timei,medfilt1(speedi,100),'LineWidth',3)
    hold off
    ylim([-1.5,1.5])
    title(titlei)
    ploti = ploti+1;
end

%%